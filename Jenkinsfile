pipeline {
    environment {
        IMAGE_NAME = "alpinehelloworld"
        IMAGE_TAG = "latest"
        STAGING = "doukanifr-staging"
        PRODUCTION = "doukanifr-production"
        COMPANY_NAME = "doukanifr"
        REGISTRY_DOMAIN = "registry.loca.lt"
    }

    agent any

    stages {
        stage('Build image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }
        stage('Run container') {
            steps {
                sh '''
                    docker container prune -f
                    docker rm -f ${IMAGE_NAME} || echo "Ok : le conteneur ${IMAGE_NAME} est inexistant"
                    docker run -d -p 83:5000 -e PORT=5000 --name ${IMAGE_NAME} ${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 5
                '''
            }
        }
        stage('Test application') {
          }
          steps {
            sh "curl http://192.168.56.12 | grep -q 'Hello world!'"
          }
        }

        stage('Clean environment') {
            steps {
                sh 'docker rm -f ${IMAGE_NAME}'
            }
        }
        stage('Push image') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                withCredentials([string(credentialsId: 'pass_private_registry', variable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        docker image tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY_DOMAIN}/${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker login ${REGISTRY_DOMAIN} -u ${COMPANY_NAME} -p ${DOCKER_PASSWORD}
                        docker push ${REGISTRY_DOMAIN}/${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }
        stage('Remove docker cache') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'docker image prune -af'
            }
        }
        stage('Deploy staging app') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh '''
                    docker rm -f ${STAGING}
                    docker run -d -p 81:5000 -e PORT=5000 --name ${STAGING} ${REGISTRY_DOMAIN}/${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 10
                '''
            }
        }
        stage('Check staging app') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'curl https://${STAGING}.loca.lt | grep -q "Hello world!"'
            }
        }
        stage('Deploy production app') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh '''
                    docker rm -f ${PRODUCTION}
                    docker run -d -p 82:5000 -e PORT=5000 --name ${REGISTRY_DOMAIN}/${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 10
                '''
            }
        }
        stage('Check production app') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'curl https://${PRODUCTION}.loca.lt | grep -q "Hello world!"'
            }
        }
    }
}