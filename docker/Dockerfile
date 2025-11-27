# --- Stage 1: builder --------------------------------------------------------
FROM pgvector/pgvector:0.8.1-pg17-trixie AS builder

ARG VECTORSCALE_REF=0.9.0
ARG APP_VERSION=0.1.0
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="Postgres + pgvector + pgvectorscale"
LABEL org.opencontainers.image.description="PostgreSQL 17 with pgvector and pgvectorscale extensions"
LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.source="https://github.com/imprv-ai/imprv_pgvectorscale"
LABEL org.opencontainers.image.licenses="MIT"
LABEL com.example.pgvector.base="pgvector/pgvector:0.8.1-pg17-trixie"
LABEL com.example.pgvectorscale.ref="${VECTORSCALE_REF}"

# Install build dependencies
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*
# Clone pgvectorscale
RUN git clone https://github.com/timescale/pgvectorscale.git /tmp/pgvectorscale \
    && cd /tmp/pgvectorscale \
    && git checkout "${VECTORSCALE_REF}"

WORKDIR /tmp/pgvectorscale/pgvectorscale

# Install cargo-pgrx with the same version as pgrx
RUN cargo install --locked cargo-pgrx --version \
    $(cargo metadata --format-version 1 | jq -r '.packages[] | select(.name == "pgrx") | .version')

# Initialize pgrx for PostgreSQL 17
RUN cargo pgrx init --pg17 pg_config

# Build and install pgvectorscale
RUN cargo pgrx install --release

# --- Stage 2: final runtime --------------------------------------------------
FROM pgvector/pgvector:0.8.1-pg17-trixie

ARG APP_VERSION=0.1.0
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown
ARG VECTORSCALE_REF=v0.2.0

LABEL org.opencontainers.image.title="Postgres + pgvector + pgvectorscale"
LABEL org.opencontainers.image.description="PostgreSQL 17 with pgvector and pgvectorscale extensions"
LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.source="https://github.com/imprv-ai/imprv_pgvectorscale"
LABEL org.opencontainers.image.licenses="MIT"
LABEL com.example.pgvector.base="pgvector/pgvector:0.8.1-pg17-trixie"
LABEL com.example.pgvectorscale.ref="${VECTORSCALE_REF}"

# Copy extension artifacts from builder
COPY --from=builder /usr/lib/postgresql/17/lib/vectorscale*.so /usr/lib/postgresql/17/lib/
COPY --from=builder /usr/share/postgresql/17/extension/vectorscale* /usr/share/postgresql/17/extension/

# Set preload libraries
ENV POSTGRESQL_CONF_PRELOAD_LIBRARIES=vectorscale

# Initialize script (run on first initdb)
COPY init_vectorscale.sql /docker-entrypoint-initdb.d/init_vectorscale.sql

# Note: Nie potrzebujemy dodatkowego HEALTHCHECK, bo jest on dziedziczony z base image (pgvector/pgvector -> postgres:17)
