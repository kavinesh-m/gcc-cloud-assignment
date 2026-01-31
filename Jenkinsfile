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
                // Pre-flight validation
                sh 'terraform -version'
                dir('terraform/environment/dev') {
                    sh 'terraform validate'
                }
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
                // Post-deploy verification
                sh 'curl -f https://dev-alb-52149831.ap-southeast-1.elb.amazonaws.com || exit 1'
            }
        }
    }
    post {
        failure {
            // Automated rollback / Self-healing
            echo 'Verification Failed! Initiating Self-Healing Rollback...'
            dir('terraform/environment/dev') {
                sh 'terraform destroy -auto-approve'                
            }
        }
    }
}