# Elasticsearch MCP Server

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Rust](https://img.shields.io/badge/rust-1.70+-orange.svg)](https://www.rust-lang.org/)
[![MCP](https://img.shields.io/badge/MCP-2025--03--26-green.svg)](https://modelcontextprotocol.io/)

A powerful **Model Context Protocol (MCP) server** that provides AI assistants with comprehensive access to **Elasticsearch clusters**. Supports both **standard Elasticsearch** and **Elasticsearch Serverless**, with specialized tools for **observability, logging, tracing, and metrics analysis**.

## 🚀 Features

### 🔍 **Core Elasticsearch Operations**
- **Index Management**: List indices, get mappings, health checks
- **Search & Query**: Full Query DSL support + ES|QL queries
- **Data Exploration**: Flexible search with field filtering

### 📊 **Observability & Analytics**
- **Log Analysis**: Search, filter, and analyze application logs
- **Distributed Tracing**: Analyze traces, find performance bottlenecks  
- **Metrics Aggregation**: Time-series metrics with multiple aggregation types
- **Error Detection**: Intelligent error pattern analysis
- **Health Monitoring**: Cluster and index health assessment

### 🌐 **Multi-Client Support**
- **✅ Cursor**: HTTP/SSE protocol (Production ready)
- **✅ Claude Desktop**: stdio protocol (Local deployment)  
- **✅ ChatGPT**: Command-line bridge (Copy-paste workflow)

## 📦 Installation & Deployment

### 🚢 **Production Deployment (Railway)**

**One-click deploy to Railway:**

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/your-template)

**Manual Railway Deployment:**
```bash
# 1. Clone repository
git clone https://github.com/poulsbopete/mcp-server-elasticsearch.git
cd mcp-server-elasticsearch

# 2. Deploy to Railway
railway login
railway variables set ES_URL="your-elasticsearch-url" ES_API_KEY="your-api-key"
railway up
```

**Required Environment Variables:**
- `ES_URL` - Your Elasticsearch cluster URL
- `ES_API_KEY` - Elasticsearch API key for authentication  
- `ES_USERNAME` - Alternative to API key (optional)
- `ES_PASSWORD` - Required if using username auth (optional)
- `ES_SSL_SKIP_VERIFY` - Skip SSL verification (default: false)

### 🏠 **Local Development**

**Prerequisites:**
- Rust 1.70+ (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`)
- Elasticsearch cluster access

**Quick Start:**
```bash
# 1. Clone and build
git clone https://github.com/poulsbopete/mcp-server-elasticsearch.git
cd mcp-server-elasticsearch
cargo build --release

# 2. Configure environment
cp .env-example .env
# Edit .env with your Elasticsearch details

# 3. Run server
# HTTP mode (for Cursor)
cargo run --bin elasticsearch-core-mcp-server -- http

# stdio mode (for Claude Desktop)
cargo run --bin elasticsearch-core-mcp-server -- stdio
```

## 🔧 Client Configuration

### **Cursor Setup** ⚡
Add to your `mcp.json`:
```json
{
  "mcpServers": {
    "elasticsearch-observability": {
      "url": "https://your-railway-app.up.railway.app/mcp/sse"
    }
  }
}
```

### **Claude Desktop Setup** 🎯
Add to `claude_desktop_config.json`:
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

**Config Locations:**
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

### **ChatGPT Integration** 💬
Use the command-line bridge:
```bash
# Get recent errors
./es-query.sh errors

# Copy JSON output and paste into ChatGPT with:
# "Analyze this Elasticsearch data: [paste results]"
```

## 🛠️ Available Tools

### **Core Tools**
| Tool | Description | Usage |
|------|-------------|-------|
| `list_indices` | List all available indices | `list_indices(index_pattern="logs-*")` |
| `get_mappings` | Get field mappings for index | `get_mappings(index="logs-app")` |
| `search` | Query DSL search | `search(index="logs-*", query_body={...})` |
| `esql` | ES\|QL queries | `esql(query="FROM logs-* \| LIMIT 10")` |
| `health_check` | Cluster health status | `health_check()` |

### **Observability Tools**
| Tool | Description | Usage |
|------|-------------|-------|
| `query_observability_data` | Time-based data queries | `query_observability_data(index_pattern="logs-*", time_range="now-1h")` |
| `analyze_logs` | Smart log analysis | `analyze_logs(index_pattern="logs-*", log_level="error", time_range="now-24h")` |
| `analyze_traces` | Distributed trace analysis | `analyze_traces(index_pattern="traces-*", service_name="api", time_range="now-1h")` |
| `aggregate_metrics` | Metrics aggregation | `aggregate_metrics(metric_field="cpu.usage", aggregation_type="avg", time_range="now-1h")` |

## 📖 Usage Examples

### **Error Analysis**
```typescript
// Find recent application errors
await analyze_logs({
  index_pattern: "logs-*",
  time_range: "now-24h", 
  log_level: "error",
  service_name: "api-server"
});
```

### **Performance Investigation**
```typescript
// Analyze slow traces
await analyze_traces({
  index_pattern: "traces-*",
  time_range: "now-1h",
  service_name: "checkout-service"
});
```

### **Metrics Analysis**
```typescript
// CPU usage trends
await aggregate_metrics({
  index_pattern: "metrics-*",
  metric_field: "system.cpu.total.pct",
  aggregation_type: "avg",
  group_by: "host.name",
  time_range: "now-6h"
});
```

### **Advanced ES|QL Queries**
```sql
-- Top error services in last hour
FROM logs-* 
| WHERE @timestamp >= NOW() - 1 hour AND log.level == "error"
| STATS error_count = COUNT(*) BY service.name 
| SORT error_count DESC 
| LIMIT 10
```

## 🔐 Security & Authentication

### **Elasticsearch Serverless**
```bash
ES_URL="https://your-deployment.es.region.aws.elastic.cloud"
ES_API_KEY="your-encoded-api-key"
```

### **Self-Managed Elasticsearch**
```bash
ES_URL="https://your-elasticsearch:9200"
ES_USERNAME="elastic" 
ES_PASSWORD="your-password"
# OR
ES_API_KEY="your-api-key"
```

### **SSL Configuration**
```bash
# Skip SSL verification (development only)
ES_SSL_SKIP_VERIFY="true"
```

## 🌟 Architecture

```
┌─────────────────┐    HTTP/SSE     ┌──────────────┐
│     Cursor      │ ──────────────► │   Railway    │
│                 │                 │  (HTTP Mode) │
└─────────────────┘                 └──────────────┘
                                             │
                                             ▼
                                    ┌──────────────┐
                                    │ Elasticsearch│
                                    │   Cluster    │
                                    └──────────────┘
                                             ▲
┌─────────────────┐    stdio       ┌──────────────┐
│ Claude Desktop  │ ──────────────► │    Local     │
│                 │                 │ (stdio Mode) │
└─────────────────┘                 └──────────────┘

┌─────────────────┐  Copy/Paste    ┌──────────────┐
│   ChatGPT       │ ──────────────► │ CLI Bridge   │
│                 │                 │   Script     │
└─────────────────┘                 └──────────────┘
```

## 🚀 Deployment Options

### **☁️ Cloud Platforms**
- **✅ Railway** - One-click deployment (recommended)
- **Docker** - Multi-platform container support
- **Kubernetes** - Scalable cluster deployment  
- **AWS ECS** - Amazon container orchestration
- **Fly.io** - Edge deployment
- **Render** - Simple cloud hosting

### **🐳 Docker Deployment**
```bash
# Build image
docker build -t elasticsearch-mcp .

# Run with environment variables
docker run -e ES_URL="your-url" -e ES_API_KEY="your-key" -p 8080:8080 elasticsearch-mcp
```

### **⚙️ Configuration Files**

**JSON5 Configuration** (`elastic-mcp.json5`):
```json5
{
  "elasticsearch": {
    "url": "${ES_URL}",
    "api_key": "${ES_API_KEY:}",
    "ssl_skip_verify": "${ES_SSL_SKIP_VERIFY:false}"
  }
}
```

## 🧪 Testing

**Test your MCP server:**
```bash
# Health check
curl https://your-deployment.up.railway.app/ping

# Test SSE endpoint  
curl -H "Accept: text/event-stream" https://your-deployment.up.railway.app/mcp/sse

# Local testing
cargo test
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Elastic** - For the powerful Elasticsearch platform
- **Model Context Protocol** - For the innovative AI integration framework
- **Railway** - For seamless deployment platform
- **Rust Community** - For the amazing ecosystem

## 📞 Support

- 📚 **Documentation**: [MCP Protocol Docs](https://modelcontextprotocol.io/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/poulsbopete/mcp-server-elasticsearch/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/poulsbopete/mcp-server-elasticsearch/discussions)

---

**Built with ❤️ for the AI-powered observability future**