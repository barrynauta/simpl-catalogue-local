# Simpl Catalogue Local

Standalone Docker Compose deployment of Simpl-Open Catalogue backend (fc-service + xfsc-advsearch-be).

## Quick Start

```bash
./start.sh
```

## Components

- **fc-service** (port 8081): Federated Catalogue service
- **xfsc-advsearch-be** (port 8080): Advanced search backend
- **PostgreSQL** (port 5432): Relational database
- **Neo4j** (ports 7474/7687): Graph database with GDS plugin

## Configuration

Edit `.env.local` to customize ports and credentials. Default credentials:
- PostgreSQL: `catalogue/catalogue_local_pass`
- Neo4j: `neo4j/neo4j`

## Commands

```bash
./start.sh          # Build and start all services
./stop.sh           # Stop services
./stop.sh --full    # Stop and remove all data (fresh start)
docker ps           # Check service status
docker logs -f catalogue-fc-service  # View fc-service logs
```

## Architecture Notes

### Neo4j Connection
fc-service expects `bolt://localhost:7687` (hardcoded in source). We use a socat TCP proxy inside the container to forward `localhost:7687` → `neo4j:7687`.

### GraphDbConfig Properties
fc-service uses custom property names (not Spring Boot standard):
- `graphstore.uri` (not `spring.neo4j.uri`)
- `graphstore.user` (not `spring.neo4j.authentication.username`)
- `graphstore.password` (not `spring.neo4j.authentication.password`)

### Required Neo4j Plugins
- APOC (loaded automatically)
- Graph Data Science (GDS) - downloads on first start (~30-60 seconds)
- n10s (neosemantics) - initialized by fc-service on first connection

## Troubleshooting

### Neo4j healthcheck fails
The healthcheck password must match `NEO4J_PASSWORD` in `.env.local`. If you see authentication failures, run `./stop.sh --full` to reset.

### fc-service can't connect to Neo4j
Check that:
1. Neo4j is healthy: `docker ps` shows `(healthy)` for catalogue-neo4j
2. GDS plugin loaded: `docker logs catalogue-neo4j | grep -i gds`
3. Credentials match: fc-service uses `neo4j/neo4j` from `.env.local`

### Build fails
Requires Maven and Git. Repositories are cloned to `repos/` on first run.

## License

COMMON_LOGGING (internal Simpl library): Likely EUPL (European Union Public License)
Other components: See individual repository licenses

## Related Documentation

- [Simpl-Open GitLab](https://code.europa.eu/simpl/simpl-open)
- [Neo4j GDS Documentation](https://neo4j.com/docs/graph-data-science/current/)
- [Spring Boot Neo4j](https://docs.spring.io/spring-boot/docs/current/reference/html/data.html#data.nosql.neo4j)
