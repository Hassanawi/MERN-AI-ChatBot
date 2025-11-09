pipeline {
    agent any
    
    environment {
        // Docker Hub credentials (configure these in Jenkins credentials)
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_HUB_USERNAME = "hsk09"
        
        // Image names
        BACKEND_IMAGE = "hsk09/mern-chatbot-backend"
        FRONTEND_IMAGE = "hsk09/mern-chatbot-frontend"
        
        // Image tags
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        LATEST_TAG = "latest"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build Backend Image') {
            steps {
                echo 'Building backend Docker image...'
                dir('backend') {
                    script {
                        sh """
                            docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:${LATEST_TAG} .
                        """
                    }
                }
            }
        }
        
        stage('Build Frontend Image') {
            steps {
                echo 'Building frontend Docker image...'
                dir('frontend') {
                    script {
                        sh """
                            docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:${LATEST_TAG} .
                        """
                    }
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                script {
                    // Start services using docker-compose-ci.yml
                    sh """
                        docker-compose -f docker-compose-ci.yml up -d
                        sleep 10
                        
                        # Check if services are running
                        docker-compose -f docker-compose-ci.yml ps
                        
                        # Test backend health endpoint
                        curl -f http://localhost:5001/api/v1 || exit 1
                        
                        # Test frontend is accessible
                        curl -f http://localhost:5174 || exit 1
                        
                        echo "All services are healthy!"
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                script {
                    sh """
                        echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_USERNAME} --password-stdin
                        
                        docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                        docker push ${BACKEND_IMAGE}:${LATEST_TAG}
                        
                        docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                        docker push ${FRONTEND_IMAGE}:${LATEST_TAG}
                        
                        docker logout
                    """
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                script {
                    // Pull and restart services with new images
                    sh """
                        docker-compose -f docker-compose-ci.yml down
                        docker-compose -f docker-compose-ci.yml pull
                        docker-compose -f docker-compose-ci.yml up -d
                        
                        echo "Deployment completed successfully!"
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            script {
                // Stop and remove containers
                sh 'docker-compose -f docker-compose-ci.yml down || true'
                
                // Remove dangling images
                sh 'docker image prune -f || true'
            }
        }
        success {
            echo 'Pipeline completed successfully! ✅'
        }
        failure {
            echo 'Pipeline failed! ❌'
        }
    }
}
