package main

import (
	_ "database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	_ "github.com/lib/pq"
)

// Struct to hold each report row
type HoursWorkedReport struct {
	StaffName        string  `json:"staff_name"`
	RoleName         string  `json:"role_name"`
	DepartmentName   string  `json:"department_name"`
	TotalHoursWorked float64 `json:"total_hours_worked"`
}

func GetHoursWorkedReportHandler(w http.ResponseWriter, r *http.Request) {
	// Build the base query
	query := `
        SELECT
            s.name AS staff_name,
            r.name AS role_name,
            d.name AS department_name,
            SUM(EXTRACT(EPOCH FROM
                CASE
                    WHEN sl.check_out >= sl.check_in THEN (sl.check_out - sl.check_in)
                    ELSE ((sl.check_out + INTERVAL '1 day') - sl.check_in)
                END
            )) / 3600 AS total_hours_worked
        FROM
            shift_logs sl
        JOIN
            shift_assignments sa ON sl.assignment_id = sa.id
        JOIN
            staff s ON sa.staff_id = s.id
        JOIN
            roles r ON s.role_id = r.id
        JOIN
            departments d ON sa.department_id = d.id
        JOIN
            shifts sh ON sa.shift_id = sh.id
        WHERE
            sh.date BETWEEN $1 AND $2
            AND sl.check_in IS NOT NULL
            AND sl.check_out IS NOT NULL
    `

	// Collect the filters from the URL
	queryParams := r.URL.Query()

	// Build the WHERE clause dynamically
	var conditions []string
	var values []interface{}
	argCount := 3 // Parameter counter for parameterized queries

	// Required date range filter
	startDate := queryParams.Get("start_date")
	endDate := queryParams.Get("end_date")

	if startDate == "" || endDate == "" {
		http.Error(w, "Start date and end date are required", http.StatusBadRequest)
		return
	}
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

	// Combine the WHERE clauses, they're built with placeholders
	// so it's safe to concatenate them
	if len(conditions) > 0 {
		query += " AND " + strings.Join(conditions, " AND ")
	}

	// Add the GROUP BY clause
	query += `
    GROUP BY
        s.name, r.name, d.name
    `

	// Build the HAVING clause dynamically
	var havingConditions []string

	// Minimum hours worked filter
	minHoursParam := queryParams.Get("min_hours")
	if minHoursParam != "" {
		minHours, err := strconv.ParseFloat(minHoursParam, 64)
		if err != nil {
			http.Error(w, "Invalid value for min_hours", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("SUM(EXTRACT(EPOCH FROM CASE WHEN sl.check_out >= sl.check_in THEN (sl.check_out - sl.check_in) ELSE ((sl.check_out + INTERVAL '1 day') - sl.check_in) END)) / 3600 >= $%d", argCount))
		values = append(values, minHours)
		argCount++
	}

	// Maximum hours worked filter
	maxHoursParam := queryParams.Get("max_hours")
	if maxHoursParam != "" {
		maxHours, err := strconv.ParseFloat(maxHoursParam, 64)
		if err != nil {
			http.Error(w, "Invalid value for max_hours", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("SUM(EXTRACT(EPOCH FROM CASE WHEN sl.check_out >= sl.check_in THEN (sl.check_out - sl.check_in) ELSE ((sl.check_out + INTERVAL '1 day') - sl.check_in) END)) / 3600 <= $%d", argCount))
		values = append(values, maxHours)
		argCount++
	}

	// Combine the HAVING clause conditions
	if len(havingConditions) > 0 {
		query += " HAVING " + strings.Join(havingConditions, " AND ")
	}

	// Order by
	query += " ORDER BY total_hours_worked DESC"

	// Log the final query (for debugging)
	log.Println("Executing query:", query)
	log.Println("With values:", values)

	// Execute the query
	rows, err := db.Query(query, values...)
	if err != nil {
		log.Printf("Error querying hours worked report: %v", err)
		http.Error(w, "Failed to fetch hours worked report", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Process the results
	var reports []HoursWorkedReport
	for rows.Next() {
		var report HoursWorkedReport
		err := rows.Scan(
			&report.StaffName,
			&report.RoleName,
			&report.DepartmentName,
			&report.TotalHoursWorked,
		)
		if err != nil {
			log.Printf("Error scanning hours worked report row: %v", err)
			http.Error(w, "Failed to process hours worked report", http.StatusInternalServerError)
			return
		}
		reports = append(reports, report)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over hours worked report rows: %v", err)
		http.Error(w, "Failed to retrieve hours worked reports", http.StatusInternalServerError)
		return
	}

	// Set Content-Type header and encode as JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reports)
}
