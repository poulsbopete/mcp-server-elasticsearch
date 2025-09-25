# Elasticsearch MCP Server for Observability

This enhanced MCP server provides comprehensive observability capabilities for your Elastic Serverless endpoint, allowing you to query metrics, traces, and logs directly from Cursor using natural language.

## 🚀 Quick Start

### 1. Prerequisites

- Docker and Docker Compose
- Elastic Serverless endpoint access
- Elastic API key or username/password

### 2. Setup

```bash
# Clone and navigate to the project
cd /opt/mcp-server-elasticsearch

# Run the setup script
./setup-observability.sh
```

The setup script will:
- Build the Docker image
- Create a `.env` file for your credentials
- Start the MCP server
- Test the connection
- Provide Cursor configuration

### 3. Configure Cursor MCP

Add this to your Cursor MCP configuration file:

```json
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
```

## 🔧 Available Tools

### Observability Tools

#### `query_observability_data`
Query any observability data (metrics, traces, logs) with time-based filtering.

**Parameters:**
- `index_pattern`: Index pattern (e.g., "metrics-*", "traces-*", "logs-*")
- `time_range`: Time range (e.g., "now-1h", "now-1d", "2024-01-01T00:00:00Z,2024-01-01T23:59:59Z")
- `filters`: Additional Elasticsearch query DSL filters (optional)
- `size`: Maximum number of results (optional, default: 100)

**Example:**
```
Query metrics data from the last hour for CPU usage
```

#### `aggregate_metrics`
Aggregate metrics data with various aggregation types.

**Parameters:**
- `index_pattern`: Index pattern for metrics (e.g., "metrics-*")
- `time_range`: Time range for aggregation
- `metric_field`: Metric field to aggregate (e.g., "system.cpu.total.pct")
- `aggregation_type`: Type of aggregation (avg, sum, min, max, percentiles, cardinality, stats, extended_stats)
- `group_by`: Field to group by (optional)
- `filters`: Additional filters (optional)

**Example:**
```
Get average CPU usage by host for the last hour
```

#### `analyze_traces`
Analyze distributed traces, find trace details, and identify performance issues.

**Parameters:**
- `index_pattern`: Index pattern for traces (e.g., "traces-*")
- `time_range`: Time range for analysis
- `trace_id`: Specific trace ID to analyze (optional)
- `service_name`: Service name to filter by (optional)
- `operation_name`: Operation name to filter by (optional)
- `size`: Maximum number of results (optional, default: 100)

**Example:**
```
Find slow traces for the payment service in the last hour
```

#### `analyze_logs`
Search and analyze log data with filtering by level, service, and content.

**Parameters:**
- `index_pattern`: Index pattern for logs (e.g., "logs-*")
- `time_range`: Time range for analysis
- `log_level`: Log level to filter by (optional)
- `service_name`: Service name to filter by (optional)
- `search_query`: Search query for log content (optional)
- `size`: Maximum number of results (optional, default: 100)

**Example:**
```
Find all ERROR logs from the API service in the last 2 hours
```

#### `health_check`
Check the health status of Elasticsearch cluster and indices.

**Parameters:**
- `index`: Optional specific index to check

**Example:**
```
Check the health of the metrics-* indices
```

### Core Tools

#### `list_indices`
List all available Elasticsearch indices.

#### `get_mappings`
Get field mappings for a specific Elasticsearch index.

#### `search`
Perform an Elasticsearch search with the provided query DSL.

#### `esql`
Perform an ES|QL query.

#### `get_shards`
Get shard information for all or specific indices.

## 📊 Example Use Cases

### 1. System Performance Monitoring

```
"Show me the average CPU usage by host for the last hour"
"Find the top 10 slowest database queries in the last 30 minutes"
"What's the memory usage trend for the last 24 hours?"
```

### 2. Error Analysis

```
"Find all ERROR logs from the last 2 hours"
"Show me failed API requests grouped by endpoint"
"What are the most common error messages in the last hour?"
```

