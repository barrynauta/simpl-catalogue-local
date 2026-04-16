# Simpl Catalogue Local

Standalone Docker Compose deployment of the Simpl-Open Catalogue backend services (fc-service + xfsc-advsearch-be).

## Purpose & Scope

This deployment runs the **base Gaia-X Federated Catalogue** (fc-service) and Advanced Search backend (xfsc-advsearch-be) locally using Docker Compose, without requiring the full Simpl Kubernetes infrastructure.

### What this deployment provides

✅ **Base Gaia-X Federated Catalogue** (fc-service)
- Core catalogue database and search engine
- Self-description publication and management
- Syntax and semantic validation
- Neo4j graph database with RDF/semantic capabilities
- PostgreSQL relational database

✅ **Advanced Search Backend** (xfsc-advsearch-be)
- Search indexing and query processing
- API for search operations

✅ **Local development environment**
- Standalone deployment without Kubernetes
- Interactive API documentation (Swagger UI)
- Direct database access for debugging

### What this deployment does NOT provide

❌ **Full Simpl-Open Catalogue governance layer**
- Catalogue Client Service (frontend/UI)
- Query Mapper Adapter (search parameter translation)
- Policy Filter Service (access control enforcement)
- Quality Rule Validation Service (quality scoring)
- Schema Registry integration
- Management Service (advanced lifecycle operations)

❌ **Other Simpl-Open services**
- Authentication/authorization (Keycloak)
- EDC connectors or data plane services
- Notary services
- Compliance services
- Production-grade scalability or high availability

### Use Cases

- **Local development and debugging** - Develop and test catalogue integrations without full infrastructure
- **Integration testing** - Validate catalogue API behavior and data models
- **SC-3 co-development scenarios** - Test component interactions during parallel development
- **Component behavior verification** - Understand how the base Gaia-X catalogue works
- **API exploration** - Learn the catalogue API through Swagger UI documentation

### Architecture Context

This deployment provides the **foundational backend** - the core Gaia-X Federated Catalogue that Simpl-Open extends with additional governance, policy enforcement, and quality management layers. It demonstrates that SC-1's Simpl-Open components are modular and can run independently of the full platform infrastructure.

