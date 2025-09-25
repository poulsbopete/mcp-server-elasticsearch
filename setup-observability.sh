#!/bin/bash

# Elasticsearch MCP Server Setup Script for Observability
# This script helps you set up the MCP server for your Elastic Serverless endpoint

set -e

echo "🔍 Elasticsearch MCP Server Setup for Observability"
echo "=================================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
# Elasticsearch Serverless Configuration
ES_URL=https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud
ES_API_KEY=YOUR_ELASTIC_API_KEY_HERE

# Alternative: Use username/password instead of API key
# ES_USERNAME=elastic
# ES_PASSWORD=YOUR_PASSWORD_HERE

# SSL settings
ES_SSL_SKIP_VERIFY=false
EOF
    echo "✅ Created .env file. Please edit it with your actual credentials."
else
    echo "✅ .env file already exists"
fi

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t elasticsearch-core-mcp-server .

echo "✅ Docker image built successfully"

# Start the services
echo "🚀 Starting MCP server..."
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 10

# Test the health endpoint
echo "🔍 Testing server health..."
if curl -f http://localhost:8080/ping > /dev/null 2>&1; then
    echo "✅ MCP server is running and healthy!"
else
    echo "❌ MCP server health check failed"
    echo "📋 Checking logs..."
    docker-compose logs elasticsearch-mcp-server
    exit 1
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Your MCP server is now running at:"
echo "   • MCP Endpoint: http://localhost:8080/mcp"
echo "   • Health Check: http://localhost:8080/ping"
echo "   • Test UI: http://localhost:8081"
echo ""
echo "🔧 To configure Cursor MCP, add this to your MCP config:"
echo ""
cat << 'EOF'
{
  "mcpServers": {
    "elasticsearch-observability": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "ES_URL", "-e", "ES_API_KEY",
        "elasticsearch-core-mcp-server",
        "stdio"
      ],
      "env": {
        "ES_URL": "https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud",
        "ES_API_KEY": "YOUR_ELASTIC_API_KEY_HERE"
      }
    }
  }
}
EOF
echo ""
echo "📚 Available observability tools:"
echo "   • query_observability_data - Query metrics, traces, logs with time filtering"
echo "   • aggregate_metrics - Aggregate metrics with various functions"
echo "   • analyze_traces - Analyze distributed traces"
echo "   • analyze_logs - Search and filter log data"
echo "   • health_check - Check cluster and index health"
echo ""
echo "🛠️  To stop the server: docker-compose down"
echo "📊 To view logs: docker-compose logs -f elasticsearch-mcp-server"
echo "🌐 To test the server: open http://localhost:8081 in your browser"
