# HOME SERVER

This home server setup provides a collection of self-hosted services for media streaming, authentication, and emulation. It uses **Docker Compose** to manage and deploy the services efficiently.

## SERVICES

### TRAEFIK 🚦

- **[Traefik](https://traefik.io/)**: Reverse proxy with SSL support for managing and securing your web services.

### DOCKER 🐳

- **[Docker socket proxy](https://docs.linuxserver.io/images/docker-socket-proxy/)**: Security-enhanced proxy which allows you to apply access rules to the Docker socket

### AUTH 🔐

- **[Authentik](https://goauthentik.io/)**: IdP (Identity Provider) and SSO (single sign on)

## PREREQUISITES

- **Docker** & **Docker Compose**
- **GNU Make**
- **Bash**

## SETUP

1.  **Clone the repository**

    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2.  **Initialize environment files**

    ```bash
    make env
    ```

    _Note: Edit the generated `.env` files in `docker/_/` before proceeding.\*

3.  **Deploy services**
    ```bash
    make up
    ```
    _This automatically creates the required networks and starts all stacks in order._


## COMMANDS

- `make up`: Start all stacks and create networks.
- `make down`: Stop all stacks.
- `make restart`: Restart all stacks.
- `make pull`: Pull latest images.
- `make ps`: Show status of all containers.
- `make logs`: Tail logs for all containers.
- `make env`: Initialize `.env` files from examples.
- `make clean`: Stop all and remove networks.

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
