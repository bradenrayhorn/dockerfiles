FROM alpine:3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a

RUN apk add --no-cache bash python3 py3-pip jq age expect

# create python virtual env
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

RUN pip3 install b2

COPY backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh

CMD ["./app/backup.sh"]
