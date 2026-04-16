#!/bin/bash

echo "================================"
echo "Stopping Simpl Catalogue Local"
echo "================================"

echo "→ Stopping services..."
docker-compose down

echo "✓ Services stopped"

if [ "$1" == "--full" ]; then
    echo "================================"
    echo "Full cleanup requested"
    echo "================================"
    
    echo "→ Removing volumes..."
    docker-compose down -v
    echo "✓ Volumes removed"
    
    echo "→ Cleaning data directories..."
    rm -rf data/
    echo "✓ Data directories cleaned"
    
    echo "→ Cleaning build artifacts..."
    rm -rf build/
    echo "✓ Build artifacts cleaned"
    
    echo "✓ Full cleanup complete"
    echo "Note: Repositories preserved. Delete repos/ manually if needed."
fi

echo "To restart: ./start.sh"
