
build:
	docker build -t actualbudget-backup:local .

run:
	docker run --rm --name actualbudget-backup --env-file .env -v ./example-dir:/app/data actualbudget-backup:local
