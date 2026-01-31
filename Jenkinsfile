pipeline {
    agent any
    tools { terraform 'terraform-latest' }
    stages {
        stage('Pre-flight Validation') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh 'chmod +x ./scripts/validate.sh && ./scripts/validate.sh'
                }
            }
        }
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
    }
}