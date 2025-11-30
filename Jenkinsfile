
pipeline {
    agent any
    
    environment {
        // Git user who triggered the build
        GIT_COMMITTER_EMAIL = sh(
            script: "git log -1 --pretty=format:'%ae'",
            returnStdout: true
        ).trim()
        GIT_COMMITTER_NAME = sh(
            script: "git log -1 --pretty=format:'%an'",
            returnStdout: true
        ).trim()
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching code from GitHub...'
                checkout scm
                echo 'Code fetched successfully!'
                script {
                    echo "Build triggered by: ${GIT_COMMITTER_NAME} (${GIT_COMMITTER_EMAIL})"
                }
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
        
        stage('Health Check Tests') {
            steps {
                echo 'Running health check tests in containerized environment...'
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
        
        stage('Run Selenium Tests') {
            steps {
                echo 'Running Selenium automated test cases...'
                script {
                    try {
                        sh """
                            # Navigate to test directory
                            cd tests
                            
                            # Build test Docker image
                            echo "Building test Docker image with Chrome and ChromeDriver..."
                            docker build -t mern-chatbot-selenium-tests .
                            
                            # Run Selenium tests in Docker container
                            echo "Running Selenium tests in headless Chrome..."
                            docker run --rm \
                                --network="host" \
                                -e BASE_URL=http://localhost:5174 \
                                -e BACKEND_URL=http://localhost:5001 \
                                -e HEADLESS=true \
                                -v \$(pwd)/reports:/app/reports \
                                mern-chatbot-selenium-tests
                            
                            echo "Selenium tests completed successfully!"
                        """
                    } catch (Exception e) {
                        echo "Selenium tests failed: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                        error("Selenium tests failed")
                    }
                }
            }
        }
        
        stage('Archive Test Results') {
            steps {
                echo 'Archiving test results and reports...'
                script {
                    // Archive HTML test report
                    archiveArtifacts artifacts: 'tests/reports/**/*', allowEmptyArchive: true
                    
                    // Publish HTML report
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'tests/reports',
                        reportFiles: 'test_report.html',
                        reportName: 'Selenium Test Report',
                        reportTitles: 'Selenium Test Results'
                    ])
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
                // Show logs if needed
                sh 'docker-compose -f docker-compose-ci.yml logs --tail=50 || true'
                
                // Send email notification
                def testResults = "Test results are attached. Please check Jenkins for detailed report."
                def buildStatus = currentBuild.result ?: 'SUCCESS'
                def buildUrl = env.BUILD_URL
                
                emailext(
                    subject: "Jenkins Build ${buildStatus}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        <html>
                        <body>
                            <h2>Jenkins Build Notification</h2>
                            <p><strong>Project:</strong> ${env.JOB_NAME}</p>
                            <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                            <p><strong>Build Status:</strong> <span style="color: ${buildStatus == 'SUCCESS' ? 'green' : 'red'}; font-weight: bold;">${buildStatus}</span></p>
                            <p><strong>Triggered by:</strong> ${GIT_COMMITTER_NAME} (${GIT_COMMITTER_EMAIL})</p>
                            <p><strong>Build URL:</strong> <a href="${buildUrl}">${buildUrl}</a></p>
                            <p><strong>Test Report:</strong> <a href="${buildUrl}Selenium_20Test_20Report/">View Selenium Test Report</a></p>
                            <hr>
                            <h3>Test Summary</h3>
                            <p>${testResults}</p>
                            <hr>
                            <p><em>This is an automated message from Jenkins CI/CD pipeline.</em></p>
                        </body>
                        </html>
                    """,
                    mimeType: 'text/html',
                    to: "qasimalik@gmail.com, hassansarfraz030@gmail.com",
                    replyTo: "qasimalik@gmail.com",
                    attachLog: true,
                    attachmentsPattern: 'tests/reports/test_report.html'
                )
            }
        }
        success {
            echo 'Pipeline completed successfully! ✅'
            echo 'Containerized environment is UP and RUNNING!'
            echo 'Selenium tests passed!'
            echo 'Email notification sent to collaborator.'
        }
        failure {
            echo 'Pipeline failed! ❌'
            echo 'Email notification sent to collaborator.'
            echo 'Cleaning up failed containers...'
            sh 'docker-compose -f docker-compose-ci.yml down || true'
        }
        unstable {
            echo 'Pipeline completed with test failures! ⚠️'
            echo 'Email notification sent to collaborator.'
        }
    }
}
