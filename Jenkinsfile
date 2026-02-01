pipeline {
    agent any
    tools {
        terraform 'terraform-latest' 
    }
    environment {
        REPO_URL = "725770766740.dkr.ecr.ap-southeast-1.amazonaws.com/dev-app-repo"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
    }
    stages {
        stage('Pre-flight Validation') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh 'chmod +x ./scripts/validate.sh && ./scripts/validate.sh'
                }
            }
        }

        stage('Provision Foundations (ECR)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    dir('terraform/environment/dev') {
                        sh 'terraform init'
                        sh 'terraform apply -target=module.ecr -auto-approve'
                    }
                }
            }
        }

        stage('Build and Push to ECR') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        dir('app') {
                            sh """
                            aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 725770766740.dkr.ecr.ap-southeast-1.amazonaws.com
                            docker build -t dev-app-repo .
                            docker tag dev-app-repo:latest ${env.REPO_URL}:${env.IMAGE_TAG}
                            docker push ${env.REPO_URL}:${env.IMAGE_TAG}
                            """
                        }
                    }
                }
            }
        }

        stage('Provision Full Stack') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    dir('terraform/environment/dev') {
                        sh "terraform apply -auto-approve -var='container_image_tag=${env.IMAGE_TAG}'"
                        
                        script {
                            def rawUrl = sh(script: 'terraform output -no-color -raw alb_dns_name', returnStdout: true).trim()
                            env.ALB_URL = rawUrl.replaceAll(/[^a-zA-Z0-9.-]/, "") 
                        }
                    }
                }
            }
        }

        stage('Post-deploy Verification') {
            steps {
                sh "chmod +x ./scripts/verify.sh"
                sh "./scripts/verify.sh http://${env.ALB_URL}"
            }
        }
    }
    
    post {
        failure {
            echo 'Verification Failed!'
            // Automated rollback logic
        }
        always {
            cleanWs()
        }
    }
}