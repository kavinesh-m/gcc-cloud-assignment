pipeline {
    agent any
    tools {
        terraform 'terraform-latest' 
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-gcc-keys')
        AWS_SECRET_ACCESS_KEY = credentials('aws-gcc-keys')
        AWS_DEFAULT_REGION    = 'ap-southeast-1'
    }
    stages {
        stage('Pre-flight Validation') {
            steps {
                // COMMAND 1: Grant permission to the validation script
                sh 'chmod +x ./scripts/validate.sh'
                sh './scripts/validate.sh'
            }
        }
        stage('Provision Infrastructure') {
            steps {
                dir('terraform/environment/dev') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Post-deploy Verification') {
            steps {
                // COMMAND 2: Grant permission to the verification script
                sh 'chmod +x ./scripts/verify.sh'
                sh './scripts/verify.sh'
            }
        }
    }
    post {
        failure {
            echo 'Verification Failed! Initiating Self-Healing Rollback...'
            dir('terraform/environment/dev') {
                sh 'terraform destroy -auto-approve'                
            }
        }
    }
}