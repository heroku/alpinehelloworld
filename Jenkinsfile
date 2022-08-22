pipeline {
   environment {
     IMAGE_NAME = "alinehelloworld"
     IMAGE_TAG = "latest"
     // le nom qui sera heberger par heroku sur environnement staging et production
     STAGING = "eazytraning-staging"  
     PRODUCTION = "eazytraning-production"
   }
   agent none
   stages {
    stage('Build image') {
          agent any  // ce stage sera executer sur la même machine avec jenkins
          steps {
             script {
               sh 'docker build -t  wachehi/$IMAGE_NAME:$IAMGE_TAG .' 
             }
         }
      }
    stage('Run container based on builded image'){
          agent any  
          steps {
             script {
               sh '''
                docker run --name $IMAGE_NAME  -d -p 80:5000 -e PORT=5000  wachehi/$IMAGE_NAME:$IAMGE_TAG
                sleep 5
               ''' 
             }
         }
   }
   stage('Test image'){
          agent any  
          steps {
             script {
               sh '''
                  curl http://192.168.56.110:8080 | grep -q "Hello world!"
               ''' 
             }
         }
   }
   stage('Clean container'){
          agent any  
          steps {
             script {
               sh '''
                  docker stop $IMAGE_NAME
                  docker rm $IMAGE_NAME
               ''' 
             }
         }
   }
   stage('Push image in stage and deploy it'){
     when {
            expression { GIT_BRANCH == 'origin/master' }
          }
     agent any
     environment {
          HEROKU_API_KEY = credentials('heroku_api_key')   // credential creer à partir de jenkins
     }                                                     // attention le token mis sur jenkins  a été généré sur heroku
                                                          // puis utilisé par credential jenkins
     steps {
             script {  // ici on va se loguer sur heroku avec login , creer le projet si il n'existe pas , pusher et deployer avec
                       // le mot clé release sur l'environement STAGING
                       // attention heroku à son propre registry ce por cela qu'on a pousser sur dockerhub
               sh '''
                  heroku container:login
                  heroku create $STAGING || echo "project already exist"  
                  heroku container:push -a $STAGING web
                  heroku container:release -a $STAGING web
               ''' 
             }
         }

   }

   stage('Push image in production and deploy it'){
     when {
            expression { GIT_BRANCH == 'origin/master' }
          }
     agent any
     environment {
          HEROKU_API_KEY = credentials('heroku_api_key')   // credential creer à partir de jenkins
     }                                                     // attention le token mis sur jenkins  a été généré sur heroku
                                                          // puis utilisé par credential jenkins
     steps {
             script {  // ici on va se loguer sur heroku avec login , creer le projet si il n'existe pas , pusher et deployer avec
                       // le mot clé release sur l'environement STAGING
                       // attention heroku à son propre registry ce por cela qu'on a pousser sur dockerhub
               sh '''
                  heroku container:login
                  heroku create $PRODUCTION || echo "project already exist"  
                  heroku container:push -a $PRODUCTION web
                  heroku container:release -a $PRODUCTION web
               ''' 
             }
         }

   }
 }
}
