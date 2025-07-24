FROM golang:1.24-alpine@sha256:7772cb5322baa875edd74705556d08f0eeca7b9c4b5367754ce3f2f00041ccee AS goinstaller

RUN CGO_ENABLED=0 go install github.com/bradenrayhorn/pickle/cmd/pickle@v0.20250723.0

FROM alpine:3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a

RUN apk add --no-cache bash

COPY --from=goinstaller /go/bin/pickle /usr/bin/pickle

CMD ["pickle"]
