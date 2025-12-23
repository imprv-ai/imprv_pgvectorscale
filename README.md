# imprv_pgvectorscale

A Docker image providing PostgreSQL 18 with vector extensions for AI/ML workloads.

## 🚀 Features

- **PostgreSQL 18** - Latest stable PostgreSQL version
- **pgvector** - Vector similarity search (from `pgvector/pgvector:0.8.1-pg18-trixie`)
- **pgvectorscale** - Time-series vector compression (built from source)
- **Semantic versioning** - Managed via Poetry
- **Local automation** - Via pypyr workflows
- **Multi-arch builds** - amd64 + arm64 via GitHub Actions

## 🏷️ Image Tags

| Tag | Description |
|-----|-------------|
| `18-vX.Y.Z` | Versioned release bound to PostgreSQL 18 |
| `18-latest` | Latest stable release for PostgreSQL 18 |

### Examples
```bash
docker.io/imprvai/imprv_pgvectorscale:18-v0.1.0
docker.io/imprvai/imprv_pgvectorscale:18-latest
```

## 🏃 Quick Start

```bash
docker run --rm -it \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  docker.io/imprvai/imprv_pgvectorscale:18-latest
```

### First Run Setup

On first initialization with a fresh data volume:

- ✅ **pgvector** is pre-installed (from base image)
- ✅ **vectorscale** is installed via `init_vectorscale.sql`
- ✅ **vectorscale** is preloaded via `shared_preload_libraries`

### Verification

Verify extensions are available:

```sql
SELECT * FROM pg_available_extensions
WHERE name IN ('vector', 'vectorscale');

SELECT * FROM pg_extension
WHERE extname IN ('vector', 'vectorscale');
```

## 📦 Versioning

Version source of truth: `pyproject.toml`

```toml
[tool.poetry]
version = "X.Y.Z"
```

### Local Release Process

Bump version locally:

```bash
pypyr release part=patch  # or part=minor / part=major
```

This automated workflow will:

1. **Bump version** in `pyproject.toml` using Poetry
2. **Build** Docker images with tags:
   - `18-vX.Y.Z`
   - `18-latest`
3. **Push** images to Docker Hub
4. **Update** `CHANGELOG.md` with commits since previous tag
5. **Commit** `pyproject.toml` and `CHANGELOG.md`
6. **Create** git tag `vX.Y.Z`
7. **Push** commit and tag (if git credentials configured)

## 🔧 Local Workflows

Commands can be run from the project root using pypyr shortcuts:

### Build Only
```bash
# Single-arch build (default, faster, for local testing)
pypyr build

# Multi-arch build (amd64 + arm64, requires docker buildx)
# Note: Multi-arch builds push images to registry (can't load locally)
pypyr build multiarch=true push=true
```

### Push Only
```bash
pypyr push
```

### Full Release
```bash
# Single-arch release (default, builds locally, then pushes)
pypyr release part=patch

# Multi-arch release (amd64 + arm64, builds and pushes to registry)
pypyr release part=patch multiarch=true
```
*Includes: version bump + build + push + changelog + git tag/push*

> **Note:** When using `multiarch=true`, images are automatically pushed during build (required for multi-arch manifests). Single-arch builds are loaded locally first, then pushed separately.

> **Note:** 
> - Shortcuts are defined in `pyproject.toml` under `[tool.pypyr.shortcuts]`
> - Multi-arch builds require `docker buildx` and are slower (uses QEMU emulation)
> - Multi-arch builds push images to registry (can't be loaded locally like single-arch)
> - GitHub Actions always builds multi-arch by default

## 🧪 CI/CD Testing (GitHub Actions)

**Workflow:** `.github/workflows/pr-build-test.yaml`

### Trigger
- **Automatic:** Runs on Pull Requests (opened, updated, reopened)
- **Paths:** Only triggers on changes to `docker/`, `.github/workflows/`, `pyproject.toml`, or `ops/`

### Process

1. **Build Docker image** (without pushing)
2. **Test PostgreSQL startup** - Verifies container starts successfully
3. **Test extensions** - Verifies `vector` and `vectorscale` extensions are available and can be installed
4. **Verify preload** - Checks that vectorscale is properly configured

> **Note:** Images are built with tag `pr-{PR_NUMBER}` for testing purposes only. No images are pushed to registry.

## 🚀 CI/CD Release (GitHub Actions)

**Workflow:** `.github/workflows/release.yaml`

### Trigger
- **Manual trigger:** `workflow_dispatch` from GitHub UI
- **Input:** `part` = `major` | `minor` | `patch`

### Process

1. **Prepare release** - Bump version, update changelog, commit, create tag (using `pypyr release-prep`)
2. **Build & push multi-arch images** (amd64 + arm64) using `docker/build-push-action`
3. **Push commit & tag** to repository

**Tags pushed:**
   - `18-vX.Y.Z`
   - `18-latest`

> **Note:** 
> - CI/CD always builds and pushes **multi-arch** images (amd64 + arm64)
> - Local release workflow (`pypyr release`) builds **single-arch** images by default (faster for testing)
> - Use `multiarch=true` flag for local multi-arch builds: `pypyr release part=patch multiarch=true`

## 📄 License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This project is licensed under the MIT License.