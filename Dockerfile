# RocketRide engine on Railway: the official upstream image (rocketride-org/rocketride-server 3.6.0, MIT), engine unmodified.
# This layer only adds an entrypoint that makes the Railway volume at /opt/data writable for the engine's
# uid 1000, then starts the engine on port 8080 as uid 1000.
FROM ghcr.io/rocketride-org/rocketride-engine:3.6.0
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/rocketride"
USER root
COPY railway/entry.sh /usr/local/bin/railway-entry.sh
ENV ROCKETRIDE_PORT=8080 \
    ROCKETRIDE_LOG_LEVEL=info
EXPOSE 8080
HEALTHCHECK NONE
ENTRYPOINT ["/usr/local/bin/railway-entry.sh"]
CMD []
