package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	_ "github.com/lib/pq"
)

// Struct for Monthly Shift Assignments Report Data
type MonthlyShiftAssignmentItem struct {
	AssignmentYear      int    `json:"assignment_year"`
	AssignmentMonth     int    `json:"assignment_month"`
	AssignmentMonthYear string `json:"assignment_month_year"` // YYYY-MM format for plotting
	TotalShifts         int    `json:"total_shifts"`
}

// Handler for Monthly Shift Assignments Report
func GetMonthlyShiftsHandler(w http.ResponseWriter, r *http.Request) {
	// Build the query to aggregate shifts by month
	query := `
        SELECT
            EXTRACT(YEAR FROM sh.date) AS assignment_year,
            EXTRACT(MONTH FROM sh.date) AS assignment_month,
            TO_CHAR(sh.date, 'YYYY-MM') AS assignment_month_year,
            COUNT(sa.id) AS total_shifts
        FROM
            shift_assignments sa
        JOIN
            shifts sh ON sa.shift_id = sh.id
        LEFT JOIN -- Keep LEFT JOINs for potential filtering
            staff s ON sa.staff_id = s.id
        LEFT JOIN
            roles r ON s.role_id = r.id
        LEFT JOIN
            departments d ON sa.department_id = d.id
        LEFT JOIN
            shift_times st ON sh.shift_time_id = st.id
        WHERE
            sh.date BETWEEN $1 AND $2
    `

	// Collect the filters from URL
	queryParams := r.URL.Query()

	// Build the WHERE clause dynamically
	var conditions []string
	var values []interface{}
	argCount := 3 // Used to dynamically build queries

	// Required date filter
	startDate := queryParams.Get("start_date")
	endDate := queryParams.Get("end_date")

	if startDate == "" || endDate == "" {
		http.Error(w, "Start date and end date are required", http.StatusBadRequest)
		return
	}

	// Add the mandatory date range condition
	values = append(values, startDate, endDate)
	// Role filter, builds query & increments argCount
	role := queryParams.Get("role")
	if role != "" {
		conditions = append(conditions, fmt.Sprintf("r.name = $%d", argCount))
		values = append(values, role)
		argCount++
	}

	// Department filter, builds query & increments argCount
	department := queryParams.Get("department")
	if department != "" {
		conditions = append(conditions, fmt.Sprintf("d.name = $%d", argCount))
		values = append(values, department)
		argCount++
	}

	// Optional Shift Type Filter (Planned to be multi-select but dropped)
	shiftTypes := queryParams["shift_type"]
	if len(shiftTypes) > 0 {
		placeholders := make([]string, len(shiftTypes))
		for i := range shiftTypes {
			placeholders[i] = fmt.Sprintf("$%d", argCount+i)
		}
		conditions = append(conditions, fmt.Sprintf("sa.shift_type IN (%s)", strings.Join(placeholders, ", ")))
		for _, sType := range shiftTypes {
			values = append(values, sType)
		}
		argCount += len(shiftTypes)
	}

	// Optional Shift Time Filter (Planned to be multi-select but dropped)
	shiftTimes := queryParams["shift_time"]
	if len(shiftTimes) > 0 {
		placeholders := make([]string, len(shiftTimes))
		for i := range shiftTimes {
			placeholders[i] = fmt.Sprintf("$%d", argCount+i)
		}
		conditions = append(conditions, fmt.Sprintf("st.name IN (%s)", strings.Join(placeholders, ", ")))
		for _, sTime := range shiftTimes {
			values = append(values, sTime)
		}
		argCount += len(shiftTimes)
	}

	// Combine the WHERE clause conditions
	if len(conditions) > 0 {
		query += " AND " + strings.Join(conditions, " AND ")
	}

	query += `
        GROUP BY
            EXTRACT(YEAR FROM sh.date),
            EXTRACT(MONTH FROM sh.date),
            TO_CHAR(sh.date, 'YYYY-MM')
    `

	query += " ORDER BY assignment_year, assignment_month"

	log.Println("Executing query:", query)
	log.Println("With values:", values)

	rows, err := db.Query(query, values...)
	if err != nil {
		log.Printf("Error querying monthly shift assignments report: %v", err)
		http.Error(w, "Failed to fetch monthly shift assignments report", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var reports []MonthlyShiftAssignmentItem
	for rows.Next() {
		var report MonthlyShiftAssignmentItem
		err := rows.Scan(
			&report.AssignmentYear,
			&report.AssignmentMonth,
			&report.AssignmentMonthYear,
			&report.TotalShifts,
		)
		if err != nil {
			log.Printf("Error scanning monthly shift assignments report row: %v", err)
			http.Error(w, "Failed to process monthly shift assignments report data", http.StatusInternalServerError)
			return
		}
		reports = append(reports, report)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over monthly shift assignments report rows: %v", err)
		http.Error(w, "Failed to retrieve all monthly shift assignments reports", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reports)
}
