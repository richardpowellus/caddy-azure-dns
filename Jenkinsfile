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
            currentUpstreamDockerHubImageDigest = params.currentUpstreamDockerHubImageDigest
          } catch (Exception e) {
            echo("Could not read currentUpstreamDockerHubImageDigest from parameters. Assuming this is the first run of the pipeline. Exception: ${e}")
            currentUpstreamDockerHubImageDigest = ""
          }
        }
      }
    }
    
    stage('Fetch new Upstream Docker Hub Image Digest') {
      steps {
        
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
              string(defaultValue: "${currentUpstreamDockerHubImageDigest}",
                     description: "Current Upstream DockerHub Image Digest",
                     name: 'currentUpstreamDockerHubImageDigest',
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
