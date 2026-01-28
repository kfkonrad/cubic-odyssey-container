FROM ghcr.io/ptero-eggs/yolks:wine_latest

LABEL maintainer="Based on Pterodactyl egg by ptero@redbananaofficial.com"
LABEL description="Cubic Odyssey Dedicated Server"

RUN useradd -m -d /home/container -s /bin/bash container

WORKDIR /home/container

RUN mkdir -p /home/container/.steam/sdk32 \
    /home/container/.steam/sdk64 \
    /home/container/steamcmd \
    /home/container/steamapps \
    /home/container/cubic-odyssey \
    && chown -R container:container /home/container

COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER container

RUN cd /home/container/steamcmd && \
    curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xzvf steamcmd.tar.gz && \
    rm steamcmd.tar.gz && \
    ./steamcmd.sh +quit && \
    ln -s /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so && \
    ln -s /home/container/steamcmd/linux64/steamclient.so /home/container/.steam/sdk64/steamclient.so

ENV HOME=/home/container

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
