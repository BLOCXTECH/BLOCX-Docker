ARG UBUNTUVER=20.04
FROM ubuntu:${UBUNTUVER}
LABEL com.centurylinklabs.watchtower.enable="true"
ARG BLOCX_VERSION="3.1.2-beta.1"
RUN mkdir -p /root/.blocx
RUN mkdir -p /var/log/supervisor
RUN apt-get update && apt-get install -y  tar wget curl pwgen jq supervisor cron git python3-virtualenv nano
RUN wget https://github.com/BLOCXTECH/BLOCX/releases/download/v${BLOCX_VERSION}/BLOCX-Ubuntu-Daemon-v${BLOCX_VERSION}.tar.gz -P /tmp && \
    tar -xvf /tmp/BLOCX-Ubuntu-Daemon-v${BLOCX_VERSION}.tar.gz -C /usr/local/bin && \
    rm /tmp/BLOCX-Ubuntu-Daemon-v${BLOCX_VERSION}.tar.gz
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY node_initialize.sh /node_initialize.sh
COPY check-health.sh /check-health.sh
COPY sentinel.sh /sentinel.sh
COPY key.sh /key.sh
VOLUME /root/.blocx
RUN chmod 755 node_initialize.sh check-health.sh sentinel.sh key.sh
EXPOSE 9999
EXPOSE 12972
HEALTHCHECK --start-period=5m --interval=2m --retries=5 --timeout=15s CMD ./check-health.sh
ENTRYPOINT ["/usr/bin/supervisord"]
