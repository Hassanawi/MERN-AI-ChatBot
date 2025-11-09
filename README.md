# MERN AI ChatBot - DevOps Assignment

A full-stack MERN (MongoDB, Express, React, Node.js) chatbot application integrated with OpenRouter AI models, containerized with Docker and automated with Jenkins CI/CD.

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐
│   Frontend  │────▶│   Backend   │────▶│   MongoDB    │
│  (React +   │     │  (Express + │     │   Database   │
│   Vite)     │     │   Node.js)  │     │              │
└─────────────┘     └─────────────┘     └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  OpenRouter  │
                    │  AI Models   │
                    └──────────────┘
```

## 📋 Prerequisites

- **Docker** and **Docker Compose** installed
- **Node.js 18+** (for local development)
- **MongoDB** (local instance or Docker)
- **Jenkins** (for CI/CD pipeline)
- **Docker Hub account** (for image registry)
- **OpenRouter API key** (free tier available)

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git
   cd MERN-AI-ChatBot
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

3. **Build and run with Docker Compose**
   ```bash
   docker-compose build
   docker-compose up -d
   ```

4. **Access the application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:5000
   - MongoDB: localhost:27017

### Option 2: Local Development

#### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your values
npm run dev
```

#### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

## 🐳 Docker Configuration

### Part I: Development Docker Compose

File: `docker-compose.yml`

Services:
- **mongo**: MongoDB 7.0 on port 27017
- **backend**: Node.js backend on port 5000
- **frontend**: React frontend on port 5173

```bash
# Build images
docker-compose build

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Part II: CI/CD Docker Compose

File: `docker-compose-ci.yml`

Uses different ports to avoid conflicts:
- **mongo-ci**: Port 27018
- **backend-ci**: Port 5001
- **frontend-ci**: Port 5174

```bash
# Run CI/CD compose
docker-compose -f docker-compose-ci.yml up -d
```

## 🔧 Jenkins Pipeline

### Setup Jenkins

1. **Install Jenkins plugins**
   - Docker Pipeline
   - Docker
   - Git
   - Credentials Binding

2. **Configure Docker Hub credentials**
   - Go to Jenkins → Manage Jenkins → Credentials
   - Add new credentials:
     - ID: `dockerhub-credentials`
     - Type: Username with password
     - Username: Your Docker Hub username
     - Password: Your Docker Hub password

3. **Create new Pipeline job**
   - New Item → Pipeline
   - Pipeline script from SCM
   - Repository URL: Your Git repo
   - Script path: `Jenkinsfile`

### Pipeline Stages

1. **Checkout**: Clone repository
2. **Build Backend Image**: Build backend Docker image
3. **Build Frontend Image**: Build frontend Docker image
4. **Run Tests**: Start services and run health checks
5. **Push to Docker Hub**: Push images to registry
6. **Deploy**: Deploy with latest images

### Environment Variables for Jenkins

Configure these in Jenkins job or system environment:
```
DOCKER_HUB_USERNAME=your-username
OPEN_AI_SECRET=your-openrouter-key
JWT_SECRET=your-jwt-secret
COOKIE_SECRET=your-cookie-secret
```

## 🌐 Deployment to Cloud (AWS EC2)

### 1. Launch EC2 Instance

- **AMI**: Ubuntu 22.04 LTS
- **Instance Type**: t2.medium (minimum)
- **Security Groups**:
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 443 (HTTPS)
  - Port 5000 (Backend API)
  - Port 5173 (Frontend)

### 2. Install Docker on EC2

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install Docker
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

### 3. Deploy Application

```bash
# Clone repository
git clone https://github.com/Hassanawi/MERN-AI-ChatBot.git
cd MERN-AI-ChatBot

# Create .env file
nano .env
# Add your environment variables

# Pull images from Docker Hub
docker-compose pull

# Start services
docker-compose up -d

# Check logs
docker-compose logs -f
```

### 4. Configure Nginx (Optional)

For production, use Nginx as reverse proxy:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
    }
}
```

## 🔐 Environment Variables

