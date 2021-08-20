pipeline {
  agent any
  
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dprus-dockerhub')
    REBUILD_IMAGE = false
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
            script: '''
              docker manifest inspect caddy:builder -v | jq '.[].Descriptor | select (.platform.architecture=="amd64" and .platform.os=="linux")' | jq -r '.digest'
            ''',
            returnStdout: true
          ).trim()
        }
      }
    }
    
    stage('Determine if it has been more than 2 weeks since the latest build') {
      steps {
        script {
          TIME_SINCE_LAST_IMAGE = sh(
            script: '''
              d1=$(curl -s GET https://hub.docker.com/v2/repositories/dprus/caddy-azure-dns/tags/latest | jq -r ".last_updated")
              ddiff=$(( $(date "+%s") - $(date -d "$d1" "+%s") ))
              echo $ddiff
            ''',
            returnStdout: true
          ).trim()
          if (TIME_SINCE_LAST_IMAGE > 1209600) { // 1209600 is 2 weeks in seconds
            echo "It has been more than 2 weeks since the last build. Image will be rebuilt."
            REBUILD_IMAGE = true
          }
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
              string(defaultValue: "${NEW_UPSTREAM_DOCKERHUB_IMAGE_DIGEST}",
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
