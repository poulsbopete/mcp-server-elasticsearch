# 🚀 Public Deployment Guide

This guide covers multiple options for hosting your Elasticsearch MCP server publicly, from simple cloud platforms to enterprise-grade solutions.

## 📋 Prerequisites

- Your Elasticsearch MCP server repository
- Elasticsearch API key
- Access to a deployment platform of your choice

## 🎯 Quick Deploy Options (Recommended)

### 1. 🚂 Railway (Easiest - Free Tier Available)

**Perfect for:** Quick deployment, minimal configuration

```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login and initialize
railway login
railway init

# 3. Deploy
railway up --detach

# 4. Set environment variables
railway variables set ES_URL="https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud"
railway variables set ES_API_KEY="your-api-key-here"

# 5. Get your public URL
railway status
```

**Configuration:** Uses `/deploy/railway.toml`

### 2. 🪁 Fly.io (Fast Global Edge Deployment)

**Perfect for:** Global deployment, automatic scaling

```bash
# 1. Install Fly CLI
curl -L https://fly.io/install.sh | sh

# 2. Login and launch
fly auth login
fly launch --copy-config --name elasticsearch-mcp-server

# 3. Set secrets
fly secrets set ES_URL="https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud"
fly secrets set ES_API_KEY="your-api-key-here"

# 4. Deploy
fly deploy
```

**Configuration:** Uses `/deploy/fly.toml`

### 3. 🎨 Render (Simple with Auto-Deploy)

**Perfect for:** GitHub integration, automatic deployments

