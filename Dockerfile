# Stage 1: Fetch and unpack the binary
FROM debian:bullseye-slim as downloader

# Install curl and tar
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl tar && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Download and unpack the latest Uniclip release
ARG UNICLIP_VERSION=2.3.6
RUN curl -sL https://github.com/quackduck/uniclip/releases/download/v${UNICLIP_VERSION}/uniclip_${UNICLIP_VERSION}_Linux_x86_64.tar.gz -o uniclip.tar.gz && \
    tar -xzf uniclip.tar.gz && \
    mv uniclip_*/uniclip uniclip && \
    chmod +x uniclip && \
    rm uniclip.tar.gz

# Stage 2: Build the clean final image
FROM debian:bullseye-slim

# Set working directory
WORKDIR /app

# Copy the binary from the downloader stage
COPY --from=downloader /app/uniclip /app/uniclip

# Make the port customizable via environment variable (default: 51607)
ENV UNICLIP_PORT=51607

# Expose the customizable port
EXPOSE $UNICLIP_PORT

# Set the entry point
ENTRYPOINT ["./uniclip"]

# Default command to use the port environment variable
CMD ["--port", "${UNICLIP_PORT}"]
