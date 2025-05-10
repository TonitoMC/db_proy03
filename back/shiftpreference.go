package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	_ "github.com/lib/pq"
)

// Struct to hold Staff Preference Report
type StaffPreferenceReport struct {
	StaffID                        int     `json:"staff_id"`
	StaffName                      string  `json:"staff_name"`
	RoleName                       string  `json:"role_name"`
	Departments                    *string `json:"departments"`
	PreferredShiftTimes            *string `json:"preferred_shift_times"`
	TotalAssignmentsCount          int     `json:"total_assignments_count"`
	PreferredShiftAssignmentsCount int     `json:"preferred_shift_assignments_count"`
	PreferenceFulfillmentRate      float64 `json:"preference_fulfillment_rate"`
}

func GetStaffPreferenceAnalysisReportHandler(w http.ResponseWriter, r *http.Request) {
	query := `
        SELECT
            s.id AS staff_id,
            s.name AS staff_name,
            r.name AS role_name,
            STRING_AGG(DISTINCT d.name, ', ') AS departments,
            STRING_AGG(DISTINCT st_pref.name, ', ') AS preferred_shift_times,
            COUNT(sa.id) AS total_assignments_count,
            COUNT(CASE WHEN ssp.shift_time_id = sh.shift_time_id THEN sa.id ELSE NULL END) AS preferred_shift_assignments_count,
            CASE
                WHEN COUNT(sa.id) > 0 THEN CAST(COUNT(CASE WHEN ssp.shift_time_id = sh.shift_time_id THEN sa.id ELSE NULL END) AS DECIMAL) / COUNT(sa.id)
                ELSE 0
            END AS preference_fulfillment_rate
        FROM
            staff s
        JOIN
            roles r ON s.role_id = r.id
        LEFT JOIN
            staff_departments sd ON s.id = sd.staff_id
        LEFT JOIN
            departments d ON sd.department_id = d.id
        LEFT JOIN
            shift_assignments sa ON s.id = sa.staff_id
        LEFT JOIN
            shifts sh ON sa.shift_id = sh.id
        LEFT JOIN
            staff_shift_preferences ssp ON s.id = ssp.staff_id
        LEFT JOIN
            shift_times st_pref ON ssp.shift_time_id = st_pref.id
				WHERE
						sh.date BETWEEN $1 AND $2
    `

	// Collect the filters from the URL query parameters
	queryParams := r.URL.Query()

	// Build the WHERE and HAVING clauses dynamically
	var conditions []string
	var havingConditions []string
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

	// Shift times, was planned to be multiple but ended as single param
	preferredShifts := queryParams["preferred_shift_time"]
	if len(preferredShifts) > 0 {
		placeholders := make([]string, len(preferredShifts))
		for i := range preferredShifts {
			placeholders[i] = fmt.Sprintf("$%d", argCount+i)
		}
		conditions = append(conditions, fmt.Sprintf("st_pref.name IN (%s)", strings.Join(placeholders, ", ")))
		for _, shift := range preferredShifts {
			values = append(values, shift)
		}
		argCount += len(preferredShifts)
	}

	// Assigned shift, was planned to be multiple but ended as single param
	assignedShifts := queryParams["assigned_shift_time"]
	if len(assignedShifts) > 0 {
		placeholders := make([]string, len(assignedShifts))
		for i := range assignedShifts {
			placeholders[i] = fmt.Sprintf("$%d", argCount+i)
		}
		conditions = append(conditions, fmt.Sprintf("(sh.shift_time_id IS NULL OR sh.shift_time_id IN (SELECT id FROM shift_times WHERE name IN (%s)))", strings.Join(placeholders, ", ")))
		for _, shift := range assignedShifts {
			values = append(values, shift)
		}
		argCount += len(assignedShifts)
	}

	if len(conditions) > 0 {
		query += " AND " + strings.Join(conditions, " AND ")
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
	query += " ORDER BY preference_fulfillment_rate DESC"

	log.Println("Executing query:", query)
	log.Println("With values:", values)

	// Execute the query
	rows, err := db.Query(query, values...)
	if err != nil {
		log.Printf("Error querying staff preference analysis report: %v", err)
		http.Error(w, "Failed to fetch staff preference analysis report", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Process the results
	var reports []StaffPreferenceReport
	for rows.Next() {
		var report StaffPreferenceReport
		var departments sql.NullString
		var preferredShiftTimes sql.NullString

		err := rows.Scan(
			&report.StaffID,
			&report.StaffName,
			&report.RoleName,
			&departments,
			&preferredShiftTimes,
			&report.TotalAssignmentsCount,
			&report.PreferredShiftAssignmentsCount,
			&report.PreferenceFulfillmentRate,
		)
		if err != nil {
			log.Printf("Error scanning staff preference report row: %v", err)
			http.Error(w, "Failed to process report data", http.StatusInternalServerError)
			return
		}

		if departments.Valid {
			report.Departments = &departments.String
		} else {
			report.Departments = nil
		}
		if preferredShiftTimes.Valid {
			report.PreferredShiftTimes = &preferredShiftTimes.String
		} else {
			report.PreferredShiftTimes = nil
		}

		reports = append(reports, report)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating over staff preference report rows: %v", err)
		http.Error(w, "Failed to retrieve staff preference reports", http.StatusInternalServerError)
		return
	}

	// Set Content-Type header and encode as JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reports)
}