For the complete Simpl-Open Catalogue architecture including governance components, see the [Simpl Programme documentation](https://simpl-programme.ec.europa.eu/).

## Prerequisites

### Required Software
- **Docker** 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** 2.0+ (included with Docker Desktop)
- **Git** 2.30+
- **Maven** 3.8+ ([Install Maven](https://maven.apache.org/install.html))
- **Java** 17+ (for Maven builds - [Install OpenJDK](https://openjdk.org/install/))

### System Requirements
- **RAM**: 8GB minimum (12GB recommended)
- **Disk**: 10GB free space (for Docker images, plugins, and databases)
- **OS**: Linux, macOS, or Windows with WSL2

### Network Access
Maven needs access to:
- `code.europa.eu` (GitLab - source repositories)
- `repo.maven.apache.org` (Maven Central)
- Internal Simpl artifact repositories (if configured)

Docker needs access to:
- `hub.docker.com` (base images)
- `plugins.neo4j.com` (Neo4j plugins)

### Verification
Check your setup:
```bash
docker --version          # Should show 20.10+
docker-compose --version  # Should show 2.0+
git --version            # Should show 2.30+
mvn --version            # Should show 3.8+ with Java 17+
java --version           # Should show 17+
```

## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/barrynauta/simpl-catalogue-local.git
cd simpl-catalogue-local

# 2. Make scripts executable
chmod +x start.sh stop.sh

# 3. Run the deployment
./start.sh

# 4. Wait for services to start (first run takes ~2 minutes for Neo4j plugin downloads)

# 5. Verify deployment
docker ps
curl http://localhost:8081/self-descriptions
curl http://localhost:8080/actuator/health
```

**First startup**: The initial run downloads ~50MB of Neo4j plugins (APOC, GDS, n10s). Subsequent startups are much faster.

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **fc-service API** | http://localhost:8081 | Federated Catalogue REST API |
| **Swagger UI** | http://localhost:8081/swagger-ui/index.html | Interactive API documentation |
| **OpenAPI Spec** | http://localhost:8081/v3/api-docs | OpenAPI 3.0 JSON specification |
| **fc-service health** | http://localhost:8081/self-descriptions | Health check endpoint |
| **Advanced Search** | http://localhost:8080 | Advanced search backend API |
| **Neo4j Browser** | http://localhost:7474 | Graph database UI |
| **PostgreSQL** | localhost:5432 | Database connection |

### API Endpoints

**fc-service (port 8081):**
```bash
# List self-descriptions
curl http://localhost:8081/self-descriptions

# List schemas
curl http://localhost:8081/schemas

# List participants
curl http://localhost:8081/participants

# Open interactive API documentation in browser
open http://localhost:8081/swagger-ui/index.html
```

**xfsc-advsearch-be (port 8080):**
```bash
# Health check (returns auth error when working correctly)
curl http://localhost:8080/actuator/health
# Expected: "Missing or invalid Authorization header"
```

**Neo4j Browser:**
- Open http://localhost:7474 in your browser
- Login with credentials from `.env` (default: `neo4j` / `catalogue_pass`)

## Components

| Service | Port | Purpose | Technology |
|---------|------|---------|------------|
| **fc-service** | 8081 | Federated Catalogue API | Java 17, Spring Boot |
| **xfsc-advsearch-be** | 8080 | Advanced Search backend | Java 21, Spring Boot |
| **PostgreSQL** | 5432 | Relational database | PostgreSQL 15 |
| **Neo4j** | 7474 (HTTP)<br>7687 (Bolt) | Graph database | Neo4j 5.14 |

## Configuration

Edit `.env` to customize:

```bash
# Ports
FC_SERVICE_PORT=8081
ADVSEARCH_PORT=8080
NEO4J_HTTP_PORT=7474
NEO4J_BOLT_PORT=7687
POSTGRES_PORT=5432

# Credentials
POSTGRES_USER=catalogue
POSTGRES_PASSWORD=catalogue_pass
NEO4J_USER=neo4j
NEO4J_PASSWORD=catalogue_pass  # MUST be custom (not 'neo4j')
```

**Important**: Neo4j 5.14+ refuses the default `neo4j` password. You must use a custom password.

## Usage

### Start Services

```bash
./start.sh
```

This script:
1. Clones repositories (first run only)
2. Builds JARs with Maven
3. Builds Docker images
4. Starts all services

### Stop Services

```bash
./stop.sh              # Stop containers only
./stop.sh --full       # Stop and remove all data
```

### Check Status

```bash
docker ps
docker logs -f catalogue-fc-service
docker logs -f catalogue-advsearch
```

### Test APIs

```bash
# fc-service API
curl http://localhost:8081/self-descriptions
curl http://localhost:8081/schemas
curl http://localhost:8081/participants

# Advanced search (requires authentication)
curl http://localhost:8080/actuator/health
```

## Architecture

### Service Dependencies

```
PostgreSQL ←────┐
                 ├─── fc-service (8081)
Neo4j ←─────────┘         ↓
                    xfsc-advsearch-be (8080)
```

### Neo4j Connection Pattern

fc-service hardcodes `bolt://localhost:7687` in its source code. We solve this using a **socat TCP proxy**:

```
fc-service container:
  Java app → localhost:7687 (socat proxy)
                ↓
             neo4j:7687 (Docker network)
                ↓
          Neo4j container
```

### Required Neo4j Plugins

All three plugins are automatically downloaded on first start (~30-60 seconds):

1. **APOC** - General procedures
2. **Graph Data Science (GDS)** - Required by `GraphDbConfig.driver()`
3. **n10s (neosemantics)** - Required for RDF/semantic operations

## Configuration Details

### GraphDbConfig Properties

fc-service uses **custom property names** (not Spring Boot standard):

```properties
graphstore.uri=bolt://localhost:7687      # NOT spring.neo4j.uri
graphstore.user=neo4j                     # NOT spring.neo4j.authentication.username
graphstore.password=catalogue_pass        # NOT spring.neo4j.authentication.password
```

These are defined in `GraphDbConfig.java` via `@Value` annotations.

### Java Versions

- **fc-service**: Java 17
- **xfsc-advsearch-be**: Java 21

The Dockerfiles use the appropriate `eclipse-temurin` base images.

## Troubleshooting

### Neo4j won't start: "Invalid value for password"

**Problem**: `Invalid value for password. It cannot be 'neo4j', which is the default.`

**Solution**: Neo4j 5.14+ requires a custom password. Set `NEO4J_PASSWORD` in `.env` to something other than `neo4j`.

### fc-service authentication failures

**Problem**: `The client is unauthorized due to authentication failure.`

**Solutions**:
1. Check Neo4j password matches in `.env` and `start-fc-service.sh`
2. Verify property names are `graphstore.*` (not `graphdb.*` or `spring.neo4j.*`)
3. Run `./stop.sh --full` to reset Neo4j data if password changed

### Missing Neo4j procedures

**Problem**: `There is no procedure with the name 'gds.graph.exists'` or `'n10s.graphconfig.show'`

**Solution**: Ensure `NEO4J_PLUGINS=["apoc", "graph-data-science", "n10s"]` in `docker-compose.yml`. Delete volumes and restart: `./stop.sh --full && ./start.sh`

### Java version mismatch in xfsc-advsearch-be

**Problem**: `UnsupportedClassVersionError: class file version 65.0`

**Solution**: The Dockerfile must use `eclipse-temurin:21-jre` (not Java 17) for xfsc-advsearch-be.

### Services marked "unhealthy" but working

**Problem**: `docker ps` shows services as unhealthy, but APIs respond correctly.

**Explanation**: Healthchecks may timeout due to initialization time. If the APIs respond to curl, the services are working. You can increase healthcheck timeouts in `docker-compose.yml` if needed.

### Docker Compose doesn't read `.env.local`

**Problem**: Environment variables not loading.

**Solution**: Docker Compose defaults to `.env` filename. Rename `.env.local` to `.env` or use `--env-file` flag.

## Project Structure

```
simpl-catalogue-local/
├── docker-compose.yml              # Service definitions
├── .env                           # Configuration
├── start.sh                       # Build and deploy script
├── stop.sh                        # Cleanup script
├── Dockerfile.fc-service          # fc-service image (Java 17 + socat)
├── Dockerfile.xfsc-advsearch-be   # advsearch image (Java 21)
├── start-fc-service.sh            # fc-service startup with correct properties
├── build/                         # Built JARs (generated)
│   ├── fc-service/app.jar
│   └── xfsc-advsearch-be/app.jar
└── repos/                         # Git clones (generated)
    ├── simpl-fc-service/
    └── xfsc-advsearch-be/
```

## Development

### Rebuild After Code Changes

```bash
./stop.sh
# Make changes in repos/
./start.sh
```

### Force Clean Rebuild

```bash
./stop.sh --full
docker rmi catalogue-fc-service catalogue-xfsc-advsearch-be
./start.sh
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker logs -f catalogue-fc-service
docker logs -f catalogue-neo4j
```

### Access Neo4j Browser

Open http://localhost:7474 and login with:
- Username: `neo4j`
- Password: (value from `.env` `NEO4J_PASSWORD`)

## Known Issues

1. **COMMON_LOGGING license warning**: This is an internal Simpl library. The warning is harmless.

2. **Healthcheck strictness**: Docker healthchecks may mark services "unhealthy" even when functional. Test with curl to verify actual status.

3. **First startup slow**: Neo4j downloads GDS plugin (~50MB) on first start. Allow 1-2 minutes.

4. **xfsc-advsearch-be JAR naming**: Build produces `xfsc-advsearch-be.jar` without version suffix. If `start.sh` fails to copy, manually adjust the filename pattern.

## Contributing

This is a standalone local deployment for development and testing. For production deployments, use the official Simpl Helm charts with Kubernetes.

### Reporting Issues

When reporting issues, include:
- Docker version: `docker --version`
- Docker Compose version: `docker-compose --version`
- Full output of `./start.sh`
- Logs: `docker logs catalogue-fc-service`

## Key Learnings

This deployment was created through extensive source code analysis when official local deployment documentation wasn't available. Key discoveries:

1. **GraphDbConfig uses custom property names** (`graphstore.*` instead of Spring Boot's `spring.neo4j.*`)
2. **Neo4j 5.14+ enforces password security** (rejects default `neo4j` password)
3. **Three Neo4j plugins are required** (APOC, GDS, n10s - not just APOC)
4. **fc-service hardcodes localhost:7687** (requires socat proxy pattern)
5. **xfsc-advsearch-be needs Java 21** (not Java 17)

## License

Components:
- **COMMON_LOGGING**: Internal Simpl library (likely EUPL)
- **fc-service**: See repository license
- **xfsc-advsearch-be**: See repository license

## Related Documentation

- [Simpl Programme](https://simpl-programme.ec.europa.eu/)
- [fc-service Repository](https://code.europa.eu/simpl/simpl-open/development/gaia-x-edc/simpl-fc-service)
- [xfsc-advsearch-be Repository](https://code.europa.eu/simpl/simpl-open/development/data1/xfsc-advsearch-be)
- [Neo4j Documentation](https://neo4j.com/docs/)
- [Neo4j Graph Data Science](https://neo4j.com/docs/graph-data-science/current/)

## Acknowledgments

This deployment demonstrates that Simpl-Open's architecture is modular and components can run independently of the full Kubernetes infrastructure. It validates the feasibility of local development and SC-3 co-development scenarios.
