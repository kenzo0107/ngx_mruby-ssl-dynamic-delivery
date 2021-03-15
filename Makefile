build:
	docker-compose build nginx
.PHONY: build

restart:
	docker-compose down
	docker-compose up -d
.PHONY: restart

ps:
	docker-compose ps
.PHONY: ps

logs:
	docker-compose logs -f
.PHONY: logs

retry: build restart ps logs
.PHONY: retry
