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
                    env.IMAGE_TAG = "v${env.BUILD_NUMBER}"
                    env.REPO_URL = "725770766740.dkr.ecr.ap-southeast-1.amazonaws.com/dev-app-repo"
                    
                    withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', accessKeyVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                        # Login to ECR
                        aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 725770766740.dkr.ecr.ap-southeast-1.amazonaws.com
                        
                        # Build the image once
                        docker build -t dev-app-repo .
                        
                        # Tag it with BOTH 'latest' and the unique 'build number'
                        docker tag dev-app-repo:latest ${env.REPO_URL}:latest
                        docker tag dev-app-repo:latest ${env.REPO_URL}:${env.IMAGE_TAG}
                        
                        # Push both tags
                        docker push ${env.REPO_URL}:latest
                        docker push ${env.REPO_URL}:${env.IMAGE_TAG}
                        """
                    }
                }
            }
        }

        // stage('Provision Infrastructure') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        //             dir('terraform/environment/dev') {
        //                 sh 'terraform init'
        //                 sh 'terraform apply -auto-approve'
        //                 script {
        //                     env.ALB_URL = sh(script: 'terraform output -raw alb_dns_name', returnStdout: true).trim()
        //                 }
        //             }
        //         }
        //     }
        // }

        // Temporarily replace your Apply stage with this to wipe the slate
        stage('Cleanup Infrastructure') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    dir('terraform/environment/dev') {
                        sh 'terraform init'
                        sh 'terraform destroy -auto-approve'
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