package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	_ "github.com/lib/pq" // Import the PostgreSQL driver
)

// Struct to hold Staff Preference Report
type StaffPreferenceReport struct {
	StaffID                        int     `json:"staff_id"`
	StaffName                      string  `json:"staff_name"`
	RoleName                       string  `json:"role_name"`
	Departments                    *string `json:"departments"`           // Use pointer for nullable STRING_AGG
	PreferredShiftTimes            *string `json:"preferred_shift_times"` // Use pointer for nullable STRING_AGG
	TotalAssignmentsCount          int     `json:"total_assignments_count"`
	PreferredShiftAssignmentsCount int     `json:"preferred_shift_assignments_count"`
	PreferenceFulfillmentRate      float64 `json:"preference_fulfillment_rate"`
}

func GetStaffPreferenceAnalysisReportHandler(w http.ResponseWriter, r *http.Request) {
	// Build the base SELECT and FROM clauses
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
    `

	// Collect the filters from the URL query parameters
	queryParams := r.URL.Query()

	// Build the WHERE and HAVING clauses dynamically
	var conditions []string
	var havingConditions []string
	var values []interface{}
	argCount := 1 // Parameter counter for parameterized queries

	// Date Range Filter (REQUIRED)
	startDate := queryParams.Get("start_date")
	endDate := queryParams.Get("end_date")

	if startDate == "" || endDate == "" {
		http.Error(w, "Start date and end date are required", http.StatusBadRequest)
		return
	}

	// Add the mandatory date range conditions first
	conditions = append(conditions, fmt.Sprintf("(sh.date IS NULL OR (sh.date BETWEEN $%d AND $%d))", argCount, argCount+1))
	values = append(values, startDate, endDate)
	argCount += 2

	conditions = append(conditions, fmt.Sprintf("(sd.start_date IS NULL OR sd.start_date <= $%d)", argCount))
	values = append(values, endDate) // Parameter for sd.start_date <= $end_date
	argCount++

	conditions = append(conditions, fmt.Sprintf("(sd.end_date IS NULL OR sd.end_date >= $%d)", argCount))
	values = append(values, startDate) // Parameter for sd.end_date >= $start_date
	argCount++

	// Optional Filters for WHERE clause
	// Staff Member Filter
	staffIDStr := queryParams.Get("staff_id")
	if staffIDStr != "" {
		staffID, err := strconv.Atoi(staffIDStr)
		if err != nil {
			http.Error(w, "Invalid staff_id", http.StatusBadRequest)
			return
		}
		conditions = append(conditions, fmt.Sprintf("s.id = $%d", argCount))
		values = append(values, staffID)
		argCount++
	}

	// Role Filter (Handling multiple roles)
	roles := queryParams["role"] // Get all values for 'role'
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
	departments := queryParams["department"] // Get all values for 'department'
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

	// Preferred Shift Time Filter (Handling multiple preferred shifts)
	preferredShifts := queryParams["preferred_shift_time"] // Get all values for 'preferred_shift_time'
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

	// Assigned Shift Time Filter (Handling multiple assigned shifts)
	// This filter needs to apply to the assigned shift time (sh.shift_time_id)
	assignedShifts := queryParams["assigned_shift_time"] // Get all values for 'assigned_shift_time'
	if len(assignedShifts) > 0 {
		// Need to get the IDs for the assigned shift times from the database
		// This would require a separate query or joining shift_times again with a different alias
		// For simplicity in this example, let's assume filtering by name directly is acceptable
		// if shift_times.name is unique. If not, filter by ID after a lookup.
		placeholders := make([]string, len(assignedShifts))
		for i := range assignedShifts {
			placeholders[i] = fmt.Sprintf("$%d", argCount+i)
		}
		// Join shift_times again with an alias for assigned shifts if needed for name filtering
		// In this query structure, st_assigned isn't explicitly joined,
		// so we filter based on sh.shift_time_id matching a preferred shift time ID.
		// To filter by assigned shift name, we'd need:
		// JOIN shift_times st_assigned ON sh.shift_time_id = st_assigned.id
		// And the condition would be st_assigned.name IN (...)
		// For now, let's add a comment indicating this would require a modification.
		log.Println("Note: Filtering by assigned_shift_time by name requires joining shift_times again.")
		// For a simple example filtering by name (assuming unique names):
		conditions = append(conditions, fmt.Sprintf("(sh.shift_time_id IS NULL OR sh.shift_time_id IN (SELECT id FROM shift_times WHERE name IN (%s)))", strings.Join(placeholders, ", ")))
		for _, shift := range assignedShifts {
			values = append(values, shift)
		}
		argCount += len(assignedShifts)
	}

	// Combine the WHERE clause conditions
	if len(conditions) > 0 {
		query += " WHERE " + strings.Join(conditions, " AND ")
	}

	// Optional Filter for HAVING clause
	// Filter for staff with at least one assignment within the date range
	hasAssignments := queryParams.Get("has_assignments") // e.g., ?has_assignments=true
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
	query += " ORDER BY s.name"

	// Log the final query (for debugging)
	log.Println("Executing query:", query)
	log.Println("With values:", values)

	// Execute the query
	rows, err := db.Query(query, values...) // Assuming 'db' is globally accessible in main package
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
		var departments sql.NullString         // Use sql.NullString for potentially null STRING_AGG
		var preferredShiftTimes sql.NullString // Use sql.NullString for potentially null STRING_AGG

		err := rows.Scan(
			&report.StaffID,
			&report.StaffName,
			&report.RoleName,
			&departments,         // Scan into sql.NullString
			&preferredShiftTimes, // Scan into sql.NullString
			&report.TotalAssignmentsCount,
			&report.PreferredShiftAssignmentsCount,
			&report.PreferenceFulfillmentRate, // Scan the calculated rate
		)
		if err != nil {
			log.Printf("Error scanning staff preference report row: %v", err)
			http.Error(w, "Failed to process report data", http.StatusInternalServerError)
			return
		}

		// Assign from sql.NullString to the struct fields (pointers)
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
