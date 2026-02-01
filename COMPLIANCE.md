Compliance and Governance Report (GCC/SHIP-HAT)

1. *Assignment 1 (Terraform Infrastructure (IaC) - Infrastructure Security)*
a) Security with Least Privilege (IAM): My IAM roles are not "Admin access". Dedicated policy in modules/compute/main.tf that only allows it to talk to one specific S3 bucket and use one specific KMS key.

b) Network Setup: VPC built with public and private subnets across two Availability Zones. The app runs in the private section so it's not directly exposed to the internet.

c) KMS Encryption: KMS encryption policy is used. AWS KMS keys used to lock down ECR images, S3 buckets, and the CloudWatch logs.

d) Transit Security and TLS Termination: A full TLS termination flow was implemented on the Application Load Balance(ALB), Managed the certificate using tls terraform provider to generate self-signed RSA-2048 certificate, which was then imported to AWS certificate Manager(ACM) to comply the SHIP-HAT Integration. Configured an HTTP-to-HTTPS redirect (301 Permanent Redirect) on Port 80. This ensures that all public traffic is upgraded to an encrypted TLS 1.3 connection before it reaches the application tasks. Suitable tls policy was used to meet the high-security government standards.

e) Secure Infrastructure Management: S3 remote backend, the terraform state is not stored locally. Added the "lifecycle { prevent_destroy = true }" block to the S3 bucket holding the Terraform state and the DynamoDB locking table. This setting ensures that even with the right permissions, the backend infrastructure cannot be deleted without a manual, multi-step code change which comply the GCC environment requirements. Used an S3 backend with "encrypt = true" to keep the infrastructure "source of truth" secure. State locking(DynamoDB), To prevent multiple people from changing the environment at once and causing corruption, I configured a DynamoDB table (terraform-state-locking) to handle state locks. State versioning, S3 bucket has versioning enabled, which acts as a backup so we can recover the infrastructure state if something goes wrong. 


2. *Assignment 2 (Workflow Orchestration “Self-Healing Deployment” - Automation + Scripts + Testing)*
a) Automated Rollbacks: I built an orchestration workflow that doesn't just deploy without any checks. It runs a validate.sh and verify.sh script before and after the deployment which is responsible for pre-flight validation and post-deployment verification. This ensure the deployment and app is actually working. If issues present the previous working image version will be used to rollback to ensure the availability and reliability of the app service.

b) Success and Failure run evidence: The verification made to be fail intentionally to test the rollback. To simulate and error, a filter to check expected output from the sample web app was initiated. The idea is to make it to match the expected output with the text string from the app. Deployment fails if unexpected text is filtered in which the previous version build will be used to conduct the rollback. This is demonstrated and can viewed from the images during my deployment in build #33, once the deployment failed build v32 was used to rollback.

c) Logic efficiency: If the pipeline failed at JIRA validation, the rollback will be skipped due to unchanged infrastructure or configuration as the it will be the initial stage before pre-flight validation. This ensures reduced time consumption and cost optimization.


3. *Assignment 3 (Gov Cloud Compliance-as-Code + Jira Delivery - Policy Gates + Change Evidence)*
a) JIRA Ticket Enforcement: To Simulate the enforcement, a "JIRA Governance check" stage was placed at the verify started of the pipeline. It checks the git commit message for a ticket ID (like GCC-123) using regex. If it doesn't find one, the build stops immediately and moved to post actions which ensures failed deployment due to JIRA ticket absence. In production environment, real JIRA ticket number generated will be filtered instead of this mock-up methodology. 

b) Audit Trail: Every single deployment is tied to a specific task. Dedicated messages is provided for error messages in each stage. As can be seen from my Build 35# the Jira Governance check was failed with extensive output higlighting the error and the deployment fails instantly which ensures the JIRA ticket enforcement as the ultimate precheck. This ties the enforcement every deployment that will go through the pipeline and ensures no changes to happen in the cloud infrastructure when failure is detected.


4. Summary of Tools used
a) Terraform
b) Jenkins
c) Shell Script
d) Python
e) Docker
f) AWS free-tier subscription
g) Github
h) Powershell
i) Visual Studio code
j) AWS CLI
k) Git bash
