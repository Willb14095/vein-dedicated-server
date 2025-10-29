FROM cm2network/steamcmd:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 lib32stdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Create steam user
RUN useradd -m steam
WORKDIR /home/steam

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to steam
USER steam

ENTRYPOINT ["/entrypoint.sh"]