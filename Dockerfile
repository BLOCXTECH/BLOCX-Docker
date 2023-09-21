ARG UBUNTUVER=20.04
FROM ubuntu:${UBUNTUVER}
LABEL com.centurylinklabs.watchtower.enable="true"

RUN mkdir -p /root/.blocx
RUN mkdir -p /var/log/supervisor
RUN apt-get update && apt-get install -y  tar wget curl pwgen jq supervisor cron git python3-virtualenv
RUN wget https://github.com/BLOCXTECH/BLOCX/releases/download/v2.1.0/BLOCX-2.1.0-ubuntu-daemon.tar.gz -P /tmp
RUN wget -O /tmp/BLOCX-2.1.0-ubuntu-daemon.tar.gz https://github.com/BLOCXTECH/BLOCX/releases/download/v2.1.0/BLOCX-2.1.0-ubuntu-daemon.tar.gz && \
    tar -xvf /tmp/BLOCX-2.1.0-ubuntu-daemon.tar.gz -C /usr/local/bin && \
    rm /tmp/BLOCX-2.1.0-ubuntu-daemon.tar.gz
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY node_initialize.sh /node_initialize.sh
COPY check-health.sh /check-health.sh
COPY sentinel.sh /sentinel.sh
VOLUME /root/.blocx
RUN chmod 755 node_initialize.sh check-health.sh sentinel.sh
EXPOSE 9999
EXPOSE 12972
HEALTHCHECK --start-period=5m --interval=2m --retries=5 --timeout=15s CMD ./check-health.sh
ENTRYPOINT ["/usr/bin/supervisord"]
