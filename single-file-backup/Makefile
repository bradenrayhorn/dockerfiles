
build:
	docker build -t single-file-backup:local .

run:
	docker run --rm --name single-file-backup --env-file .env -v ./example-dir:/data/backups single-file-backup:local
