# Tools

Install a fresh Laravel App with a flavor
```
docker run --rm \
    --pull=always \
    -v "$(pwd)":/opt \
    -w /opt \
    finuras/sidecar install example-app
```
