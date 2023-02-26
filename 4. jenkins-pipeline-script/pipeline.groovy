//Define the code repository address.
def git_url = 'https://github.com/tquocthang97/demo-forecast-api.git'
//Define the SWR zone.
def aws_region = 'ap-southeast-1'
//Define the account id
def aws_account_id = '1111111111111111'
//Define the image name.
def image_repo_name = 'forecast-api'
//Define the repository_uri
def repository_uri = '22222222222.dkr.ecr.us-east-1.amazonaws.com/forecast-api'
//Certificate ID of the cluster to be deployed
def credential = 'k8s-token'
//API server address of the cluster. Ensure that the address can be accessed from the Jenkins cluster.
def apiserver = 'https://eks-url'

pipeline {
    agent any
    stages {
        stage('Clone') { 
            steps{
                echo "1.Clone Stage" 
                git url: git_url
                script { 
                    build_tag = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim() 
                } 
            }
        } 
        stage('Test') { 
            steps{
                echo "2.Test Stage" 
            }
        } 
        stage('Build') { 
            steps{
                echo "3.Build Docker Image Stage" 
                sh "docker build -t ${image_repo_name}:${build_tag} ." 
            }
        } 

        stage('Push') { 
            steps{
                script {
                    echo "4.Login and Push Docker Image Stage" 
                    sh """aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"""
                    sh """docker tag ${image_repo_name}:${build_tag} ${repository_uri}:${build_tag}"""
                    sh """IMAGE_NAME=${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${image_repo_name}:${build_tag}"""
                    sh """docker push $IMAGE_NAME:${build_tag}"""
                }
            }
        } 
        stage('Deploy') {
            steps{
                echo "5. Deploy Stage"
                script {
                echo "begin to config kubenetes"
                try {
                    withKubeConfig([credentialsId: credential, serverUrl: apiserver]) {
                        sh 'envsubst < k8s/deploy.yaml | kubectl apply -f -' 
                    }
                    println "Deployment Success"
                } catch (e) {
                    println "Deployment Failed! "
                    println e
                }
                }
            }
        }
    }
}
