pipeline {
  agent any
  
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dprus-dockerhub')
  }
  
  stages {
    stage('Initialize') {
      steps {
        script {
          def dockerHome = tool 'myDocker'
          env.PATH = "${dockerHome}/bin:${env.PATH}"
        }
      }
    }
    stage('Build') {
      steps {
        sh 'docker build -t dprus/caddy-azure-dns:latest .'
      }
    }
    stage('Login') {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
      }
    }
    stage('Push') {
      steps {
        sh 'docker push dprus/caddy-azure-dns:latest'
      }
    }
  }
  
  post {
    always {
      sh 'docker logout'
    }
  }
}
