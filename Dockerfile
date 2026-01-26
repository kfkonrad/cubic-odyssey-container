FROM ghcr.io/ptero-eggs/yolks:wine_latest

LABEL maintainer="Based on Pterodactyl egg by ptero@redbananaofficial.com"
LABEL description="Cubic Odyssey Dedicated Server"

# Set working directory
WORKDIR /home/container

# Install additional dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    lib32gcc-s1 \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /home/container/.steam/sdk32 \
    /home/container/.steam/sdk64 \
    /home/container/steamcmd \
    /home/container/steamapps

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment
ENV HOME=/home/container

# Expose game port (default 20000)
EXPOSE 20000/udp

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
