
build:
	docker build -t s3-backup:local .

run:
	docker run --rm --name s3-backup --env-file .env s3-backup:local
