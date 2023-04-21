pipeline {
    environment {
        IMAGE_NAME = "alpinehelloworld"
        IMAGE_TAG = "latest"
        STAGING = "doukanifr-staging"
        PRODUCTION = "doukanifr-production"
            withCredentials([dockerhubcreds(credentialsId: 'my_dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                withEnv(["COMPANY_USERNAME=${DOCKER_USERNAME}", "PASSWORD=${DOCKER_PASSWORD}"]) {
                }
            }
    }
    agent none

    stages {
        stage('Build image') {
            agent any
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }
        stage('Run container') {
            agent any
            steps {
                sh '''
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
                sh '''
                    docker image tag ${IMAGE_NAME}:${IMAGE_TAG} ${COMPANY_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker login -u ${COMPANY_USERNAME} -p ${PASSWORD}
                    docker push ${COMPANY_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                '''
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
                    docker run -d -p 80:5000 -e PORT=5000 --name ${STAGING} ${COMPANY_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    lt --port 8080 --subdomain ${STAGING}
                '''
            }
        }
        stage('Test staging app') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'sh curl https://${STAGING}.loca.lt | grep -q "Hello world!"'
            }
        }
        stage('Deploy production app') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh '''
                    docker run -d -p 80:5000 -e PORT=5000 --name ${PRODUCTION} ${COMPANY_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    lt --port 8080 --subdomain ${PRODUCTION}
                '''
            }
        }
        stage('Test production app') {
            agent any
            when {
                expression { GIT_BRANCH == 'origin/master' }
            }
            steps {
                sh 'sh curl https://${PRODUCTION}.loca.lt | grep -q "Hello world!"'
            }
        }
    }
}