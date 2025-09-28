#!/bin/bash

# 🚀 Elasticsearch MCP Server Deployment Script
# This script helps you deploy the MCP server to various cloud platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if required environment variables are set
check_env() {
    if [[ -z "${ES_URL}" ]]; then
        error "ES_URL environment variable is not set. Please set it to your Elasticsearch endpoint."
    fi
    
    if [[ -z "${ES_API_KEY}" ]]; then
        error "ES_API_KEY environment variable is not set. Please set it to your Elasticsearch API key."
    fi
    
    log "Environment variables validated ✅"
}

# Test Elasticsearch connection
test_elasticsearch() {
    log "Testing Elasticsearch connection..."
    
    if curl -s -H "Authorization: ApiKey ${ES_API_KEY}" "${ES_URL}/_cluster/health" > /dev/null; then
        log "Elasticsearch connection successful ✅"
    else
        error "Failed to connect to Elasticsearch. Please check your ES_URL and ES_API_KEY."
    fi
}

# Deploy to Railway
deploy_railway() {
    log "Deploying to Railway..."
    
    if ! command -v railway &> /dev/null; then
        log "Installing Railway CLI..."
        npm install -g @railway/cli
    fi
    
    # Initialize if not already done
    if [[ ! -f railway.toml ]] || ! railway status &> /dev/null; then
        log "Creating new Railway project..."
        cp deploy/railway.toml railway.toml
        railway init --name "elasticsearch-mcp-server"
        
        log "Adding service to Railway project..."
        railway add --service "mcp-server"
    fi
    
    # Set environment variables
    railway variables --set "ES_URL=${ES_URL}"
    railway variables --set "ES_API_KEY=${ES_API_KEY}"
    
    # Deploy
    railway up --detach
    
    log "Railway deployment complete! 🚂"
    railway status
}

# Deploy to Fly.io
deploy_fly() {
    log "Deploying to Fly.io..."
    
    if ! command -v fly &> /dev/null; then
        error "Fly CLI not found. Please install it: curl -L https://fly.io/install.sh | sh"
    fi
    
    # Copy config
    if [[ ! -f fly.toml ]]; then
        cp deploy/fly.toml fly.toml
    fi
    
    # Launch or update
    if [[ ! -f fly.toml ]] || ! fly status &> /dev/null; then
        fly launch --copy-config --name elasticsearch-mcp-server --yes
    fi
    
    # Set secrets
    fly secrets set ES_URL="${ES_URL}"
    fly secrets set ES_API_KEY="${ES_API_KEY}"
    
    # Deploy
    fly deploy
    
    log "Fly.io deployment complete! 🪁"
    fly status
}

# Build and test locally
test_local() {
    log "Building and testing locally..."
    
    # Build the Docker image
    docker build -t elasticsearch-mcp-server .
    
    # Run container with environment variables
    CONTAINER_ID=$(docker run -d \
        -e ES_URL="${ES_URL}" \
        -e ES_API_KEY="${ES_API_KEY}" \
        -e CONTAINER_MODE=true \
        -e HTTP_ADDRESS=0.0.0.0:8080 \
        -p 8080:8080 \
        elasticsearch-mcp-server http)
    
    log "Container started with ID: ${CONTAINER_ID}"
    
    # Wait for container to start
    sleep 10
    
    # Test health endpoint
    if curl -f http://localhost:8080/ping > /dev/null 2>&1; then
        log "Health check passed ✅"
    else
        error "Health check failed ❌"
    fi
    
    # Test MCP endpoint
    if curl -s -X POST -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}' \
        http://localhost:8080/mcp > /dev/null; then
        log "MCP endpoint test passed ✅"
    else
        warn "MCP endpoint test failed - this might be expected without proper MCP client"
    fi
    
    # Cleanup
    docker stop ${CONTAINER_ID}
    docker rm ${CONTAINER_ID}
    
    log "Local test complete! 🧪"
}

# Show usage
usage() {
    echo "🚀 Elasticsearch MCP Server Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  railway     Deploy to Railway (recommended for beginners)"
    echo "  fly         Deploy to Fly.io (recommended for production)"
    echo "  test        Build and test locally"
    echo "  check       Check prerequisites and environment"
    echo ""
    echo "Prerequisites:"
    echo "  - ES_URL environment variable (your Elasticsearch endpoint)"
    echo "  - ES_API_KEY environment variable (your Elasticsearch API key)"
    echo ""
    echo "Examples:"
    echo "  export ES_URL='https://your-elasticsearch-endpoint.com'"
    echo "  export ES_API_KEY='your-api-key-here'"
    echo "  $0 check"
    echo "  $0 test"
    echo "  $0 railway"
}

# Main script logic
main() {
    case "${1:-}" in
        "railway")
            check_env
            test_elasticsearch
            deploy_railway
            ;;
        "fly")
            check_env
            test_elasticsearch
            deploy_fly
            ;;
        "test")
            check_env
            test_elasticsearch
            test_local
            ;;
        "check")
            check_env
            test_elasticsearch
            log "All checks passed! Ready for deployment. ✅"
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        "")
            usage
            ;;
        *)
            error "Unknown command: $1. Use '$0 help' for usage information."
            ;;
    esac
}

# Run the main function
main "$@"
