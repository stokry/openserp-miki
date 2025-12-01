# Builder stage
FROM golang:1.26-alpine AS builder
LABEL stage=gobuilder

RUN apk update --no-cache && apk add --no-cache tzdata

WORKDIR /app

# Copy mod files first for caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source
COPY . .

# Build the binary
RUN go build -o openserp .

# Final stage
FROM zenika/alpine-chrome:with-chromedriver

WORKDIR /usr/src/app

# Copy config and binary
COPY config.yaml .
COPY --from=builder /app/openserp /usr/local/bin/openserp

# Expose port if needed (Railway sets PORT env)
EXPOSE 8080

# Start the server
ENTRYPOINT ["openserp", "serve"]
