FROM golang:1.23-alpine@sha256:c694a4d291a13a9f9d94933395673494fc2cc9d4777b85df3a7e70b3492d3574 AS kopia

RUN CGO_ENABLED=0 go install github.com/kopia/kopia@v0.18.0

FROM alpine:3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a

RUN apk add --no-cache bash github-cli

COPY --from=kopia /go/bin/kopia /usr/bin/kopia

COPY backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh

CMD ["./app/backup.sh"]
