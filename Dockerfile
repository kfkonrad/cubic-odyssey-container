FROM ghcr.io/ptero-eggs/yolks:wine_latest

LABEL maintainer="Based on Pterodactyl egg by ptero@redbananaofficial.com"
LABEL description="Cubic Odyssey Dedicated Server"

# Create non-root user
RUN useradd -m -d /home/container -s /bin/bash container

# Set working directory
WORKDIR /home/container

# Create necessary directories
RUN mkdir -p /home/container/.steam/sdk32 \
    /home/container/.steam/sdk64 \
    /home/container/steamcmd \
    /home/container/steamapps \
    /home/container/cubic-odyssey \
    && chown -R container:container /home/container

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Switch to non-root user for SteamCMD and runtime
USER container

# Install SteamCMD and bootstrap it to get steamclient.so files
RUN cd /home/container/steamcmd && \
    curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xzvf steamcmd.tar.gz && \
    rm steamcmd.tar.gz && \
    ./steamcmd.sh +quit && \
    ln -s /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so && \
    ln -s /home/container/steamcmd/linux64/steamclient.so /home/container/.steam/sdk64/steamclient.so

# Set environment
ENV HOME=/home/container

# Expose game port (default 20000)
EXPOSE 20000/udp

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
