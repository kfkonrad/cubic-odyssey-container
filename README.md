# Cubic Odyssey Dedicated Server - Docker

Docker setup for running a Cubic Odyssey dedicated server in a container. This configuration is based on the official Pterodactyl egg and uses Wine to run the Windows server executable on Linux.

## Prerequisites

- Docker and Docker Compose installed on your system
- At least 4GB of RAM available for the container
- Sufficient disk space for the server files (approximately 2-3GB)

Note: Cubic Odyssey supports anonymous Steam downloads, so no Steam account is required!

## Quick Start

### 1. Clone or Download This Repository

```bash
cd cubic-egg
```

### 2. Configure Your Server

Copy the example environment file and edit it with your settings:

```bash
cp .env.example .env
nano .env  # or use your preferred editor
```

Configure server settings like server name, port, max players, etc. Steam credentials are optional - anonymous download is supported by default.

### 3. Build and Start the Server

```bash
docker-compose up -d
```

The first startup will download and install the server files via SteamCMD. This may take several minutes depending on your connection.

### 4. Monitor the Server

View server logs:
```bash
docker-compose logs -f
```

The server is ready when you see:
```
Lobbies (OnCreateLobbyFinished): lobby created.
```

## Configuration Options

All configuration is done through the `.env` file. See `.env.example` for all available options.

### Steam Credentials (OPTIONAL)

Anonymous download is supported. Leave empty to use anonymous login.

| Variable | Description | Default |
|----------|-------------|---------|
| `STEAM_USER` | Your Steam username (optional) | anonymous |
| `STEAM_PASS` | Your Steam password (optional) | - |
| `STEAM_AUTH` | Steam Guard code (if enabled) | - |

### Server Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `SERVER_NAME` | Server name in browser | Cubic Odyssey Server |
| `SERVER_PASSWORD` | Password to join (empty = no password) | - |
| `GAME_PORT` | Server port | 20000 |
| `MAX_PLAYERS` | Maximum players allowed | 20 |
| `GAMEMODE` | Game mode (adventure or creative) | adventure |
| `PRIVATE_SERVER` | Hide from server list (TRUE/FALSE) | FALSE |
| `GALAXY_SEED` | Galaxy generation seed | 21945875634 |
| `AUTO_UPDATE` | Auto-update on restart (1/0) | 1 |

## Port Forwarding

If you want players outside your local network to join, you need to forward the game port (default: 20000/UDP) through your router.

Default port: **20000/UDP**

## Management Commands

### Start the server
```bash
docker-compose up -d
```

### Stop the server
```bash
docker-compose down
```

### Restart the server
```bash
docker-compose restart
```

### View logs
```bash
docker-compose logs -f
```

### Update server files
The server will automatically update on restart if `AUTO_UPDATE=1` is set in your `.env` file.

To manually force an update:
```bash
docker-compose restart
```

### Access server console
```bash
docker-compose exec cubic-odyssey bash
```

## File Structure

```
cubic-egg/
├── Dockerfile              # Container image definition
├── docker-compose.yml      # Service orchestration
├── entrypoint.sh          # Startup script
├── .env.example           # Configuration template
├── .env                   # Your configuration (create this)
├── cubic-odyssey.json     # Original Pterodactyl egg
└── server_data/           # Server files (created on first run)
    ├── server/            # Game server binaries
    ├── config/            # Configuration files
    └── steamcmd/          # SteamCMD installation
```

## Troubleshooting

### Server won't start

1. Check logs for errors: `docker-compose logs`
2. Verify ports are not already in use: `netstat -tulpn | grep 20000`
3. If using Steam credentials, ensure they are correct in the `.env` file
4. Try using anonymous download by leaving STEAM_USER and STEAM_PASS empty

### Installation fails

1. If using Steam credentials, Steam Guard may have expired your auth code - generate a new one and update `STEAM_AUTH`
2. Try anonymous download by removing STEAM_USER and STEAM_PASS from `.env`
3. Check your internet connection
4. Ensure you have enough disk space

### Can't connect to server

1. Verify the server is running: `docker-compose ps`
2. Check if the port is properly exposed: `docker-compose port cubic-odyssey 20000`
3. Ensure port forwarding is configured on your router
4. Verify firewall settings allow UDP traffic on the game port

### Performance issues

Adjust resource limits in `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      memory: 8G  # Increase if needed
    reservations:
      memory: 4G
```

Then restart: `docker-compose down && docker-compose up -d`

## Advanced Configuration

### Custom Server Configuration

After the first run, you can manually edit server configuration files in `server_data/config/server_config.txt`.

Note: Some settings may be overwritten on restart if set in environment variables.

### Backup Your Server

To backup your server data:
```bash
tar -czf cubic-odyssey-backup-$(date +%Y%m%d).tar.gz server_data/
```

To restore:
```bash
tar -xzf cubic-odyssey-backup-YYYYMMDD.tar.gz
```

## Security Notes

- Never commit your `.env` file with real credentials to version control
- Use strong passwords for both Steam and server passwords
- Consider using `PRIVATE_SERVER=TRUE` if you want invite-only
- Keep your server updated by enabling `AUTO_UPDATE=1`

## Credits

Based on the Pterodactyl egg created by ptero@redbananaofficial.com

Game: Cubic Odyssey - An open-world adventure game where you explore vibrant planets, craft tools, build vehicles, and fight the Red Darkness.

## License

This Docker configuration is provided as-is for running Cubic Odyssey dedicated servers. The game and server software are owned by their respective copyright holders.