### Backend (.env)

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `MONGODB_URL` | MongoDB connection string | ✅ | `mongodb://localhost:27017/mernai_chatbot` |
| `JWT_SECRET` | Secret for JWT tokens | ✅ | - |
| `COOKIE_SECRET` | Secret for cookie signing | ✅ | - |
| `OPEN_AI_SECRET` | OpenRouter API key | ✅ | - |
| `OPENROUTER_BASE` | OpenRouter base URL | ❌ | `https://openrouter.ai/api/v1` |
| `OPENROUTER_MODEL` | Default AI model | ❌ | `google/gemini-2.0-flash-exp:free` |
| `OPEN_AI_STRICT` | Disable fallback (0 or 1) | ❌ | `0` |
| `PORT` | Backend port | ❌ | `5000` |

### Docker Compose

| Variable | Description | Required |
|----------|-------------|----------|
| `DOCKER_HUB_USERNAME` | Your Docker Hub username | ✅ |

## 🧪 Testing

### Manual Testing

1. **Backend health check**
   ```bash
   curl http://localhost:5000/api/v1
   ```

2. **Test OpenRouter integration**
   ```bash
   cd backend
   node scripts/test-openrouter.js
   ```

3. **Access frontend**
   - Open http://localhost:5173
   - Sign up for new account
   - Login and test chat functionality

### Docker Testing

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs backend
docker-compose logs frontend

# Test backend
curl http://localhost:5000/api/v1

# Stop services
docker-compose down
```

## 📊 Available OpenRouter Models (Free Tier)

- `google/gemini-2.0-flash-exp:free` (Recommended)
- `openai/gpt-oss-20b:free` (AtlasCloud)
- `gpt-3.5-turbo` (Limited free tier)

To check available models with your API key:
```bash
cd backend
node scripts/test-openrouter.js
```

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check MongoDB is running
docker-compose ps mongo

# Check backend logs
docker-compose logs backend

# Verify environment variables
cat backend/.env
```

### Frontend can't connect to backend
```bash
# Check backend is accessible
curl http://localhost:5000/api/v1

# Verify CORS is configured
# Check backend/src/app.ts for CORS settings
```

### OpenRouter API errors
```bash
# Test API key
cd backend
node scripts/test-openrouter.js

# Check API key is valid in .env
# Verify OPENROUTER_BASE is correct
```

### Docker build failures
```bash
# Clean Docker cache
docker system prune -a

# Rebuild with no cache
docker-compose build --no-cache
```

## 📁 Project Structure

```
MERN-AI-ChatBot/
├── backend/
│   ├── src/
│   │   ├── config/         # Configuration files
│   │   ├── controllers/    # Route controllers
│   │   ├── db/            # Database connection
│   │   ├── models/        # Mongoose models
│   │   ├── routes/        # API routes
│   │   └── utils/         # Utility functions
│   ├── Dockerfile         # Backend Docker image
│   ├── package.json       # Node.js dependencies
│   └── tsconfig.json      # TypeScript config
├── frontend/
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── context/       # Context providers
│   │   ├── helpers/       # Helper functions
│   │   └── pages/         # Page components
│   ├── Dockerfile         # Frontend Docker image
│   ├── package.json       # React dependencies
│   └── vite.config.ts     # Vite configuration
├── docker-compose.yml     # Part I - Development
├── docker-compose-ci.yml  # Part II - CI/CD
├── Jenkinsfile           # Jenkins pipeline
└── README.md             # This file
```

## 📝 Assignment Deliverables

### Part I: Dockerization
- ✅ Backend Dockerfile (multi-stage build)
- ✅ Frontend Dockerfile (nginx static serve)
- ✅ docker-compose.yml (all services)
- ✅ Documentation and instructions

### Part II: CI/CD Pipeline
- ✅ Jenkinsfile (automated pipeline)
- ✅ docker-compose-ci.yml (CI environment)
- ✅ Docker Hub integration
- ✅ Deployment automation

### Screenshots Needed
1. Jenkins pipeline successful execution
2. Docker containers running (`docker ps`)
3. Application working (login + chat)
4. Backend logs showing OpenRouter responses
5. Docker Hub showing pushed images

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is created for educational purposes as part of a DevOps assignment.

## 👤 Author

**Hassan Awi**
- GitHub: [@Hassanawi](https://github.com/Hassanawi)

## 🙏 Acknowledgments

- OpenRouter for free AI model access
- MongoDB for database
- Docker for containerization
- Jenkins for CI/CD automation
