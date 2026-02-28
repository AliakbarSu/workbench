# Workbench

A containerised development environment for running [Claude Code](https://github.com/anthropics/claude-code) with a locked-down network firewall. Projects from the host machine are mounted into the container so Claude can work on them in isolation.

## What's inside

- **Node 20** with pnpm, plus **Python** via uv
- **Claude Code** (latest)
- **Atlas** (database migrations), **Google Cloud SDK**, **gh** CLI
- **zsh** with Powerlevel10k, autosuggestions, syntax highlighting, and fzf
- **iptables/ipset** firewall that restricts outbound traffic to an allowlist

## Setup

1. Copy the mounts config and edit it to point at your local project directories:

   ```sh
   cp config/mounts.example.yaml config/mounts.yaml
   ```

2. Open `config/mounts.yaml` and add the paths you want mounted:

   ```yaml
   paths:
     - /Users/you/repos/my-project
   ```

## Usage

```sh
make shell
```

This builds the Docker image if it doesn't exist, starts the container (or attaches to an existing one), and drops you into a zsh session. Your projects are mounted under `/projects/<directory-name>`.

## Configuration

| File | Purpose |
|------|---------|
| `config/mounts.yaml` | Host paths to mount into the container (gitignored) |
| `config/mounts.example.yaml` | Template for `mounts.yaml` |
| `config/firewall.yaml` | Domains the container is allowed to reach |
| `terminal-config/.zshrc` | zsh config copied into the container on each start |

### Firewall

The container runs with a strict outbound allowlist managed by `scripts/init-firewall.sh`. GitHub IP ranges are fetched dynamically from the GitHub API; all other allowed hosts are listed in `config/firewall.yaml`. To permit additional domains, add them there and rebuild the image.

## Directory structure

```
workbench/
├── Dockerfile
├── Makefile
├── config/
│   ├── firewall.yaml          # outbound network allowlist
│   ├── mounts.yaml            # your local project paths (gitignored)
│   └── mounts.example.yaml
├── scripts/
│   ├── shell.sh               # start/attach to the container
│   └── init-firewall.sh       # configure iptables inside the container
└── terminal-config/
    └── .zshrc
```
