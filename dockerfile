ARG MC_VERSION 
ARG FORGE_VERSION
ARG JAVA_VERSION
ARG PACK_NAME

FROM openjdk:${JAVA_VERSION}-jdk-slim AS build

ARG MC_VERSION 
ARG FORGE_VERSION
ARG PACK_NAME

ENV INSTALLER_NAME=forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar
ENV PACK_NAME=${PACK_NAME}

RUN groupadd -r minecraft && useradd -r -g minecraft minecraft


WORKDIR /tmp

# --- install server pack files ---
COPY ./${PACK_NAME}/ ./${PACK_NAME}/

RUN set -eux; \
    if [ -f "./${PACK_NAME}/${INSTALLER_NAME}" ]; then \
      echo "Found local installer: ./${PACK_NAME}/${INSTALLER_NAME}"; \
      mv "./${PACK_NAME}/${INSTALLER_NAME}" "./${INSTALLER_NAME}"; \
    else \
      echo "Local installer not found — downloading ${INSTALLER_NAME}"; \
      apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*; \
      curl -fSL -o "${INSTALLER_NAME}" "https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/${INSTALLER_NAME}"; \
    fi

WORKDIR /app
RUN java -jar "/tmp/${INSTALLER_NAME}" --installServer
# enable eula acceptance
RUN echo "eula=true" > eula.txt

# Copy all pack files to override server files
RUN set -eux; \
    if [ -d "/tmp/${PACK_NAME}" ]; then \
      echo "Found pack folder, copying all files to server..."; \
      # Copy all files and directories from pack folder to app, excluding only the installer
      find "/tmp/${PACK_NAME}" -mindepth 1 -maxdepth 1 ! -name "${INSTALLER_NAME}" -exec cp -rf {} "/app/" \; ; \
      echo "Pack files copied successfully"; \
    else \
      echo "No pack folder found, skipping..."; \
    fi

# === end install server pack files ---

# --- setup server files ---
COPY ./default_files/* /app/
# === end setup server files ---

COPY ./docker_scripts ./docker_scripts
RUN chown -R minecraft:minecraft /app
RUN chmod +x /app/docker_scripts/*.sh

RUN rm -rf /tmp/*

FROM openjdk:${JAVA_VERSION}-jdk-slim

ARG MC_VERSION 
ARG FORGE_VERSION

COPY --from=build /app /app
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group

# Set environment variables for runtime
ENV MC_VERSION=${MC_VERSION}
ENV FORGE_VERSION=${FORGE_VERSION}

WORKDIR /app

# Ensure all files have correct ownership and permissions
RUN chown -R minecraft:minecraft /app && \
    find /app -type f -name "*.sh" -exec chmod +x {} \; && \
    chmod -R 755 /app/docker_scripts 2>/dev/null || true

# Create and set permissions for volume mount points
RUN mkdir -p /modified_data && chown minecraft:minecraft /modified_data
RUN mkdir -p /app/world && chown minecraft:minecraft /app/world

VOLUME [ "/app/modified_data", "/app/world" ]

# Switch to minecraft user for runtime
USER minecraft:minecraft

CMD ["./docker_scripts/docker-entry.sh"]
# --- IGNORE ---


