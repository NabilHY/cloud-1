COMPOSE = docker compose -f srcs/docker-compose.yml

.PHONY: build up down clean restart logs ps psa status

build:
	@echo "Creating Local Volumes ..."
	mkdir -p /home/nhayoun/data/db > /dev/null 2>&1 || true
	mkdir -p /home/nhayoun/data/wp > /dev/null 2>&1 || true
	mkdir -p /home/nhayoun/data/static > /dev/null 2>&1 || true
	mkdir -p /home/nhayoun/data/portainer > /dev/null 2>&1 || true
	@echo "🔧 Building Docker images..."
	@$(COMPOSE) build mariadb nginx wordpress adminer static_site portainer redis ftp
	@echo "✅ Build completed."

up:
	@echo "🚀 Starting containers in background..."
	@$(COMPOSE) up -d --build
	@$(COMPOSE) ps

down:
	@echo "🛑 Stopping and removing containers, networks..."
	@$(COMPOSE) down -v --remove-orphans

clean:
	@echo "🔥 Full cleanup: containers, volumes, and orphans..."
	@$(COMPOSE) down -v --remove-orphans

restart:
	@echo "🔄 Restarting environment..."
	@$(MAKE) down
	@$(MAKE) up

logs:
	@echo "📜 Tailing logs (press Ctrl+C to stop)..."
	@$(COMPOSE) logs -f

ps:
	@$(COMPOSE) ps

psa:
	@$(COMPOSE) ps -a

status:
	@echo "📊 Current Docker status:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

re:
	@echo "🔄 Rebuilding and restarting environment..."
	@$(MAKE) nuke
	@$(MAKE) down
	@$(MAKE) build
	@$(MAKE) restart
	@echo "✅ Environment rebuilt and restarted."

nuke:
	@echo "💣 Nuke all containers, images, and volumes..."
	@docker system prune -a --volumes -f
	@echo "✅ Nuke completed."