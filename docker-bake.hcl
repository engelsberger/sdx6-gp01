group "default" {
  targets = ["sdx-service"]
}

target "sdx-service" {
  context    = "."
  dockerfile = "Dockerfile"

  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]

  tags = [
    "src-app:latest"
  ]
}