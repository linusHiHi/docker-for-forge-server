ARG MC_VERSION 
ARG FORGE_VERSION
ARG JAVA_VERSION
ARG PACK_NAME

FROM openjdk:${JAVA_VERSION}-jdk-slim AS build

ARG MC_VERSION 
ARG FORGE_VERSION
ARG PACK_NAME

ENV INSTALLER_NAME=forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar \
    PACK_NAME=${PACK_NAME}

# Create minecraft user (rarely changes)
RUN groupadd -g 1234 -r mia && useradd -r -g mia -u 1000 mc

WORKDIR /tmp

# Copy scripts and default files (changes less frequently)
COPY ./default_files/ /app/
COPY ./docker_scripts/ /app/docker_scripts/
COPY ./docker-entry.sh /app/

# Handle Forge installer (depends on MC/Forge version, changes less frequently)
RUN set -eux; \
    echo "Local installer not found — downloading ${INSTALLER_NAME}"; \
    apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fSL -o "${INSTALLER_NAME}" "https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/${INSTALLER_NAME}" && \
    apt-get purge -y curl && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Install Forge server (depends on installer, changes less frequently)
WORKDIR /app
RUN java -jar "/tmp/${INSTALLER_NAME}" --installServer && \
    echo "eula=true" > eula.txt

# Copy pack files (changes most frequently - should be last)
COPY ./packs/${PACK_NAME}/ /tmp/${PACK_NAME}/
RUN set -eux; \
    if [ -d "/tmp/${PACK_NAME}" ]; then \
      echo "Found pack folder, copying all files to server..."; \
      find "/tmp/${PACK_NAME}" -mindepth 1 -maxdepth 1 ! -name "${INSTALLER_NAME}" -exec cp -rf {} "/app/" \; ; \
      echo "Pack files copied successfully"; \
    else \
      echo "No pack folder found, skipping..."; \
    fi

# Set final permissions and cleanup
RUN chown -R mc:mia /app && \
    chmod +x /app/docker-entry.sh && \
    chmod -R +x /app/docker_scripts/ && \
    rm -rf /tmp/* && \
    rm -f /app/*.log /app/*.bat

FROM openjdk:${JAVA_VERSION}-jdk-slim

ARG MC_VERSION 
ARG FORGE_VERSION
ARG PACK_NAME
ARG JAVA_VERSION

# Set environment variables for runtime
ENV MC_VERSION=${MC_VERSION} \
    FORGE_VERSION=${FORGE_VERSION} \
    JAVA_VERSION=${JAVA_VERSION} \
    PACK_NAME=${PACK_NAME}

COPY --from=build /app /app
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group

WORKDIR /app

# Setup permissions and volume mount points
RUN chown -R mc:mia /app && \
    find /app -type f -name "*.sh" -exec chmod +x {} \; && \
    chmod -R 755 /app/docker_scripts 2>/dev/null || true && \
    mkdir -p /modified_data /app/world && \
    chown mc:mia /modified_data /app/world && \
    chmod 777 /app/world

VOLUME [ "/app/modified_data", "/app/world", "/app/log", "/app/crash-reports", "/app/mod-pack" ]

USER mc:mia

CMD ["./docker-entry.sh"]


