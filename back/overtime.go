package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	_ "github.com/lib/pq"
)

// Struct for each line of the response
type OvertimeReport struct {
	StaffName      string  `json:"staff_name"`
	RoleName       string  `json:"role_name"`
	DepartmentName string  `json:"department_name"`
	TotalOvertime  float64 `json:"total_overtime"`
}

// Handler for overtime analysis
func GetOvertimeAnalysisReportHandler(w http.ResponseWriter, r *http.Request) {
	// Base query, selects information & joins basic tables & starts
	// a WHERE 1 = 1 so we can dynamically add the filters from our frontend
	query := `
        SELECT
            s.name AS staff_name,
            r.name AS role_name,
            d.name AS department_name,
            SUM(EXTRACT(EPOCH FROM o.duration)) / 3600 AS total_overtime_hours
        FROM
            overtimes o
        JOIN
            shift_assignments sa ON o.shift_assignment_id = sa.id
        JOIN
            staff s ON sa.staff_id = s.id
        JOIN
            roles r ON s.role_id = r.id
        JOIN
            departments d ON sa.department_id = d.id
        JOIN
            shifts sh ON sa.shift_id = sh.id
        WHERE 1=1
    `

	// Collect the filters from URL
	queryParams := r.URL.Query()

	// Build the WHERE clause dynamically
	var conditions []string
	var values []interface{}
	argCount := 1 // Used to dynamically build queries with the PSQL driver, where placeholders are numbers.

	// Required date range filter,
	// builds query & increments argCount
	startDate := queryParams.Get("start_date")
	endDate := queryParams.Get("end_date")
	if startDate != "" && endDate != "" {
		conditions = append(conditions, fmt.Sprintf("sh.date >= $%d AND sh.date <= $%d", argCount, argCount+1))
		values = append(values, startDate, endDate)
		argCount += 2
	} else {
		http.Error(w, "Start date and end date are required", http.StatusBadRequest)
		return
	}

	// Role filter, adds a where clause & increments argCount if needed
	role := queryParams.Get("role")
	if role != "" {
		conditions = append(conditions, fmt.Sprintf("r.name = $%d", argCount))
		values = append(values, role)
		argCount++
	}

	// Department filter, adds a where clause & increments argCount if needed
	department := queryParams.Get("department")
	if department != "" {
		conditions = append(conditions, fmt.Sprintf("d.name = $%d", argCount))
		values = append(values, department)
		argCount++
	}

	// Combine the WHERE clause conditions, this is safe as it just created a
	// query string of the form
	// "WHERE condition = $1 AND condition = $2", etc.
	if len(conditions) > 0 {
		query += " AND " + strings.Join(conditions, " AND ")
	}

	// Group by, some of these needed to be included
	query += `
  GROUP BY
      s.name, r.name, d.name
  `

	// Build the HAVING clause dynamically
	var havingConditions []string

	// Minimum overtime hours
	minOvertimeStr := queryParams.Get("min_overtime_hours")
	if minOvertimeStr != "" {
		minOvertime, err := strconv.ParseFloat(minOvertimeStr, 64)
		if err != nil {
			http.Error(w, "Invalid minimum overtime hours", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("SUM(EXTRACT(EPOCH FROM o.duration)) / 3600 >= $%d", argCount))
		values = append(values, minOvertime)
		argCount++
	}

	// Maximum overtime hours
	maxOvertimeStr := queryParams.Get("max_overtime_hours")
	if maxOvertimeStr != "" {
		maxOvertime, err := strconv.ParseFloat(maxOvertimeStr, 64)
		if err != nil {
			http.Error(w, "Invalid maximum overtime hours", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("SUM(EXTRACT(EPOCH FROM o.duration)) / 3600 <= $%d", argCount))
		values = append(values, maxOvertime)
		argCount++
	}

	// Combine the previous conditions
	if len(havingConditions) > 0 {
		query += " HAVING " + strings.Join(havingConditions, " AND ")
	}

	// Get results in descending order
	query += " ORDER BY total_overtime_hours DESC"

	// Log the final query (for debugging)
	log.Println("Executing query:", query)
	log.Println("With values:", values)

	// Execute the query
	rows, err := db.Query(query, values...)
	if err != nil {
		log.Printf("Error querying overtime analysis report: %v", err)
		http.Error(w, "Failed to fetch overtime analysis report", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Process the results
	var reports []OvertimeReport
	for rows.Next() {
		var report OvertimeReport
		err := rows.Scan(
			&report.StaffName,
			&report.RoleName,
			&report.DepartmentName,
			&report.TotalOvertime,
		)
		if err != nil {
			log.Printf("Error scanning overtime analysis report row: %v", err)
			http.Error(w, "Failed to process overtime analysis report", http.StatusInternalServerError)
			return
		}
		reports = append(reports, report)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over overtime analysis report rows: %v", err)
		http.Error(w, "Failed to retrieve overtime analysis reports", http.StatusInternalServerError)
		return
	}

	// Set Content-Type header and encode as JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reports)
}
