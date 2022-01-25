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
            }
        }     
        stage('Publish to DockerHub'){
            steps{
                withDockerRegistry([ credentialsId: "dockerhub-credential", url: "" ]) {   
                    sh '''
		        docker tag weblogin kelvinduan/weblogin:latest
                        docker push kelvinduan/weblogin:latest
                        docker rmi kelvinduan/weblogin:latest
                        docker rmi weblogin
		    '''
                }
            }
        }     
        stage('Run Docker Container'){
            steps{
                sh '''
		    docker stop weblogin
                    docker rm weblogin
                    docker image prune --force
                    docker run -d -p 8000:8080  --name weblogin kelvinduan/weblogin
		'''
            }
        }
	stage('Publish to Nexus'){
            steps{
                withCredentials([string(credentialsId: 'nexus-password', variable: 'nexus_password')]) {
                    sh '''
                        docker login -u admin -p ${nexus_password} 192.168.0.102:8083
                        docker tag weblogin:latest 192.168.0.102:8083/weblogin:latest
                        docker push 192.168.0.102:8083/weblogin:latest
                        docker rmi 192.168.0.102:8083/weblogin:latest
                        docker rmi weblogin:latest
                    '''
                }
            }
        }     
        stage('Run Docker Container'){
            steps{
                sh '''
                    docker stop weblogin
                    docker rm weblogin
                    docker image prune --force
                    docker run -d -p 8000:8080  --name weblogin 192.168.0.102:8083/weblogin:latest
                '''
            }
        }
    }
}
