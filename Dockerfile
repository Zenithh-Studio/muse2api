FROM python:3.12-slim

LABEL org.opencontainers.image.source="https://github.com/Zenithh-Studio/muse2api"

RUN apt-get update \
 && apt-get install -y --no-install-recommends chromium fonts-wqy-zenhei ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd --system --gid 1001 muse \
 && useradd --system --uid 1001 --gid muse --create-home muse \
 && mkdir -p /app/data /run/muse2api-auth /run/muse2api-admin \
 && chown -R 1001:1001 /app /run/muse2api-auth /run/muse2api-admin

WORKDIR /app

COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install --no-cache-dir .

ENV MUSE2API_HOST=0.0.0.0 \
    MUSE2API_DATA_DIR=/app/data \
    MUSE2API_CHROMIUM_PATH=/usr/local/bin/muse2api-chromium

COPY --chown=1001:1001 docker/entrypoint.sh /usr/local/bin/muse2api-entrypoint
COPY --chown=1001:1001 docker/chromium.sh /usr/local/bin/muse2api-chromium
RUN chmod 755 /usr/local/bin/muse2api-entrypoint /usr/local/bin/muse2api-chromium

USER 1001:1001

EXPOSE 18610
ENTRYPOINT ["/usr/local/bin/muse2api-entrypoint"]
CMD ["muse2api"]
