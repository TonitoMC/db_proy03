package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time" // Import time for date formatting

	_ "github.com/lib/pq" // Import the PostgreSQL driver
)

// Struct to hold Leave Analysis Report data
type LeaveAnalysisReportItem struct {
	StaffName      string     `json:"staff_name"`
	RoleName       string     `json:"role_name"`
	DepartmentName string     `json:"department_name"` // Note: This will show one row per department if staff is in multiple
	StartDate      time.Time  `json:"start_date"`
	EndDate        *time.Time `json:"end_date"` // Use pointer for nullable end_date
	Status         string     `json:"status"`
}

// Assuming 'db' is a globally accessible *sql.DB variable in the 'main' package.
// You must ensure this 'db' is successfully initialized before this handler is called.
// var db *sql.DB // This should be declared at the package level in your main.go

func GetLeaveAnalysisReportHandler(w http.ResponseWriter, r *http.Request) {
	// Build the base query with a subquery to calculate duration
	query := `
        SELECT 
            staff_name,
            role_name,
            department_name,
            start_date,
            end_date,
            status,
            leave_duration_days
        FROM (
            SELECT
                s.name AS staff_name,
                r.name AS role_name,
                d.name AS department_name,
                lr.start_date,
                lr.end_date,
                lr.status,
                CASE
                    WHEN lr.end_date IS NULL THEN EXTRACT(DAY FROM age(CURRENT_DATE, lr.start_date))
                    ELSE EXTRACT(DAY FROM age(lr.end_date, lr.start_date))
                END AS leave_duration_days
            FROM
                leave_requests lr
            JOIN
                staff s ON lr.staff_id = s.id
            JOIN
                roles r ON s.role_id = r.id
            JOIN
                staff_departments sd ON s.id = sd.staff_id
            JOIN
                departments d ON sd.department_id = d.id
            WHERE 1=1
    `

	// Collect the filters from the URL query parameters
	queryParams := r.URL.Query()

	// Build the WHERE clause dynamically
	var conditions []string
	var values []interface{}
	argCount := 1 // Parameter counter for parameterized queries

	// Date Range filter (using overlap logic)
	startDateStr := queryParams.Get("start_date")
	endDateStr := queryParams.Get("end_date")

	if startDateStr != "" && endDateStr != "" {
		conditions = append(conditions, fmt.Sprintf("(lr.start_date <= $%d AND (lr.end_date IS NULL OR lr.end_date >= $%d))",
			argCount, argCount+1))
		values = append(values, endDateStr, startDateStr)
		argCount += 2

		// Staff department validity check
		conditions = append(conditions, fmt.Sprintf("(sd.start_date IS NULL OR sd.start_date <= $%d)", argCount))
		values = append(values, endDateStr)
		argCount++

		conditions = append(conditions, fmt.Sprintf("(sd.end_date IS NULL OR sd.end_date >= $%d)", argCount))
		values = append(values, startDateStr)
		argCount++
	} else if startDateStr != "" {
		conditions = append(conditions, fmt.Sprintf("lr.start_date >= $%d", argCount))
		values = append(values, startDateStr)
		argCount++

		conditions = append(conditions, fmt.Sprintf("(sd.end_date IS NULL OR sd.end_date >= $%d)", argCount))
		values = append(values, startDateStr)
		argCount++
	} else if endDateStr != "" {
		conditions = append(conditions, fmt.Sprintf("(lr.end_date IS NULL OR lr.end_date <= $%d)", argCount))
		values = append(values, endDateStr)
		argCount++

		conditions = append(conditions, fmt.Sprintf("(sd.start_date IS NULL OR sd.start_date <= $%d)", argCount))
		values = append(values, endDateStr)
		argCount++
	}

	// Department filter (Handling multiple departments)
	departments := queryParams["department"]
	if len(departments) > 0 {
		placeholders := make([]string, len(departments))
		for i := range departments {
			placeholders[i] = fmt.Sprintf("$%d", argCount)
			values = append(values, departments[i])
			argCount++
		}
		conditions = append(conditions, fmt.Sprintf("d.name IN (%s)", strings.Join(placeholders, ", ")))
	}

	// Status filter
	statuses := queryParams["status"]
	if len(statuses) > 0 {
		placeholders := make([]string, len(statuses))
		for i := range statuses {
			placeholders[i] = fmt.Sprintf("$%d", argCount)
			values = append(values, statuses[i])
			argCount++
		}
		conditions = append(conditions, fmt.Sprintf("lr.status IN (%s)", strings.Join(placeholders, ", ")))
	}

	// Role filter
	roles := queryParams["role"]
	if len(roles) > 0 {
		placeholders := make([]string, len(roles))
		for i := range roles {
			placeholders[i] = fmt.Sprintf("$%d", argCount)
			values = append(values, roles[i])
			argCount++
		}
		conditions = append(conditions, fmt.Sprintf("r.name IN (%s)", strings.Join(placeholders, ", ")))
	}

	// Combine the WHERE clause conditions
	if len(conditions) > 0 {
		query += " AND " + strings.Join(conditions, " AND ")
	}

	// Close the subquery
	query += `) AS leave_data`

	// Add WHERE clause for duration filters to the outer query
	var outerConditions []string

	// Minimum Duration filter
	minDurationStr := queryParams.Get("min_duration")
	if minDurationStr != "" {
		minDuration, err := strconv.Atoi(minDurationStr)
		if err != nil {
			http.Error(w, "Invalid minimum duration parameter", http.StatusBadRequest)
			return
		}

		outerConditions = append(outerConditions, fmt.Sprintf("leave_duration_days >= $%d", argCount))
		values = append(values, minDuration)
		argCount++
	}

	// Maximum Duration filter
	maxDurationStr := queryParams.Get("max_duration")
	if maxDurationStr != "" {
		maxDuration, err := strconv.Atoi(maxDurationStr)
		if err != nil {
			http.Error(w, "Invalid maximum duration parameter", http.StatusBadRequest)
			return
		}

		outerConditions = append(outerConditions, fmt.Sprintf("leave_duration_days <= $%d", argCount))
		values = append(values, maxDuration)
		argCount++
	}

	// Add outer WHERE clause if duration filters exist
	if len(outerConditions) > 0 {
		query += " WHERE " + strings.Join(outerConditions, " AND ")
	}

	// Order by
	query += " ORDER BY start_date"

	// Log the final query (for debugging)
	log.Println("Executing query:", query)
	log.Println("With values:", values)

	// Execute the query
	rows, err := db.Query(query, values...)
	if err != nil {
		log.Printf("Error querying leave analysis report: %v", err)
		http.Error(w, "Failed to fetch leave analysis report", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Update struct to include duration
	type LeaveAnalysisReportWithDuration struct {
		LeaveAnalysisReportItem
		DurationDays float64 `json:"duration_days"`
	}

	// Process the results
	var reports []LeaveAnalysisReportWithDuration
	rowCount := 0

	for rows.Next() {
		rowCount++
		var report LeaveAnalysisReportWithDuration
		var startDate, endDate sql.NullTime

		err := rows.Scan(
			&report.StaffName,
			&report.RoleName,
			&report.DepartmentName,
			&startDate,
			&endDate,
			&report.Status,
			&report.DurationDays,
		)
		if err != nil {
			log.Printf("Error scanning leave analysis report row: %v", err)
			http.Error(w, "Failed to process leave analysis report data", http.StatusInternalServerError)
			return
		}

		if startDate.Valid {
			report.StartDate = startDate.Time
		} else {
			log.Printf("Warning: Null start_date encountered for staff %s", report.StaffName)
		}

		if endDate.Valid {
			report.EndDate = &endDate.Time
		} else {
			report.EndDate = nil
		}

		reports = append(reports, report)
	}

	log.Printf("Query returned %d rows", rowCount)

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over leave analysis report rows: %v", err)
		http.Error(w, "Failed to retrieve all leave analysis reports", http.StatusInternalServerError)
		return
	}

	// Set Content-Type header and encode as JSON
	w.Header().Set("Content-Type", "application/json")

	// Use json.Marshal to inspect the actual response before sending
	jsonBytes, err := json.MarshalIndent(reports, "", "  ")
	if err != nil {
		log.Printf("Error marshaling JSON: %v", err)
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}

	// Log the actual JSON being sent
	log.Printf("Sending JSON response of %d bytes: %s", len(jsonBytes), string(jsonBytes))

	// Write the response
	w.Write(jsonBytes)
}
