-- =============================================================================
-- PGVECTORSCALE EXTENSION INITIALIZATION SCRIPT
-- =============================================================================
-- Based on: https://github.com/timescale/pgvectorscale/blob/main/README.md
-- This script runs automatically during PostgreSQL initialization
-- =============================================================================

-- First, verify that pgvector extension is available
-- (This should be available from the base pgvector image or Dockerfile installation)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_available_extensions
        WHERE name = 'vector'
    ) THEN
        RAISE EXCEPTION 'pgvector extension is not available. Please ensure pgvector is properly installed.';
    END IF;
END
$$;

-- Install the vectorscale extension with CASCADE to handle dependencies
-- CASCADE automatically installs pgvector if not already present
CREATE EXTENSION IF NOT EXISTS vectorscale CASCADE;

-- Verify that vectorscale was installed successfully
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_extension
        WHERE extname = 'vectorscale'
    ) THEN
        RAISE EXCEPTION 'Failed to install vectorscale extension';
    END IF;

    RAISE NOTICE 'pgvectorscale extension installed successfully';
END
$$;

-- =============================================================================
-- WHAT THIS DOES:
-- 1. Checks if pgvector is available in the system
-- 2. Creates vectorscale extension (installs pgvector automatically if needed)
-- 3. Verifies successful installation
-- 4. Logs success message
-- =============================================================================