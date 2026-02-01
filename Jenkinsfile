pipeline {
    agent any
    tools { terraform 'terraform-latest' }
    environment {
        REPO_URL = "725770766740.dkr.ecr.ap-southeast-1.amazonaws.com/dev-app-repo"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        DEPLOYMENT_STARTED = 'false'
    }
    stages {
        stage('Jira Governance Check') {
            steps {
                script {
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    echo "Checking Commit Message: ${commitMsg}"
                    
                    if (commitMsg =~ /GCC-[0-9]+/) {
                        echo "Compliance Verified: Jira Ticket found."
                    } else {
                        error "COMPLIANCE FAILURE: Commit message must contain a Jira ticket (e.g., 'GCC-123: Test Compliance')"
                    }
                }
            }
        }
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
        stage('Provision Full Stack') {
            steps {
                script {
                    env.DEPLOYMENT_STARTED = 'true'
                }
                withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    dir('terraform/environment/dev') {
                        sh "terraform apply -auto-approve -var='container_image_tag=${env.IMAGE_TAG}'"
                        script {
                            def rawOutput = sh(script: 'terraform output -no-color -raw alb_dns_name', returnStdout: true).trim()
                            def matcher = (rawOutput =~ /([a-zA-Z0-9.-]+\.amazonaws\.com)/)
                            if (matcher) {
                                env.ALB_URL = matcher[0][1]
                            }
                            echo "--- CLEANED URL FOR VERIFICATION: http://${env.ALB_URL} ---"
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
            script {
                if (env.DEPLOYMENT_STARTED == 'true') {
                    echo "--- DEPLOYMENT FAILURE DETECTED ---"
                    echo "Triggering Self-Healing Rollback to ensure environment stability."
                    
                    def prevBuild = (env.BUILD_NUMBER.toInteger() - 1)
                    
                    if (prevBuild > 0) {
                        def rollbackTag = "v${prevBuild}"
                        def tfPath = "terraform/environment/dev"
                        
                        echo "Targeting Rollback Image Tag: ${rollbackTag}"
                        
                        withCredentials([usernamePassword(credentialsId: 'aws-gcc-keys', 
                                         passwordVariable: 'AWS_SECRET_ACCESS_KEY', 
                                         usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                            
                            sh "terraform -chdir=${tfPath} init"
                            sh "terraform -chdir=${tfPath} apply -auto-approve -var='container_image_tag=${rollbackTag}'"
                        }
                        echo "SUCCESS: Self-healing complete. Environment reverted to ${rollbackTag}."
                    } else {
                        echo "WARNING: No previous build found. Manual intervention may be required."
                    }
                } else {
                    echo "--- GOVERNANCE/PRE-FLIGHT FAILURE ---"
                    echo "The build failed before deployment started. No infrastructure changes were made."
                    echo "Skipping automated rollback to save time and AWS resources."
                }
            }
        }
        success {
            cleanWs()
        }
    }
}