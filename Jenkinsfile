pipeline {
    environment {
        IMAGE_NAME = "alpinehelloworld"
        IMAGE_TAG = "latest"
        STAGING = "doukanifr-staging"
        PRODUCTION = "doukanifr-production"
        COMPANY_NAME = "abdelhad"
    }

    agent any

    stages {
        stage('Var testing') {
            steps {
                withCredentials([string(credentialsId: 'my_dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    withEnv([
                        "USERNAME=${env.COMPANY_NAME}",
                        "PASSWORD=${env.PASSWORD}"
                ]) {
                sh 'echo ${USERNAME}; echo ${PASSWORD}'
                    }
                }
            }
        }
        stage('Build image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }
        stage('Run container') {
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
            steps {
                sh 'curl http://192.168.56.12 | grep -q "Hello world!"'
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
                withCredentials([string(credentialsId: 'pass_docker_hub', variable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        docker image tag ${IMAGE_NAME}:${IMAGE_TAG} ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker login -u ${COMPANY_NAME} -p ${DOCKER_PASSWORD}
                        docker push ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
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
                    docker run -d -p 81:5000 -e PORT=5000 --name ${STAGING} ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
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
                    docker run -d -p 82:5000 -e PORT=5000 --name ${PRODUCTION} ${COMPANY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
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