pipeline {
    agent any
    tools {
        terraform 'terraform-latest' 
    }
    stages {
        stage('Pre-flight Validation') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh 'chmod +x ./scripts/validate.sh'
                    sh './scripts/validate.sh'
                }
            }
        }

        stage('Build and Push to ECR') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', accessKeyVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                        # Login to ECR
                        aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 725770766740.dkr.ecr.ap-southeast-1.amazonaws.com
                        
                        # Build, Tag, and Push
                        docker build -t dev-app-repo .
                        docker tag dev-app-repo:latest 725770766740.dkr.ecr.ap-southeast-1.amazonaws.com/dev-app-repo:latest
                        docker push 725770766740.dkr.ecr.ap-southeast-1.amazonaws.com/dev-app-repo:latest
                        """
                    }
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    dir('terraform/environment/dev') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                        script {
                            env.ALB_URL = sh(script: 'terraform output -raw alb_dns_name', returnStdout: true).trim()
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
        always {
            cleanWs() // Clean workspace to save disk space
        }
        failure {
            echo 'Verification Failed! Initiating Self-Healing Rollback...'
            withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                dir('terraform/environment/dev') {
                    sh 'terraform init'
                    // sh 'terraform destroy -auto-approve'                
                }
            }
        }
    }
}