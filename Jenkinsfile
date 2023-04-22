pipeline {
    environment {
        IMAGE_NAME = "alpinehelloworld"
        IMAGE_TAG = "latest"
        STAGING = "doukanifr-staging"
        PRODUCTION = "doukanifr-production"
    }

    agent none

    stages {
        stage('Build image') {
            agent any
            steps {
                withCredentials([string(credentialsId: 'my_dockerhub', variable: 'DOCKER_PASSWORD')]) {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }
        stage('Run container') {
            agent any
            steps {
                sh '''
                    docker container prune -f
                    docker rm -f ${IMAGE_NAME}
                    docker run -d -p 80:5000 -e PORT=5000 --name ${IMAGE_NAME} ${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 5
                '''
            }
        }
        stage('Test application') {
            agent any
            steps {
                sh 'curl http://192.168.56.12 | grep -q "Hello world!"'
            }
        }
        stage('Clean environment') {
            agent any
            steps {
                sh 'docker rm -f ${IMAGE_NAME}'
            }
        }
        stage('Push image') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            agent any
            steps {
//                withCredentials([string(credentialsId: 'pass_docker_hub', variable: 'DOCKER_PASSWORD')]) {
                withCredentials([dockerhubcreds(credentialsId: 'my_dockerhub', usernameVariable: 'COMPANY_NAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        docker image tag ${IMAGE_NAME}:${IMAGE_TAG} ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker login -u ${COMPANY_NAME} -p ${DOCKER_PASSWORD}
                        docker push ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }
        stage('Remove docker cache') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'docker image prune -af'
            }
        }
        stage('Deploy staging app') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh '''
                    docker rm -f ${STAGING}
                    docker run -d -p 81:5000 -e PORT=5000 --name ${STAGING} ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 10
                '''
            }
        }
        stage('Test staging app') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'curl https://${STAGING}.loca.lt | grep -q "Hello world!"'
            }
        }
        stage('Deploy production app') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh '''
                    docker rm -f ${PRODUCTION}
                    docker run -d -p 82:5000 -e PORT=5000 --name ${PRODUCTION} ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    sleep 10
                '''
            }
        }
        stage('Test production app') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'curl https://${PRODUCTION}.loca.lt | grep -q "Hello world!"'
            }
        }
    }
}