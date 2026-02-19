# Variables
NAME = inception
SRCS_DIR = ./srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml

# Default rule: create directories and launch containers
all:
	@mkdir -p /home/cauffret/data/mariadb
	@mkdir -p /home/cauffret/data/wordpress
	@docker compose -f $(COMPOSE_FILE) up --build

# Stop and remove containers, networks
down:
	@docker compose -f $(COMPOSE_FILE) down

# Full cleanup: stop containers and remove volumes/data
fclean: down
	@docker system prune -a --volumes -f
	@sudo rm -rf /home/cauffret/data

re: fclean all

.PHONY: all down fclean re
