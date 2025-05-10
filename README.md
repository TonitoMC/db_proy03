# Hospital Staff Reporting

This project was made as part of a Relational Databases University course, it's objective was to make a simple reporting application where the reports are
calculated in real-time. This means, all of the information processing, grouping, filtering, etc. is done by dynamically building queries sent to a PostgreSQL database.
We were also tasked with building a frontend, allowing the user of the application to see the reports, visualize via graphs, export to PDF & CSV.

Note: Some of the handlers in the backend support multi-valued filters, for example Shift_type, but these are not supported in the front-end due to time constraints.

## Running this Project

### Dependencies

Docker & Docker Compose

### How to Run

Run the following command in the root of the directory:

```
docker compose up --build
```

Note: The front-end repository is running in the development version, however, this should not affect anything
