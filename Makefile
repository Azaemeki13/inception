NAME		= inception
COMPOSE		= docker compose -f srcs/docker-compose.yml
LOGIN		= cauffret
DATA_DIR	= /home/$(LOGIN)/data

all:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@$(COMPOSE) up --build -d

down:
	@$(COMPOSE) down

clean: down
	@docker system prune -a --volumes -f

fclean: clean
	@sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all down clean fclean re