### 3. Trace Analysis

```
"Find traces that took longer than 5 seconds in the last hour"
"Show me the trace flow for the payment service"
"What are the slowest operations in the user service?"
```

### 4. Capacity Planning

```
"Show me disk usage by index for the last week"
"What's the document count trend for the logs-* indices?"
"Find indices that are growing the fastest"
```

## 🕒 Time Range Formats

The server supports various time range formats:

- **Relative**: `now-1h`, `now-1d`, `now-1w`
- **Absolute**: `2024-01-01T00:00:00Z,2024-01-01T23:59:59Z`
- **Mixed**: `now-1h,now` (last hour to now)

## 🔍 Index Patterns

Common index patterns for observability:

- **Metrics**: `metrics-*`, `metricbeat-*`, `system-*`
- **Traces**: `traces-*`, `apm-*`, `jaeger-*`
- **Logs**: `logs-*`, `logstash-*`, `filebeat-*`

## 🛠️ Configuration

### Environment Variables

- `ES_URL`: Your Elastic Serverless endpoint URL
- `ES_API_KEY`: Your Elastic API key (recommended)
- `ES_USERNAME`: Username (alternative to API key)
- `ES_PASSWORD`: Password (alternative to API key)
- `ES_SSL_SKIP_VERIFY`: Skip SSL verification (default: false)

### Custom Configuration

You can use the `elastic-serverless-config.json5` file for advanced configuration:

```json5
{
    "elasticsearch": {
        "url": "https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud",
        "api_key": "YOUR_API_KEY",
        "tools": {
            "custom": {
                "cpu_metrics": {
                    "type": "esql",
                    "description": "Get CPU metrics for the last hour",
                    "query": "FROM metrics-* | WHERE @timestamp >= now() - 1h AND metricset.name == \"cpu\" | STATS avg(system.cpu.total.pct) AS avg_cpu BY host.name | SORT avg_cpu DESC"
                }
            }
        }
    }
}
```

## 🧪 Testing

### Test UI
Visit `http://localhost:8081` to access the test interface.

### Health Check
```bash
curl http://localhost:8080/ping
```

### MCP Endpoint Test
```bash
curl -X POST http://localhost:8080/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2025-03-26",
      "capabilities": {},
      "clientInfo": {
        "name": "test-client",
        "version": "1.0.0"
      }
    }
  }'
```

## 🚨 Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify your API key or username/password
   - Check that your credentials have the necessary permissions

2. **Connection Refused**
   - Ensure the Elastic Serverless endpoint is accessible
   - Check your network connectivity

3. **Index Not Found**
   - Verify the index pattern exists
   - Check the time range - data might not exist for that period

4. **SSL Certificate Issues**
   - Set `ES_SSL_SKIP_VERIFY=true` if needed (not recommended for production)

### Logs

View server logs:
```bash
docker-compose logs -f elasticsearch-mcp-server
```

### Debug Mode

Enable debug logging by setting the log level:
```bash
export RUST_LOG=debug
docker-compose up
```

## 📈 Performance Tips

1. **Use appropriate time ranges** - Shorter time ranges are faster
2. **Limit result sizes** - Use the `size` parameter to limit results
3. **Use specific index patterns** - More specific patterns are faster than wildcards
4. **Cache frequently used queries** - Consider using custom tools for common queries

## 🔒 Security

- Store credentials in environment variables, not in code
- Use API keys instead of username/password when possible
- Regularly rotate your API keys
- Monitor access logs for unusual activity

## 📚 Additional Resources

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [ES|QL Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/esql.html)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Cursor MCP Integration](https://docs.cursor.com/integrations/mcp)

## 🤝 Contributing

This is an enhanced version of the official Elasticsearch MCP server with observability-specific tools. Contributions are welcome!

## 📄 License

Licensed under the Apache License, Version 2.0.
