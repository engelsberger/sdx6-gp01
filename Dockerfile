# Go binary
FROM golang:1.24-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git=2.43.0-r0

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o sdx-service .

# Runtime image
FROM alpine:3.19

WORKDIR /app

COPY ca-certificates-20240226-r0.apk /tmp/
RUN apk add --no-cache /tmp/ca-certificates-20240226-r0.apk

COPY --from=builder /app/sdx-service .

EXPOSE 8080
CMD ["./sdx-service", "serve"]
