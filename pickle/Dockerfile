FROM golang:1.24-alpine@sha256:daae04ebad0c21149979cd8e9db38f565ecefd8547cf4a591240dc1972cf1399 AS goinstaller

RUN CGO_ENABLED=0 go install github.com/bradenrayhorn/pickle/cmd/pickle@v1.2508.0

FROM alpine:3@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

RUN apk add --no-cache bash

COPY --from=goinstaller /go/bin/pickle /usr/bin/pickle

CMD ["pickle"]
