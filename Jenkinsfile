pipeline {
  agent any
  
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dprus-dockerhub')
  }
  
  stages {
    
    stage('Initialize Variables') {
      steps {
        script {
          try {
            CURRENT_UPSTREAM_DOCKERHUB_IMAGE_DIGEST = params.CURRENT_UPSTREAM_DOCKERHUB_IMAGE_DIGEST
          } catch (Exception e) {
            echo("Could not read CURRENT_UPSTREAM_DOCKERHUB_IMAGE_DIGEST from parameters. Assuming this is the first run of the pipeline. Exception: ${e}")
            CURRENT_UPSTREAM_DOCKERHUB_IMAGE_DIGEST = ""
          }
        }
      }
    }
    
    stage('Fetch new Upstream Docker Hub Image Digest') {
      steps {
        script {
          NEW_UPSTREAM_DOCKERHUB_IMAGE_DIGEST = sh(
            '''
              docker manifest inspect caddy:builder -v | jq '.[].Descriptor | select (.platform.architecture=="amd64" and .platform.os=="linux")' | jq -r '.digest'
            ''',
            returnStdout: true
          ).trim()
        }
      }
    }
    
    stage('Build') {
      steps {
        sh 'docker build -t dprus/caddy-azure-dns:latest .'
      }
    }
    
    stage('Login to Docker Hub') {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
      }
    }
    
    stage('Push image to Docker Hub') {
      steps {
        sh 'docker push dprus/caddy-azure-dns:latest'
      }
    }
    
    stage("Save Persistent Variables") {
      steps {
        script {
          properties([
            parameters([
              string(defaultValue: "${CURRENT_UPSTREAM_DOCKERHUB_IMAGE_DIGEST}",
                     description: "Current Upstream DockerHub Image Digest",
                     name: 'CURRENT_UPSTREAM_DOCKERHUB_IMAGE_DIGEST',
                     trim: true)
            ])
          ])
        }
      }
    }
  }
  
  post {
    always {
      sh 'docker logout'
    }
  }
}
