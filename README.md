# HOME SERVER

This home server setup provides a collection of self-hosted services for media streaming, authentication, and emulation. It uses **Docker Compose** to manage and deploy the services efficiently.

<br>

## SERVICES

| Category | Service | Description |
|----------|---------|-------------|
| **Reverse Proxy** | [Traefik](https://traefik.io/) | Reverse proxy with SSL support |
| | [Crowdsec](https://www.crowdsec.net/) | Security engine with Traefik bouncer |
| **Docker Utils** | [Socket Proxy](https://docs.linuxserver.io/images/docker-socket-proxy/) | Secure Docker socket access |
| | [Watchtower](https://containrrr.dev/watchtower/) | Container update monitoring |
| **Auth** | [Authentik](https://goauthentik.io/) | Identity provider & SSO |
| **Cloud** | [Immich](https://immich.app/) | Photo/video backup solution |
| | [Filebrowser](https://filebrowser.org/) | Web file manager |
| **DevTools** | [Opencode](https://opencode.ai/) | AI development environment |
| | [Obsidian Live Sync](https://github.com/vrtmrz/obsidian-livesync) | CouchDB sync for Obsidian |
| **Monitoring** | [Uptime Kuma](https://uptime.kuma.pet/) | Service uptime monitoring |
| | [Goaccess](https://goaccess.io/) | Real-time web log analyzer |
| **Streaming** | [Jellyfin](https://jellyfin.org/) | Media server |
| | [Seerr](https://github.com/seerr-team/seerr) | Media discovery & recommendations |
| | [Prowlarr](https://prowlarr.com/) | Index manager |
| | [Sonarr](https://sonarr.tv/) | TV series management |
| | [Radarr](https://radarr.video/) | Movie management |
| | [Flaresolverr](https://github.com/FlareSolverr/FlareSolverr) | Cloudflare bypass proxy |
| | [Byparr](https://github.com/ThePhaseless/Byparr) | DDoS-Guard bypass proxy |
| **Downloads** | [qBittorrent](https://www.qbittorrent.org/) | Torrent client |
| **VPN** | [Gluetun](https://github.com/qdm12/gluetun) | VPN client |
| **Backups** | [Docker Volume Backup](https://offen.github.io/docker-volume-backup/) | Automated volume backups |

## QUICK START

0. **Prerequisites**:
    - Docker & Docker Compose
    - GNU Make
    - Bash

1. **Clone the repository**

    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2. **Initialize environment files**

    ```bash
    make env
    ```

    > **Note:** Edit the generated `.env` files in `docker/_/` before proceeding.\*

3. **Deploy services**
    ```bash
    make up
    ```
    > This automatically creates the required networks and starts all stacks in order.\_

<br>

## COMMANDS

### Global Commands

| Command         | Description                           |
| :-------------- | :------------------------------------ |
| `make up`       | Start all stacks in boot order        |
| `make down`     | Stop all stacks in reverse order      |
| `make restart`  | Restart all stacks                    |
| `make ps`       | Show status of all services           |
| `make logs`     | Tail logs for all services            |
| `make pull`     | Pull latest images                    |
| `make env`      | Initialize `.env` files from examples |
| `make networks` | Create external Docker networks       |
| `make clean`    | Stop stacks and remove networks       |
| `make nuke`     | Clean + prune all Docker resources    |

### Per-Stack Commands

| Command                | Description                    |
| :--------------------- | :----------------------------- |
| `make up-<stack>`      | Start specific stack           |
| `make down-<stack>`    | Stop specific stack            |
| `make restart-<stack>` | Restart specific stack         |
| `make logs-<stack>`    | Tail logs for specific stack   |
| `make ps-<stack>`      | Show status of specific stack  |
| `make pull-<stack>`    | Pull images for specific stack |

> **Note:** For individual service management within a stack, use `docker compose` directly.

<br>
<br>

---

### Disclaimer ❗️

**Responsibility**: By using this setup, you acknowledge and agree that you are solely responsible for:

- Ensuring compliance with all applicable laws and regulations, including copyright laws.
- Configuring and securing your services to prevent unauthorized access.
- Managing and backing up your data.

**No Warranty**: This setup is provided as-is, without any warranty. The maintainers are not responsible for any data loss, security breaches, or legal issues that may arise from its use.

Use this setup responsibly and at your own risk.
