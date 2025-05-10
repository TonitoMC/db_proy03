package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	_ "github.com/lib/pq"
)

var db *sql.DB

func main() {
	// DB conn URL
	dbURL := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("POSTGRES_HOST"),
		os.Getenv("POSTGRES_PORT"),
		os.Getenv("POSTGRES_USER"),
		os.Getenv("POSTGRES_PASSWORD"),
		os.Getenv("POSTGRES_DB"))

	var err error

	// Open DB conn
	db, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}
	defer db.Close()

	// Test the connection
	pingErr := db.Ping()
	if pingErr != nil {
		log.Fatalf("Failed to ping database: %v", pingErr)
	}

	log.Println("Successfully connected to the database!")

	// Chi router
	r := chi.NewRouter()

	// Allow frontend requests
	corsMiddleware := cors.New(cors.Options{
		AllowedOrigins:   []string{"http://localhost:5173"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"*"},
		ExposedHeaders:   []string{"*"},
		AllowCredentials: true,
		MaxAge:           300,
	})

	// Middleware
	r.Use(corsMiddleware.Handler)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	// Report routes
	r.Get("/reports/leave-analysis", GetLeaveAnalysisReportHandler)
	r.Get("/reports/oncall-analysis", GetStaffWorkloadAnalysisHandler)
	r.Get("/reports/overtime", GetOvertimeAnalysisReportHandler)
	r.Get("/reports/shift-preference", GetStaffPreferenceAnalysisReportHandler)
	r.Get("/reports/work-hours", GetHoursWorkedReportHandler)
	r.Get("/reports/monthly-shifts", GetMonthlyShiftsHandler)

	// Start the server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default port
	}

	// Logs
	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}
