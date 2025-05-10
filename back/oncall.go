package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	_ "github.com/lib/pq"
)

// Struct to hold Staff Workload Report data
type StaffWorkloadReportItem struct {
	StaffID              int     `json:"staff_id"`
	StaffName            string  `json:"staff_name"`
	RoleName             string  `json:"role_name"`
	Departments          *string `json:"departments"`
	TotalShiftsAssigned  int     `json:"total_shifts_assigned"`
	OnCallShiftsAssigned int     `json:"on_call_shifts_assigned"`
	OnCallPercentage     float64 `json:"on_call_percentage"`
}

func GetStaffWorkloadAnalysisHandler(w http.ResponseWriter, r *http.Request) {
	// Build the base query (SELECT, FROM, JOINs)
	query := `
        SELECT
            s.id AS staff_id,
            s.name AS staff_name,
            r.name AS role_name,
            STRING_AGG(DISTINCT d.name, ', ') AS departments,
            COUNT(sa.id) AS total_shifts_assigned,
            COUNT(CASE WHEN sa.shift_type = 'on-call' THEN sa.id ELSE NULL END) AS on_call_shifts_assigned,
            CASE
                WHEN COUNT(sa.id) > 0 THEN CAST(COUNT(CASE WHEN sa.shift_type = 'on-call' THEN sa.id ELSE NULL END) AS DECIMAL) / COUNT(sa.id) * 100
                ELSE 0
            END AS on_call_percentage
        FROM
            staff s
        JOIN
            roles r ON s.role_id = r.id
        LEFT JOIN
            shift_assignments sa ON s.id = sa.staff_id
        LEFT JOIN
            departments d ON sa.department_id = d.id
        LEFT JOIN
            shifts sh ON sa.shift_id = sh.id
  			WHERE
  					sh.date BETWEEN $1 AND $2
  					AND r.name = 'Doctor'
    `

	// Collect the filters from the URL query parameters
	queryParams := r.URL.Query()

	// Build the WHERE and HAVING clauses dynamically
	var conditions []string
	var havingConditions []string
	var values []interface{}
	argCount := 1 // Parameter counter for parameterized queries

	// Required date range filter
	startDate := queryParams.Get("start_date")
	endDate := queryParams.Get("end_date")

	if startDate == "" || endDate == "" {
		http.Error(w, "Start date and end date are required", http.StatusBadRequest)
		return
	}

	// Add the mandatory date range condition
	conditions = append(conditions, fmt.Sprintf("(sh.date IS NULL OR (sh.date BETWEEN $%d AND $%d))", argCount, argCount+1))
	values = append(values, startDate, endDate)
	argCount += 2

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

	// Department Filter (Handling multiple departments)
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

	// Combine the WHERE clause conditions correctly
	if len(conditions) > 0 {
		query += " AND " + strings.Join(conditions, " AND ")
	}

	// Optional Filters for HAVING clause (based on aggregated counts)
	// Minimum Total Shifts
	minTotalShiftsStr := queryParams.Get("min_total_shifts")
	if minTotalShiftsStr != "" {
		minTotalShifts, err := strconv.Atoi(minTotalShiftsStr)
		if err != nil {
			http.Error(w, "Invalid value for min_total_shifts", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("COUNT(sa.id) >= $%d", argCount))
		values = append(values, minTotalShifts)
		argCount++
	}

	// Maximum Total Shifts
	maxTotalShiftsStr := queryParams.Get("max_total_shifts")
	if maxTotalShiftsStr != "" {
		maxTotalShifts, err := strconv.Atoi(maxTotalShiftsStr)
		if err != nil {
			http.Error(w, "Invalid value for max_total_shifts", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("COUNT(sa.id) <= $%d", argCount))
		values = append(values, maxTotalShifts)
		argCount++
	}

	// Minimum On-Call Shifts
	minOnCallShiftsStr := queryParams.Get("min_on_call_shifts")
	if minOnCallShiftsStr != "" {
		minOnCallShifts, err := strconv.Atoi(minOnCallShiftsStr)
		if err != nil {
			http.Error(w, "Invalid value for min_on_call_shifts", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("COUNT(CASE WHEN sa.shift_type = 'on-call' THEN sa.id ELSE NULL END) >= $%d", argCount))
		values = append(values, minOnCallShifts)
		argCount++
	}

	// Maximum On-Call Shifts
	maxOnCallShiftsStr := queryParams.Get("max_on_call_shifts")
	if maxOnCallShiftsStr != "" {
		maxOnCallShifts, err := strconv.Atoi(maxOnCallShiftsStr)
		if err != nil {
			http.Error(w, "Invalid value for max_on_call_shifts", http.StatusBadRequest)
			return
		}
		havingConditions = append(havingConditions, fmt.Sprintf("COUNT(CASE WHEN sa.shift_type = 'on-call' THEN sa.id ELSE NULL END) <= $%d", argCount))
		values = append(values, maxOnCallShifts)
		argCount++
	}

	hasAssignments := queryParams.Get("has_assignments")
	if strings.ToLower(hasAssignments) == "true" {
		havingConditions = append(havingConditions, "COUNT(sa.id) > 0")
	}

	// Combine the HAVING clause conditions
	if len(havingConditions) > 0 {
		query += " HAVING " + strings.Join(havingConditions, " AND ")
	}

	// Add GROUP BY
	query += `
    GROUP BY
        s.id, s.name, r.name
    `

	// Add ORDER BY
	query += " ORDER BY on_call_percentage DESC"

	// Log the final query (for debugging)
	log.Println("Executing query:", query)
	log.Println("With values:", values)

	// Execute the query
	rows, err := db.Query(query, values...)
	if err != nil {
		log.Printf("Error querying staff workload analysis report: %v", err)
		http.Error(w, "Failed to fetch staff workload analysis report", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Process the results
	var reports []StaffWorkloadReportItem
	for rows.Next() {
		var report StaffWorkloadReportItem
		var departments sql.NullString

		err := rows.Scan(
			&report.StaffID,
			&report.StaffName,
			&report.RoleName,
			&departments,
			&report.TotalShiftsAssigned,
			&report.OnCallShiftsAssigned,
			&report.OnCallPercentage,
		)
		if err != nil {
			log.Printf("Error scanning staff workload report row: %v", err)
			http.Error(w, "Failed to process report data", http.StatusInternalServerError)
			return
		}

		if departments.Valid {
			report.Departments = &departments.String
		} else {
			report.Departments = nil
		}

		reports = append(reports, report)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over staff workload report rows: %v", err)
		http.Error(w, "Failed to retrieve staff workload reports", http.StatusInternalServerError)
		return
	}

	// Set Content-Type header and encode as JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reports)
}
