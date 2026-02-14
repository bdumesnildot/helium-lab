# HOME SERVER

This home server setup provides a collection of self-hosted services for media streaming, authentication, and emulation. It uses **Docker Compose** to manage and deploy the services efficiently.

<br>

## SERVICES

#### 🚦 Reverse Proxy and SSL

- **[Traefik](https://traefik.io/)**: Reverse proxy with SSL support for managing and securing your web services.

#### 🧰 Security & Utils

- **[Docker socket proxy](https://docs.linuxserver.io/images/docker-socket-proxy/)**: Security-enhanced proxy which allows you to apply access rules to the Docker socket
- **[Gluetun](https://github.com/qdm12/gluetun)**: VPN client for routing traffic through a secure tunnel.

#### 🔐 Authentication

- **[Authentik](https://goauthentik.io/)**: IdP (Identity Provider) and SSO (single sign on), solution for managing user access to your services.

#### 📥 Downloads

- **[qBittorrent](https://www.qbittorrent.org/)**: A powerful and user-friendly torrent client.
- **[nzbget](https://nzbget.net/)**: A binary newsreader for downloading files from Usenet.

<br>

## QUICK START

<br>

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
