# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. **Choose Your Deployment**

#### Option A: Cloud (Railway) - Recommended
```bash
# 1. Fork this repo and connect to Railway
# 2. Set environment variables in Railway dashboard:
#    ES_URL=your-elasticsearch-url
#    ES_API_KEY=your-api-key
# 3. Deploy!
```

#### Option B: Local Development
```bash
git clone https://github.com/poulsbopete/mcp-server-elasticsearch.git
cd mcp-server-elasticsearch
cp .env-example .env
# Edit .env with your Elasticsearch credentials
cargo build --release
```

### 2. **Configure Your AI Client**

#### ✅ **Cursor** (HTTP/SSE)
Add to your `~/.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "elasticsearch-observability": {
      "url": "https://your-app.up.railway.app/mcp/sse"
    }
  }
}
```

#### ✅ **Claude Desktop** (stdio)
**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
```json
{
  "mcpServers": {
    "elasticsearch-observability": {
      "command": "/path/to/elasticsearch-core-mcp-server",
      "args": ["stdio"],
      "env": {
        "ES_URL": "your-elasticsearch-url",
        "ES_API_KEY": "your-api-key"
      }
    }
  }
}
```

#### ✅ **ChatGPT** (CLI Bridge)
```bash
# Make executable
chmod +x es-query.sh

# Get recent errors
./es-query.sh errors

# Copy JSON output to ChatGPT with:
# "Analyze this Elasticsearch data: [paste results]"
```

### 3. **Test Your Setup**

#### Test Commands:
- **Cursor**: "Show me recent errors from my logs"
- **Claude Desktop**: "What Elasticsearch indices are available?"  
- **ChatGPT**: Run `./es-query.sh health` → copy to ChatGPT

### 4. **Example Queries**

```typescript
// Find application errors
await analyze_logs({
  index_pattern: "logs-*",
  time_range: "now-24h",
  log_level: "error"
});

// Analyze performance traces  
await analyze_traces({
  index_pattern: "traces-*", 
  service_name: "api-server",
  time_range: "now-1h"
});

// Get CPU metrics
await aggregate_metrics({
  metric_field: "system.cpu.total.pct",
  aggregation_type: "avg",
  time_range: "now-6h"
});
```

## 🔧 Troubleshooting

### **Common Issues:**

1. **"No tools available"** → Check environment variables (ES_URL, ES_API_KEY)
2. **"Connection refused"** → Verify Elasticsearch URL is accessible
3. **"Authentication failed"** → Check API key permissions
4. **"Index not found"** → Verify index patterns match your data

### **Debug Commands:**
```bash
# Test Elasticsearch connection
curl -H "Authorization: ApiKey YOUR_KEY" "YOUR_ES_URL"

# Check MCP server health
curl https://your-app.up.railway.app/ping

# Local server logs
RUST_LOG=debug ./target/release/elasticsearch-core-mcp-server stdio
```

## 🎯 Next Steps

1. **Explore Tools**: Try different analysis tools with your data
2. **Custom Queries**: Use ES|QL for advanced analytics
3. **Monitor Setup**: Set up alerts for critical errors
4. **Scale Up**: Deploy to production with proper monitoring

**Need help?** Check the main [README.md](README.md) for detailed documentation!