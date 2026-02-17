# Agent Context

Docker Compose homelab managed via Make.

## Commands

```bash
make env         # Initialize .env files
make networks    # Create external networks
make up          # Start all stacks
make down        # Stop all stacks
make ps          # Status of all services
make logs        # Tail all logs
make clean       # Stop and remove networks
make nuke        # Clean + prune Docker
```

## Per-Stack

```bash
make up-<stack>    # Start one stack
make down-<stack>  # Stop one stack
make logs-<stack>  # Tail stack logs
```

## Structure

Each stack in `docker/<stack>/` has:

- `docker-compose.yml`
- `.env.example` (template)
- `.env` (ignored, created by `make env`)

Boot order is defined left-to-right in Makefile `STACKS` variable.
