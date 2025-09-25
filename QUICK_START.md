# 🚀 Quick Start Guide

Get your Elasticsearch MCP server running for observability in 5 minutes!

## Step 1: Set Your Credentials

Edit the `.env` file with your Elastic Serverless credentials:

```bash
# Replace with your actual API key
ES_API_KEY=your_actual_api_key_here
```

## Step 2: Start the Server

```bash
./setup-observability.sh
```

## Step 3: Test It Works

Visit: http://localhost:8081

## Step 4: Configure Cursor

Add this to your Cursor MCP config:

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
        "ES_API_KEY": "YOUR_ACTUAL_API_KEY_HERE"
      }
    }
  }
}
```

## Step 5: Start Using in Cursor!

Try these example queries in Cursor:

- "Show me CPU usage for the last hour"
- "Find error logs from the last 2 hours"
- "What are the slowest traces in the last 30 minutes?"
- "Check the health of my Elasticsearch cluster"

## 🎉 You're Ready!

Your MCP server is now providing observability tools to Cursor. You can query your metrics, traces, and logs using natural language!
