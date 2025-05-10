
# Use a Go base image
FROM golang:1.23.8-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files
COPY go.mod go.sum ./
RUN go mod download

# Copy your application code
COPY . .

# Expose the port your Go application listens on
EXPOSE 8080 

# Command to build and run your application
# This will build the binary and then run it.
# You'll need to rebuild the Docker image or container to see code changes.
CMD ["go", "run", "."] 
# Alternatively, you could build a binary and run it:
# RUN go build -o /app/your_app_name .
# CMD ["/app/your_app_name"]
