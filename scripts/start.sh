#!/bin/bash

echo "🚀 Starting Notes Application..."

# Créer le dossier docker s'il n'existe pas
mkdir -p docker

# Vérifier que docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

# Arrêter les conteneurs existants
echo "🛑 Stopping existing containers..."
docker-compose down

# Build et démarrer les services
echo "🏗️  Building and starting services..."
docker-compose up --build -d

# Attendre que les services soient prêts
echo "⏳ Waiting for services to be ready..."
sleep 10

# Vérifier le statut
echo "📊 Checking services status..."
docker-compose ps

echo ""
echo "✅ Application started successfully!"
echo ""
echo "📍 Services available at:"
echo "   - API Backend: http://localhost:8080"
echo "   - Swagger UI: http://localhost:8080/swagger-ui.html"
echo "   - Frontend: http://localhost:8081"
echo "   - Database: localhost:5432"
echo ""
echo "📝 To view logs: docker-compose logs -f"
echo "🛑 To stop: docker-compose down"