1. Fork this repository to your GitHub
2. Go to [render.com](https://render.com) and connect your GitHub
3. Create a new **Web Service**
4. Select your forked repository
5. Use these settings:
   - **Runtime:** Docker
   - **Dockerfile Path:** `./Dockerfile`
   - **Build Command:** (leave empty)
   - **Start Command:** (leave empty - uses Dockerfile)

5. Add environment variables:
   - `CONTAINER_MODE` = `true`
   - `HTTP_ADDRESS` = `0.0.0.0:8080`
   - `ES_URL` = `https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud`
   - `ES_API_KEY` = `your-api-key-here` (mark as secret)

**Configuration:** Uses `/deploy/render.yaml` for Infrastructure as Code

## 🏢 Enterprise Options

### 4. ☁️ AWS ECS Fargate

**Perfect for:** AWS ecosystem, enterprise requirements

```bash
# 1. Build and push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

docker build -t elasticsearch-mcp-server .
docker tag elasticsearch-mcp-server:latest YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/elasticsearch-mcp-server:latest
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/elasticsearch-mcp-server:latest

# 2. Create task definition
aws ecs register-task-definition --cli-input-json file://deploy/ecs-task-definition.json

# 3. Create service
aws ecs create-service \
    --cluster your-cluster \
    --service-name elasticsearch-mcp-server \
    --task-definition elasticsearch-mcp-server \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

**Configuration:** Uses `/deploy/ecs-task-definition.json`

### 5. ⚙️ Kubernetes

**Perfect for:** Kubernetes environments, maximum control

```bash
# 1. Apply the configuration
kubectl apply -f deploy/kubernetes.yaml

# 2. Update the secret with your credentials
kubectl patch secret elasticsearch-credentials -p='{"stringData":{"es-api-key":"your-actual-api-key"}}'

# 3. Get external IP
kubectl get service elasticsearch-mcp-server-service
```

**Configuration:** Uses `/deploy/kubernetes.yaml`

### 6. 🐳 Docker on VPS

**Perfect for:** DigitalOcean, Linode, or any VPS

```bash
# 1. On your VPS, clone the repo
git clone https://github.com/your-username/mcp-server-elasticsearch.git
cd mcp-server-elasticsearch

# 2. Create environment file
cat > .env << EOF
ES_URL=https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud
ES_API_KEY=your-api-key-here
EOF

# 3. Deploy with cloud-optimized compose
docker-compose -f deploy/docker-compose.cloud.yml up -d

# 4. Set up reverse proxy (nginx example)
sudo apt install nginx certbot python3-certbot-nginx
# Configure nginx to proxy to localhost:80
sudo certbot --nginx -d yourdomain.com
```

**Configuration:** Uses `/deploy/docker-compose.cloud.yml`

## 🔧 Configuration Details

### Environment Variables

All deployments require these environment variables:

```bash
# Required
ES_URL="https://otel-demo-a5630c.kb.us-east-1.aws.elastic.cloud"
ES_API_KEY="your-elasticsearch-api-key"

# Platform-specific
CONTAINER_MODE="true"                 # Always set for containerized deployments
HTTP_ADDRESS="0.0.0.0:8080"         # Bind to all interfaces for public access
```

### Health Check Endpoint

All platforms use the health check endpoint:
- **URL:** `https://your-domain.com/ping`
- **Expected Response:** `200 OK`

### MCP Endpoint

Your MCP server will be available at:
- **URL:** `https://your-domain.com/mcp`
- **Protocol:** Streamable HTTP

## 🔗 Client Configuration

Once deployed, update your MCP client (like Cursor) to use the public endpoint:

```json
{
  "mcpServers": {
    "elasticsearch-observability": {
      "command": "npx",
      "args": [
        "@modelcontextprotocol/client-axios",
        "https://your-deployed-url.com/mcp"
      ]
    }
  }
}
```

## 🔒 Security Considerations

### 🛡️ API Key Security
- **Never** commit API keys to repositories
- Use platform-specific secret management:
  - Railway: `railway variables set`
  - Fly.io: `fly secrets set`
  - Render: Environment variables marked as "secret"
  - AWS: Systems Manager Parameter Store / Secrets Manager
  - Kubernetes: Secrets

### 🌐 Network Security
- All platforms provide HTTPS by default
- Consider IP allowlisting if needed
- Monitor access logs for unusual activity

### 🔐 Authentication
The MCP server doesn't have built-in authentication. Consider:
- Running behind a reverse proxy with auth
- Using a VPN for access restriction
- Implementing IP allowlisting at the platform level

## 📊 Monitoring and Maintenance

### 📈 Health Monitoring
All deployment configs include health checks. Monitor:
- `/ping` endpoint availability
- Response times
- Error rates

### 📝 Logging
Access logs through platform-specific tools:
- **Railway:** `railway logs`
- **Fly.io:** `fly logs`
- **Render:** Dashboard logs section
- **AWS:** CloudWatch logs
- **Kubernetes:** `kubectl logs`

### 🔄 Updates
For automatic deployments:
1. **Railway/Render:** Push to main branch
2. **Fly.io:** `fly deploy`
3. **AWS:** Update task definition and service
4. **Kubernetes:** `kubectl rollout restart deployment/elasticsearch-mcp-server`

## 💰 Cost Comparison

| Platform | Free Tier | Paid Tier | Best For |
|----------|-----------|-----------|----------|
| Railway | 5 USD/month credits | $5+/month | Quick start |
| Fly.io | Generous free tier | $2+/month | Global deployment |
| Render | Free (limitations) | $7+/month | Auto-deploy from GitHub |
| AWS ECS | Pay per use | Variable | Enterprise/existing AWS |
| DigitalOcean | - | $5+/month | Full control |

## 🆘 Troubleshooting

### Common Issues

1. **502 Bad Gateway**
   - Check health endpoint: `curl https://your-url.com/ping`
   - Verify `HTTP_ADDRESS=0.0.0.0:8080` is set
   - Check container logs

2. **Elasticsearch Connection Failed**
   - Verify `ES_URL` and `ES_API_KEY` are correct
   - Test connection: `curl -H "Authorization: ApiKey $ES_API_KEY" $ES_URL/_cluster/health`

3. **MCP Client Can't Connect**
   - Ensure URL is `https://your-domain.com/mcp` (not just `/`)
   - Check CORS settings if accessing from browser
   - Verify the server is responding: `curl https://your-url.com/mcp`

### Getting Help
- Check platform-specific logs
- Verify environment variables are set correctly
- Test the health endpoint first
- Confirm Elasticsearch connectivity

---

🎉 **You're ready to deploy!** Choose the platform that best fits your needs and follow the corresponding guide above.
