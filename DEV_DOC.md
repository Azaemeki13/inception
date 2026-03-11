# Developer Documentation

## Prerequisites

| Requirement | Install |
|---|---|
| Docker | `sudo apt-get install docker.io` |
| Docker Compose | `sudo apt-get install docker-compose-plugin` |
| Make | `sudo apt-get install make` |
| User in docker group | `sudo usermod -aG docker $USER` (then re-login) |

---

## Environment Setup From Scratch

### 1. Clone the repository

```bash
git clone <repo-url> ginception
cd ginception
```

### 2. Create the `.env` file

This file is **not tracked by git**. You must create it manually:

```bash
nano srcs/.env
```

Required variables:

```env
LOGIN=cauffret
DOMAIN_NAME=cauffret.42.fr

# MariaDB
SQL_DATABASE=wordpress
SQL_USER=wpuser
SQL_PASSWORD=<your_password>
SQL_ROOT_PASSWORD=<your_root_password>

# WordPress Admin (username must NOT contain "admin")
WP_ADMIN_USER=cauffret
WP_ADMIN_PASSWORD=<your_password>
WP_ADMIN_EMAIL=cauffret@student.42.fr

# WordPress Regular User
WP_USER=editor
WP_USER_PASSWORD=<your_password>
WP_USER_EMAIL=editor@student.42.fr
```

### 3. Create the data directories

```bash
sudo mkdir -p /home/cauffret/data/mariadb
sudo mkdir -p /home/cauffret/data/wordpress
```

### 4. Add domain to hosts

```bash
echo "127.0.0.1 cauffret.42.fr" | sudo tee -a /etc/hosts
```

---

## Build and Launch

### Makefile targets

| Command | What it does |
|---|---|
| `make` | Builds all images and starts containers in detached mode |
| `make down` | Stops and removes containers |
| `make clean` | Stops containers, removes images and volumes |
| `make fclean` | `clean` + prunes Docker system + deletes data directories |
| `make re` | Full rebuild from scratch (`fclean` + `make`) |

### What `make` runs

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

- `-f srcs/docker-compose.yml` — path to compose file
- `up` — create and start containers
- `-d` — detached mode (background)
- `--build` — rebuild images before starting

---

## Project Structure

```
ginception/
├── Makefile                        # Entry point — build/start/stop/clean
├── srcs/
│   ├── .env                        # Credentials (NOT in git)
│   ├── docker-compose.yml          # Service orchestration
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile          # MariaDB image definition
│       │   ├── conf/
│       │   │   └── server-50.cnf   # MariaDB server configuration
│       │   └── tools/
│       │       └── setup.sh        # DB initialization script
│       ├── wordpress/
│       │   ├── Dockerfile          # WordPress image definition
│       │   ├── conf/
│       │   │   └── www.conf        # PHP-FPM pool configuration
│       │   └── tools/
│       │       └── setup.sh        # WordPress installation script
│       └── nginx/
│           ├── Dockerfile          # NGINX image definition
│           └── conf/
│               └── nginx.conf      # NGINX server configuration
```

---

## Container Management

### Status

```bash
# List running containers
docker compose -f srcs/docker-compose.yml ps

# Check a specific container
docker inspect mariadb
docker inspect wordpress
docker inspect nginx
```

### Logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs

# Single service (follow mode)
docker compose -f srcs/docker-compose.yml logs -f mariadb

# Last 50 lines
docker compose -f srcs/docker-compose.yml logs --tail 50 wordpress
```

### Shell access

```bash
# Enter a container
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# Run a single command
docker exec mariadb mariadb -u wpuser -p<password> -e "SHOW TABLES FROM wordpress;"
```

### Restart a single service

```bash
docker compose -f srcs/docker-compose.yml restart nginx
```

---

## Volume Management

### Named volumes

| Volume | Host path | Container path | Contains |
|---|---|---|---|
| `mariadb` | `/home/cauffret/data/mariadb` | `/var/lib/mysql` | Database files (users, posts, settings) |
| `wordpress` | `/home/cauffret/data/wordpress` | `/var/www/html` | WordPress PHP files, themes, uploads |

The WordPress volume is shared between the **WordPress** and **NGINX** containers.

### Inspect volumes

```bash
# List all named volumes
docker volume ls

# Inspect a volume (shows host path)
docker volume inspect mariadb
docker volume inspect wordpress

# Check data on host
ls -la /home/cauffret/data/mariadb/
ls -la /home/cauffret/data/wordpress/
```

### Data persistence

| Scenario | Data |
|---|---|
| `make down` then `make` | Data persists — containers recreated, volumes intact |
| `make clean` | Data lost — volumes removed |
| `make fclean` | Data lost — volumes removed + host directories cleared |
| Reboot host machine | Data persists — volumes are on disk |

### Delete volumes manually

```bash
# Remove a specific volume
docker volume rm mariadb
docker volume rm wordpress

# Remove all unused volumes
docker volume prune
```

---

## Network

All services communicate over a private Docker bridge network (`app_network`):

### Inspect network

```bash
docker network ls
docker network inspect srcs_app_network
```

### Key points

- Only **port 443** is exposed to the host (NGINX)
- WordPress and MariaDB are **not accessible** from outside
- Containers resolve each other **by name** (Docker DNS)
- `network: host` and `--link` are **not used**

---

## Common Issues

| Problem | Solution |
|---|---|
| `make` fails — permission denied | Add user to docker group: `sudo usermod -aG docker $USER` and re-login |
| Container keeps restarting | Check logs: `docker compose -f srcs/docker-compose.yml logs <service>` |
| Can't access `https://cauffret.42.fr` | Verify `/etc/hosts` contains `127.0.0.1 cauffret.42.fr` |
| Browser shows SSL warning | Expected — self-signed certificate. Click Advanced → Proceed |
| WordPress shows install wizard | Volumes were cleared — database is empty. This is normal on first run |
| MariaDB won't start | Check if data directory exists: `ls /home/cauffret/data/mariadb/` |
| Port 443 already in use | Stop the conflicting service: `sudo lsof -i :443` then kill it |