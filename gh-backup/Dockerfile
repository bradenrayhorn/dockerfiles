FROM golang:1.24-alpine@sha256:daae04ebad0c21149979cd8e9db38f565ecefd8547cf4a591240dc1972cf1399 AS goinstaller

RUN CGO_ENABLED=0 go install github.com/bradenrayhorn/marmalade/cmd/marmalade@v1.2508.4

FROM alpine:3@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

RUN apk add --no-cache bash github-cli tar xz

COPY --from=goinstaller /go/bin/marmalade /usr/bin/marmalade

COPY backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh

CMD ["./app/backup.sh"]
