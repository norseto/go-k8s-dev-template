FROM golang:1.14-alpine as build

WORKDIR /src/hello-world

# Install dependencies in go.mod and go.sum
COPY go.mod go.sum ./
RUN go mod download

# Copy rest of the application source code
COPY . ./

# Compile the application to /app.
# Add lint, tests for production.
RUN go build -o /app -v ./cmd/hello-world

FROM alpine as release
COPY --from=build /app /app
ENTRYPOINT ["/app"]
