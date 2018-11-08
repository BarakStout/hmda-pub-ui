podTemplate(label: 'buildDockerContainer', containers: [
  containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat'),
  containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm', ttyEnabled: true, command: 'cat')
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
]) {
   node('buildDockerContainer') {
     def repo = checkout scm
     def gitCommit = repo.GIT_COMMIT
     def gitBranch = repo.GIT_BRANCH
     def shortGitCommit = "${gitCommit[0..10]}"

    stage('Build And Publish Docker Image') {
      container('docker') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub',
            usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'hmda-platform-jenkins-service',
              usernameVariable: 'DTR_USER', passwordVariable: 'DTR_PASSWORD']]) {
              withCredentials([string(credentialsId: 'internal-docker-registry', variable: 'DOCKER_REGISTRY_URL')]){
                sh "docker build --rm -t=${env.DOCKER_HUB_USER}/hmda-pub-ui ."
                if (env.TAG_NAME != null || gitBranch == "v2") {
                  if (gitBranch == "v2") {
                    env.DOCKER_TAG = "latest"
                  } else {
                    env.DOCKER_TAG = env.TAG_NAME
                  }
                  sh """
                    docker tag ${env.DOCKER_HUB_USER}/hmda-pub-ui ${env.DOCKER_HUB_USER}/hmda-pub-ui:${env.DOCKER_TAG}
                    docker login -u ${env.DOCKER_HUB_USER} -p ${env.DOCKER_HUB_PASSWORD} 
                    docker push ${env.DOCKER_HUB_USER}/hmda-pub-ui:${env.DOCKER_TAG}
                    docker tag ${env.DOCKER_HUB_USER}/hmda-pub-ui:${env.DOCKER_TAG} ${DOCKER_REGISTRY_URL}/${env.DOCKER_HUB_USER}/hmda-pub-ui:${env.DOCKER_TAG}
                    docker login ${DOCKER_REGISTRY_URL} -u ${env.DTR_USER} -p ${env.DTR_PASSWORD} 
                    docker push ${DOCKER_REGISTRY_URL}/${env.DOCKER_HUB_USER}/hmda-pub-ui:${env.DOCKER_TAG}
                  """
                }
              }
            }
          }
        }
      }

    stage('Deploy') {
      if (env.BRANCH_NAME == 'v2') {
        container('helm') {
          sh "helm upgrade --install --force \
          --namespace=default \
          --values=kubernetes/hmda-pub-ui/values.yaml \
          --set image.tag=${gitBranch} \
          hmda-pub-ui \
          kubernetes/hmda-pub-ui"
        }
      }
    }

  }

}
