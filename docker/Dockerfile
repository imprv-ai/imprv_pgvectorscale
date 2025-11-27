# --- Global build args (common for all stages) ------------------------
ARG VECTORSCALE_REF=0.9.0
ARG APP_VERSION=0.1.0
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown

# --- Stage 1: builder --------------------------------------------------------
FROM pgvector/pgvector:0.8.1-pg17-trixie AS builder

# Activate global ARG in this stage
ARG VECTORSCALE_REF
ARG APP_VERSION
ARG VCS_REF
ARG BUILD_DATE

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    postgresql-server-dev-17 \
    cargo \
    rustc \
    rustfmt \
    curl \
    jq \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Update CA certificates and clone pgvectorscale
RUN update-ca-certificates && \
    git clone https://github.com/timescale/pgvectorscale.git /tmp/pgvectorscale \
    && cd /tmp/pgvectorscale \
    && git checkout "${VECTORSCALE_REF}"

WORKDIR /tmp/pgvectorscale/pgvectorscale

# Install cargo-pgrx with the same version as pgrx
RUN cargo install --locked cargo-pgrx --version \
    "$(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "pgrx") | .version')"

# Initialize pgrx for PostgreSQL 17
RUN cargo pgrx init --pg17 pg_config

# Build and install pgvectorscale
RUN cargo pgrx install --release

# Clean builder
RUN rm -rf /tmp/pgvectorscale


# --- Stage 2: final runtime --------------------------------------------------
FROM pgvector/pgvector:0.8.1-pg17-trixie

# Activate global ARG in the final image
ARG VECTORSCALE_REF
ARG APP_VERSION
ARG VCS_REF
ARG BUILD_DATE

# Standard OCI labels
LABEL org.opencontainers.image.title="Postgres + pgvector + pgvectorscale"
LABEL org.opencontainers.image.description="PostgreSQL 17 with pgvector and pgvectorscale extensions"
LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.source="https://github.com/imprv-ai/imprv_pgvectorscale"
LABEL org.opencontainers.image.licenses="MIT"

LABEL ai.imprv.pgvector.base="pgvector/pgvector:0.8.1-pg17-trixie"
LABEL ai.imprv.pgvectorscale.ref="${VECTORSCALE_REF}"

# Copy extension artifacts from builder (only for vectorscale)
COPY --from=builder /usr/lib/postgresql/17/lib/vectorscale*.so /usr/lib/postgresql/17/lib/
COPY --from=builder /usr/share/postgresql/17/extension/vectorscale* /usr/share/postgresql/17/extension/

# Set preload libraries
ENV POSTGRESQL_CONF_PRELOAD_LIBRARIES=vectorscale

# Initialize script (run on first initdb)
COPY init_vectorscale.sql /docker-entrypoint-initdb.d/init_vectorscale.sql

# HEALTHCHECK dziedziczony z base image (pgvector/pgvector -> postgres:17)
