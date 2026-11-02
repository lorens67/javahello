pipeline {
    agent any

    environment {
        GIT_REPOSITORY_URL = 'https://github.com/lorens67/javahello.git'
        DOCKER_IMAGE_NAME = '25122004/docker_jenkins_java'
        IMAGE_TAG = '1.0'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    try {
                        git branch: 'main', url: GIT_REPOSITORY_URL
                    } catch (Exception e) {
                        echo "Failed to clone repository: ${e.message}"
                        error "Failed to clone repository"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}")
                    } catch (Exception e) {
                        echo "Failed to build Docker image: ${e.message}"
                        error "Failed to build Docker image"
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'my-docker-hub-credentials-id',
                                                         usernameVariable: 'DOCKER_USERNAME',
                                                         passwordVariable: 'DOCKER_PASSWORD')]) {
                            sh '''
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                            '''
                            sh "docker push ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                        }
                    } catch (Exception e) {
                        echo "Failed to push Docker image to registry: ${e.message}"
                        error "Failed to push Docker image"
                    }
                }
            }
        }

        stage('Pull Image from DockerHub') {
            steps {
                script {
                    try {
                        sh "docker pull ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                    } catch (Exception e) {
                        echo "Failed to pull Docker image: ${e.message}"
                        error "Failed to pull Docker image"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        sh 'kubectl apply -f k8s-deployment.yaml'
                        sh 'kubectl rollout restart deployment/javahello'
                    } catch (Exception e) {
                        echo "Failed to deploy to Kubernetes: ${e.message}"
                        error "Failed to deploy to Kubernetes"
                    }
                }
            }
        }

        stage('Verify Pod Running') {
            steps {
                script {
                    try {
                        sh 'kubectl rollout status deployment/javahello --timeout=120s'
                        sh 'kubectl wait --for=condition=Ready pod -l app=javahello --timeout=60s'
                        sh 'kubectl get pods -l app=javahello -o wide'
                        sh 'kubectl get svc javahello-service'
                        sh 'kubectl logs -l app=javahello --tail=5'
                    } catch (Exception e) {
                        sh 'kubectl describe pods -l app=javahello || true'
                        error "Pod verification failed: ${e.message}"
                    }
                }
            }
        }
    }
}
