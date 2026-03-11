# User Documentation

## Services Overview

This project runs a **WordPress website** using three Docker containers:

| Service | Role | Port |
|---|---|---|
| **NGINX** | Web server — handles HTTPS and serves static files | 443 (exposed) |
| **WordPress + PHP-FPM** | Web application — processes PHP | 9000 (internal only) |
| **MariaDB** | Database — stores users, posts, settings | 3306 (internal only) |

Only NGINX is accessible from outside. WordPress and MariaDB communicate internally through a private Docker network.

---

## Start and Stop

### Prerequisites

- Docker and Docker Compose installed
- `/etc/hosts` contains: `127.0.0.1 cauffret.42.fr`

### Commands

| Action | Command |
|---|---|
| Build and start | `make` |
| Stop containers | `make down` |
| Stop and remove images/volumes | `make clean` |
| Full reset (removes all data) | `make fclean` |
| Rebuild from scratch | `make re` |

---

## Access the Website

| What | URL |
|---|---|
| Website | `https://cauffret.42.fr` |
| Admin panel | `https://cauffret.42.fr/wp-admin/` |

> ⚠️ Your browser will show a security warning because the SSL certificate is self-signed. Click **Advanced** **Proceed** to continue.

---

## Credentials

All credentials are stored in `srcs/.env`. This file is **not tracked by git**.

| Variable | Description |
|---|---|
| `SQL_DATABASE` | WordPress database name |
| `SQL_USER` | Database user for WordPress |
| `SQL_PASSWORD` | Database user password |
| `SQL_ROOT_PASSWORD` | MariaDB root password |
| `WP_ADMIN_USER` | WordPress admin username |
| `WP_ADMIN_PASSWORD` | WordPress admin password |
| `WP_ADMIN_EMAIL` | WordPress admin email |
| `WP_USER` | WordPress regular user |
| `WP_USER_PASSWORD` | WordPress regular user password |
| `WP_USER_EMAIL` | WordPress regular user email |

### To view credentials:

```bash
cat srcs/.env
```

### To change credentials:

1. Edit `srcs/.env`
2. Run `make fclean` (full reset required — database must be recreated)
3. Run `make`

---

## Check Services

### Are the containers running?

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three should show `Up`:

```
NAME        STATUS
mariadb     Up
wordpress   Up
nginx       Up
```

### View logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs

# Specific service
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx
```

### Test HTTPS

```bash
curl -k https://cauffret.42.fr
```

Should return HTML content (the WordPress page).

### Test database connection

```bash
docker exec mariadb mariadb -u $SQL_USER -p$SQL_PASSWORD -e "SHOW DATABASES;"
```

Should list the WordPress database.

### Check volumes

```bash
# List named volumes
docker volume ls

# Verify data path
docker volume inspect mariadb
docker volume inspect wordpress
```

Both should show the path `/home/cauffret/data/` in the output.

### Check network

```bash
docker network ls
docker network inspect srcs_app_network
```

Should show all three containers connected to the same network.