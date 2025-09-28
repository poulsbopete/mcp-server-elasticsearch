#!/bin/bash

# Elasticsearch MCP Query Helper for ChatGPT
# Usage: ./es-query.sh [errors|indices|health|logs]

ES_URL="https://a5630c65c43f4f299288c392af0c2f45.es.us-east-1.aws.elastic.cloud"
ES_API_KEY="UThGNGc1a0JrZlJTcENQMzAzM1M6QndwU2ZSQ2dnR295aFdsOUF6QzdQdw=="

case "$1" in
    "errors")
        echo "🔍 Recent Errors (copy this result to ChatGPT):"
        echo "=================================================="
        curl -X POST "$ES_URL/_query" \
             -H "Authorization: ApiKey $ES_API_KEY" \
             -H "Content-Type: application/json" \
             -d '{"query":"FROM logs-* | WHERE @timestamp >= NOW() - 1 hour AND message LIKE \"*error*\" | KEEP @timestamp, message, service.name | SORT @timestamp DESC | LIMIT 10"}' | jq .
        ;;
    "indices")
        echo "📊 Available Indices (copy this result to ChatGPT):"
        echo "=================================================="
        curl -X POST "$ES_URL/logs-*/_search" \
             -H "Authorization: ApiKey $ES_API_KEY" \
             -H "Content-Type: application/json" \
             -d '{"size": 0, "aggs": {"indices": {"terms": {"field": "_index", "size": 20}}}}' | jq .aggregations
        ;;
    "health")
        echo "❤️ Cluster Status (copy this result to ChatGPT):"
        echo "==============================================="
        curl -X GET "$ES_URL" \
             -H "Authorization: ApiKey $ES_API_KEY" | jq .
        ;;
    *)
        echo "Usage: $0 [errors|indices|health]"
        echo "Examples:"
        echo "  $0 errors   - Get recent error logs"
        echo "  $0 indices  - List available indices" 
        echo "  $0 health   - Check cluster health"
        ;;
esac
