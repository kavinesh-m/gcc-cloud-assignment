# GCC Gov-Cloud Deployment Assignment Pipeline

This project is my submission of technical assignment for Cloud Devops Engineer role and it comprise of Assignments 1, 2, and 3. It shows a fully automated, secure AWS environment managed by Terraform,Jenkins, Docker containerization, with built-in "Self-Healing" and Jira governance adhering to GCC/GCC+, SHIP-HAT compliance frameworks.

## What this project does
1.  **Sets up AWS:** Creates a secure VPC, private subnets, and IAM roles using Terraform.
2.  **Enforces Rules:** A Jenkins pipeline checks every change for a Jira ticket before it starts.
3.  **Deploys Safely:** Builds a Docker app, pushes it to ECR, and deploys to EC2/ALB.
4.  **Self-Heals:** If the app fails a health check, the pipeline automatically rolls back to the last working version.

## Project Structure
* `/terraform`: All Infrastructure-as-Code files (VPC, IAM, S3, KMS).
* `/app`: The sample web application code.
* `/scripts`: Helper scripts for Pre-flight checks (`validate.sh`) and health checks (`verify.sh`).
* `Jenkinsfile`: The "brain" of the project that runs the whole pipeline.

## Security & Compliance
This project follows the **SHIP-HAT** standards:
* **Jira Ticket Enforcement:** No ticket = No deployment.
* **Least Privilege:** Each part of the app only has the exact AWS permissions it needs.
* **Encryption:** All data in S3 and ECR is locked with AWS KMS keys.

## Proof of Work
### 1. Successful Deployment
![Success Screen](assets/Graph-success.png)
*The final "Green" build showing the app is live.*

### 2. Jira Enforcement (Failure Test)
![Jira Fail](assets/jira-fail.png)
*Evidence of the pipeline blocking a change that didn't have a GCC ticket ID.*

### 3. Post-deploy (Failure Test)
![Post-deploy Fail](assets/post-deploy-failed.png)
*Evidence of the pipeline post deployment fail due to error in app service detected.*

### 4. Automated Rollback (Self-Healing)
![Rollback Evidence](assets/rollback-complete.png)
*Evidence from Assignment 2 where a bad version was detected and reverted.*

### 5. Evidence & Audit Artefacts

<details> <summary><b>Click to view: Live Endpoint Proof</b></summary>

Verification that the application is live and accessible via the ALB.

## Live Endpoint
**URL:** [https://dev-alb-1945154568.ap-southeast-1.elb.amazonaws.com/]

![Application Screenshot](assets/web-app.png)

Full endpoint proof available in ![Endpoint proof](artefacts/live_endpoint_proof.txt)

</details>

<details> <summary><b>Click to view: Terraform Plan Evidence</b></summary>

This shows the dry-run of the infrastructure changes before they were applied.

![Terraform Plan Evidence](artefacts/terraform_plan_evidence.txt)

</details>

<details> <summary><b>Click to view: Terraform State List</b></summary>

This confirms that all resources (VPC, IAM, KMS, ALB) are successfully tracked in the S3 backend.

![Terraform State List](artefacts/terraform_state_list.txt)

</details>

## How to run it
1. Push your code to the repository.
2. Ensure your commit message starts with `GCC-XXX:`.
3. Jenkins will automatically trigger the build.
4. Check the ALB URL output at the end to see the live app.

---
**Author:** Kavinesh Manimaran    
**Project:** AWS@Terraform - GCC/SHIP-HAT Compliance Assignment
© 2026 All Rights Reserved.