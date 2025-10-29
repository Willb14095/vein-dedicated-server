# Dockerfile
FROM cm2network/steamcmd:latest

# ── 1. Install system deps as root ─────────────────────────────────────
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        lib32gcc-s1 \
        lib32stdc++6 && \
    rm -rf /var/lib/apt/lists/*

# ── 2. Ensure steam user exists and owns /home/steam ──────────────────
RUN if ! id -u steam > /dev/null 2>&1; then \
        useradd -m -s /bin/bash steam; \
    fi && \
    chown -R steam:steam /home/steam

# ── 3. Switch to steam user ───────────────────────────────────────────
USER steam
WORKDIR /home/steam

# ── 4. Copy entrypoint (already +x from Git) ──────────────────────────
COPY --chown=steam:steam entrypoint.sh /entrypoint.sh

# ── 5. Install Vein via SteamCMD (first run) ──────────────────────────
RUN /home/steam/steamcmd/steamcmd.sh +login anonymous \
    +app_update 2131400 validate +quit

# ── 6. Entrypoint ─────────────────────────────────────────────────────
ENTRYPOINT ["/entrypoint.sh"]