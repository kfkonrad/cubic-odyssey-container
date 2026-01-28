# cubic-odyssey-container

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

Run the Cubic Odyssey dedicated server in a container

This repo provides a Dockerfile and compose file inspired by the Pterodactyl egg for Cubic Odyssey. The game server is
fully configurable via a `.env` file, runs as a non-root user and includes an optional automatic update mechanism.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Install

To build the container image you can run the following command:

```sh
docker compose build
```

If you want to customize your server (difficulty settings, server name, password, etc.) you can copy the `.env.example`
to `.env` and adjust as you wish. Your settings will be loaded and respected automatically. See comments in
`.env.example` for available options.

## Usage

```sh
docker compose up -d
```

The container will install the Cubic Odyssey Server on the initial run (and update it if `AUTO_UPDATE` is set to `1` in
your `.env`). This may take a couple of minutes depending on your internet connection.

The game server is ready once you see the following line in the `docker compose logs`:

```
Lobbies (OnCreateLobbyFinished): lobby created.
```

## Maintainers

[@kfkonrad](https://github.com/kfkonrad)

## Contributing

PRs accepted.

Small note: If editing the README, please conform to the
[standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

MIT © 2026 Kevin F. Konrad
