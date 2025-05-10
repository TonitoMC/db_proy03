package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	// Import time for date formatting
	_ "github.com/lib/pq" // Import the PostgreSQL driver
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
    `

	// Collect the filters from URL
	queryParams := r.URL.Query()

	// Build the WHERE clause dynamically
	var conditions []string
	var values []interface{}
	argCount := 1 // Used to dynamically build queries

	// Date Range Filter (REQUIRED)
	startDate := queryParams.Get("start_date")
	endDate := queryParams.Get("end_date")

	if startDate == "" || endDate == "" {
		http.Error(w, "Start date and end date are required", http.StatusBadRequest)
		return
	}

	// Add the mandatory date range condition
	conditions = append(conditions, fmt.Sprintf("sh.date BETWEEN $%d AND $%d", argCount, argCount+1))
	values = append(values, startDate, endDate)
	argCount += 2

	// Optional Role Filter (Multi-select)
	roles := queryParams["role"]
	if len(roles) > 0 {
		placeholders := make([]string, len(roles))
		for i := range roles {
			placeholders[i] = fmt.Sprintf("$%d", argCount+i)
		}
		conditions = append(conditions, fmt.Sprintf("r.name IN (%s)", strings.Join(placeholders, ", ")))
		for _, role := range roles {
			values = append(values, role)
		}
		argCount += len(roles)
	}

	// Optional Department Filter (Multi-select)
	departments := queryParams["department"]
	if len(departments) > 0 {
		placeholders := make([]string, len(departments))
		for i := range departments {
			placeholders[i] = fmt.Sprintf("$%d", argCount+i)
		}
		conditions = append(conditions, fmt.Sprintf("d.name IN (%s)", strings.Join(placeholders, ", ")))
		for _, dept := range departments {
			values = append(values, dept)
		}
		argCount += len(departments)
	}

	// Optional Shift Type Filter (Dropdown)
	shiftTypes := queryParams["shift_type"] // Assuming this is the param name
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

	// Optional Shift Time Filter (Multi-select)
	shiftTimes := queryParams["shift_time"] // Assuming this is the param name
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
		query += " WHERE " + strings.Join(conditions, " AND ")
	}

	// **Group by year and month**
	query += `
        GROUP BY
            EXTRACT(YEAR FROM sh.date),
            EXTRACT(MONTH FROM sh.date),
            TO_CHAR(sh.date, 'YYYY-MM')
    `

	// No HAVING clause needed for this simple count per month

	// **Order chronologically by year and month**
	query += " ORDER BY assignment_year, assignment_month"

	// Log the final query (for debugging)
	log.Println("Executing query:", query)
	log.Println("With values:", values)

	// Execute the query
	// Assuming 'db' is a globally accessible and initialized *sql.DB variable.
	rows, err := db.Query(query, values...)
	if err != nil {
		log.Printf("Error querying monthly shift assignments report: %v", err)
		http.Error(w, "Failed to fetch monthly shift assignments report", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Process the results
	var reports []MonthlyShiftAssignmentItem // Use the new struct
	for rows.Next() {
		var report MonthlyShiftAssignmentItem
		// Scan into the new struct
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

	// Set Content-Type header and encode as JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reports) // Encode the slice
}
