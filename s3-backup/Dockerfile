FROM golang:1.24-alpine@sha256:7772cb5322baa875edd74705556d08f0eeca7b9c4b5367754ce3f2f00041ccee AS goinstaller

RUN CGO_ENABLED=0 go install github.com/bradenrayhorn/marmalade/cmd/marmalade@v0.3.0

FROM alpine:3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a

RUN apk add --no-cache bash tar xz aws-cli

COPY --from=goinstaller /go/bin/marmalade /usr/bin/marmalade

COPY backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh

CMD ["./app/backup.sh"]
