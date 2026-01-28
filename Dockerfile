FROM ghcr.io/ptero-eggs/yolks:wine_latest

LABEL maintainer="Based on Pterodactyl egg by ptero@redbananaofficial.com"
LABEL description="Cubic Odyssey Dedicated Server"

# Set working directory
WORKDIR /home/container

# Create necessary directories
RUN mkdir -p /home/container/.steam/sdk32 \
    /home/container/.steam/sdk64 \
    /home/container/steamcmd \
    /home/container/steamapps

# Install SteamCMD and bootstrap it to get steamclient.so files
RUN cd /home/container/steamcmd && \
    curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xzvf steamcmd.tar.gz && \
    rm steamcmd.tar.gz && \
    ./steamcmd.sh +quit && \
    ln -s /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so && \
    ln -s /home/container/steamcmd/linux64/steamclient.so /home/container/.steam/sdk64/steamclient.so

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment
ENV HOME=/home/container

# Expose game port (default 20000)
EXPOSE 20000/udp

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
