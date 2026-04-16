#!/bin/bash
# Start socat proxy to forward localhost:7687 to neo4j:7687
socat TCP-LISTEN:7687,fork,reuseaddr TCP:neo4j:7687 &
 
# Start fc-service with correct Neo4j properties and enable Swagger
exec java \
  -Djava.security.egd=file:/dev/./urandom \
  -Dspring.profiles.active=local \
  -Dgraphstore.uri=bolt://localhost:7687 \
  -Dgraphstore.user=neo4j \
  -Dgraphstore.password=catalogue_pass \
  -Dspringdoc.api-docs.enabled=true \
  -Dspringdoc.swagger-ui.enabled=true \
  -jar /app/app.jar
