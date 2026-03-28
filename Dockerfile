# Go binary
FROM golang:1.26-alpine AS builder


WORKDIR /app

RUN apk add --no-cache git=2.52.0-r0

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o sdx-service .

# Runtime image
FROM alpine:3.21

WORKDIR /app

RUN apk add --no-cache ca-certificates=20250911-r0

COPY --from=builder /app/sdx-service .

EXPOSE 8080
CMD ["./sdx-service", "serve"]
