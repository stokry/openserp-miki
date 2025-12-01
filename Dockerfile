# Builder stage
FROM golang:1.25-alpine AS builder
LABEL stage=gobuilder

RUN apk update --no-cache && apk add --no-cache tzdata

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o openserp .

# Final stage
FROM zenika/alpine-chrome:with-chromedriver
WORKDIR /usr/src/app

COPY config.yaml .
COPY --from=builder /app/openserp /usr/local/bin/openserp

EXPOSE 8080
ENTRYPOINT ["openserp", "serve"]
