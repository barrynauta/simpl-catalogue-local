#!/bin/bash
set -e

echo "================================"
echo "Starting Simpl Catalogue Local"
echo "================================"

# Load environment variables
if [ -f .env.local ]; then
    export $(cat .env.local | grep -v '^#' | xargs)
fi

# Create build directories
mkdir -p build/fc-service build/xfsc-advsearch-be repos

# Clone or update repositories
echo "→ Setting up repositories..."
if [ ! -d "repos/simpl-fc-service" ]; then
    git clone https://code.europa.eu/simpl/simpl-open/development/gaia-x-edc/simpl-fc-service.git repos/simpl-fc-service
fi

if [ ! -d "repos/xfsc-advsearch-be" ]; then
    git clone https://code.europa.eu/simpl/simpl-open/development/data1/xfsc-advsearch-be.git repos/xfsc-advsearch-be
fi

# Build fc-service
echo "→ Building fc-service..."
cd repos/simpl-fc-service
mvn clean package -DskipTests=${BUILD_SKIP_TESTS:-true} -Dcheckstyle.skip=true
cp fc-service-server/target/fc-service-server-*.jar ../../build/fc-service/app.jar
cd ../..

# Build xfsc-advsearch-be (with version patching)
echo "→ Building xfsc-advsearch-be..."
cd repos/xfsc-advsearch-be

# Patch pom.xml to replace ${env.PROJECT_RELEASE_VERSION} with actual version
if grep -q '${env.PROJECT_RELEASE_VERSION}' pom.xml; then
    sed -i.bak 's/${env.PROJECT_RELEASE_VERSION}/'"${ADVSEARCH_VERSION}"'/g' pom.xml
fi

mvn clean package -DskipTests=${BUILD_SKIP_TESTS:-true} -Dcheckstyle.skip=true
cp target/xfsc-advsearch-be.jar ../../build/xfsc-advsearch-be/app.jar
cd ../..

# Start services
echo "→ Starting services..."
docker-compose up -d --build

echo ""
echo "✓ Simpl Catalogue Local is starting"
echo ""
echo "Services:"
echo "  - PostgreSQL:      localhost:${POSTGRES_PORT:-5432}"
echo "  - Neo4j Browser:   http://localhost:${NEO4J_HTTP_PORT:-7474}"
echo "  - fc-service:      http://localhost:${FC_SERVICE_PORT:-8081}"
echo "  - advsearch:       http://localhost:${ADVSEARCH_PORT:-8080}"
echo ""
echo "Check status:"
echo "  docker ps"
echo "  docker logs -f catalogue-fc-service"
echo ""
