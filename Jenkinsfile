pipeline{
    agent any
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'master', url: 'https://github.com/kelvinduan2020/2022-TomcatWebLoginApp.git'
            }
        }
	    stage('Maven Build'){
            steps{
                sh 'mvn package'             
            }
        }
        stage("Sonar Quality Check"){
            steps{
                script{
                    withSonarQubeEnv('sonarqube-server') {
                        sh 'mvn sonar:sonar'
                    }
                    timeout(time: 1, unit: 'HOURS') {
                      def qg = waitForQualityGate()
                      if (qg.status != 'OK') {
                           error "Pipeline aborted due to quality gate failure: ${qg.status}"
                      }
                    }
                }
            }
        }
        stage('Create Dockr Image'){
            steps{
                sh 'docker build -t weblogin:latest .' 
                sh 'docker tag weblogin kelvinduan/weblogin:latest'
                sh 'docker rmi weblogin'
            }
        }     
        stage('Publish to DockerHub'){
            steps{
                withDockerRegistry([ credentialsId: "dockerhub-credential", url: "" ]) {
                    sh 'docker push kelvinduan/weblogin:latest'
                    sh 'docker rmi kelvinduan/weblogin:latest'
                }
            }
        }     
        stage('Run Docker Container'){
            steps{
                sh 'docker stop weblogin'
                sh 'docker rm weblogin'
                sh 'docker image prune --force'
                sh "docker run -d -p 8000:8080  --name weblogin kelvinduan/weblogin"
            }
        }
    }
}
