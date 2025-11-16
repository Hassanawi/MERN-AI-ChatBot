
pipeline {
    agent any
    
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching code from GitHub...'
                checkout scm
                echo 'Code fetched successfully!'
            }
        }
        
        stage('Build Application') {
            steps {
                echo 'Building application in containerized environment...'
                script {
                    // Start containers with code mounted as volumes
                    sh """
                        # Ensure environment is down before starting
                        docker-compose -f docker-compose-ci.yml down || true
                        
                        # Start all services (code is mounted as volumes, not built as images)
                        docker-compose -f docker-compose-ci.yml up -d
                        
                        echo "Waiting for services to start..."
                        sleep 20
                        
                        # Check service status
                        docker-compose -f docker-compose-ci.yml ps
                        
                        echo "Build phase completed - application running in containerized environment"
                    """
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running tests in containerized environment...'
                script {
                    sh """
                        # Wait for services to be fully ready
                        echo "Waiting for backend to be ready..."
                        for i in {1..12}; do
                            if docker ps | grep -q 'mern-chatbot-backend-ci.*Up'; then
                                echo "Backend container is running"
                                sleep 5
                                break
                            fi
                            echo "Waiting for backend... (attempt \$i/12)"
                            sleep 5
                        done
                        
                        # Verify all containers are running
                        echo "Verifying all services..."
                        docker ps | grep mern-chatbot-mongo-ci
                        docker ps | grep mern-chatbot-backend-ci
                        docker ps | grep mern-chatbot-frontend-ci
                        
                        # Test frontend accessibility
                        echo "Testing frontend..."
                        for i in {1..6}; do
                            if wget --spider --timeout=5 http://localhost:5174 2>/dev/null; then
                                echo "Frontend is accessible!"
                                break
                            fi
                            echo "Waiting for frontend... (attempt \$i/6)"
                            sleep 5
                        done
                        
                        # Show container logs for debugging
                        echo "Container status:"
                        docker-compose -f docker-compose-ci.yml ps
                        
                        echo "All services are running in containerized environment!"
                    """
                }
            }
        }
        
        stage('Application Ready') {
            steps {
                echo 'Application built and running successfully!'
                script {
                    sh """
                        echo "================================================"
                        echo "Containerized application is UP and RUNNING"
                        echo "Backend (CI): http://localhost:5001"
                        echo "Frontend (CI): http://localhost:5174"
                        echo "MongoDB (CI): localhost:27018"
                        echo "================================================"
                        
                        # Show final status
                        docker-compose -f docker-compose-ci.yml ps
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed.'
            script {
                // Show logs if failed
                sh 'docker-compose -f docker-compose-ci.yml logs --tail=50 || true'
            }
        }
        success {
            echo 'Pipeline completed successfully! ✅'
            echo 'Containerized environment is UP and RUNNING!'
            echo 'Note: Containers will remain running until manually stopped.'
        }
        failure {
            echo 'Pipeline failed! ❌'
            echo 'Cleaning up failed containers...'
            sh 'docker-compose -f docker-compose-ci.yml down || true'
        }
    }
}
