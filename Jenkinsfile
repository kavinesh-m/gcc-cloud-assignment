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
        stage('Provision Infrastructure') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    dir('terraform/environment/dev') {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
        stage('Post-deploy Verification') {
            steps {
                sh 'chmod +x ./scripts/verify.sh'
                sh './scripts/verify.sh'
            }
        }
    }
    post {
        failure {
            echo 'Verification Failed! Initiating Self-Healing Rollback...'
            withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                dir('terraform/environment/dev') {
                    sh 'terraform destroy -auto-approve'                
                }
            }
        }
    }
}