# AWS Serverless Static Site with Terraform

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

```mermaid
graph TD
    %% Define Styles
    classDef user fill:#fff,stroke:#333,stroke-width:2px;
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:white;
    classDef security fill:#DD344C,stroke:#232F3E,stroke-width:2px,color:white;
    classDef storage fill:#3F8624,stroke:#232F3E,stroke-width:2px,color:white;
    classDef compute fill:#D45B07,stroke:#232F3E,stroke-width:2px,color:white;
    classDef db fill:#3B48CC,stroke:#232F3E,stroke-width:2px,color:white;

    %% Nodes
    User((User / Browser)):::user
    
    subgraph AWS_Cloud [AWS Cloud]
        style AWS_Cloud fill:#f2f2f2,stroke:#232F3E,stroke-dasharray: 5 5
        
        subgraph Edge [Edge Locations]
            style Edge fill:#e6e6e6,stroke:#666
            WAF[AWS WAF<br/>(Security Rules)]:::security
            CF[Amazon CloudFront<br/>(CDN Distribution)]:::aws
        end

        subgraph Region [Region: eu-central-1]
            style Region fill:#fff,stroke:#666
            
            S3_Site[S3 Bucket<br/>(Static Site Hosting)]:::storage
            Lambda[AWS Lambda<br/>(Visitor Counter)]:::compute
            DDB[(Amazon DynamoDB<br/>Visitor Table)]:::db
            
            S3_Logs[S3 Bucket<br/>(Access Logs)]:::storage
        end
    end

    %% Connections
    User -->|HTTPS Request| WAF
    WAF -->|Allowed Traffic| CF
    
    CF -->|OAC Secured Access| S3_Site
    CF -->|API Call| Lambda
    
    Lambda -->|Read/Write Count| DDB
    
    CF -.->|Logging| S3_Logs
    S3_Site -.->|Logging| S3_Logs



A production-ready infrastructure project to host a secure static website on AWS using Terraform. This project implements a serverless architecture including CloudFront (CDN), S3 (Origin), WAF (Security), and a serverless visitor counter backend using Lambda and DynamoDB.

**Author:** [emredogan-cloud](https://github.com/emredogan-cloud)

---

## 🏗 Architecture

This project deploys the following AWS resources:

- **Amazon S3:** Private bucket to store static HTML/CSS/JS assets.
- **Amazon CloudFront:** Global Content Delivery Network (CDN) with OAC (Origin Access Control) for secure S3 access.
- **AWS WAF:** Web Application Firewall attached to CloudFront to protect against common web exploits.
- **AWS Lambda & DynamoDB:** A Python-based "Visitor Counter" microservice.
- **Terraform Backend:** S3 and DynamoDB for remote state management and state locking (via `backend-bootstrap`).

---

## 📂 Project Structure

```text
.
├── backend-bootstrap/       # Terraform to provision the S3 State Bucket & DynamoDB Lock Table
│   ├── main.tf
│   └── ...
├── modules/                 # Reusable Terraform modules
│   ├── cloudfront_oac       # CDN configuration with Origin Access Control
│   ├── logs_bucket          # S3 Access logging configuration
│   ├── s3_oac_policy        # Policy allowing CloudFront OAC to read S3
│   ├── s3_site_bucket       # The hosting bucket configuration
│   ├── visitor              # Lambda function (counter.py) and API setup
│   └── waf_cloudfront       # Security rules for the CDN
├── site/                    # The static website content (index.html)
├── stacks/                  # The deployable infrastructure code
│   └── static-site          # Main stack utilizing the modules above
│       ├── env/             # Environment specific variables (dev.tfvars, prod.tfvars)
│       └── backend-config/  # Backend configuration files
├── venv/                    # Local Python virtual environment
└── .github/workflows/       # CI/CD pipelines
```

---

## 🚀 Getting Started

### Prerequisites

- AWS CLI (configured with Administrator permissions)
- Terraform (v1.5+)
- Python 3.12 (for local Lambda testing)

### 1) Setup Remote Backend (Bootstrap)

Before deploying the main infrastructure, you must create the storage for the Terraform state file.

```bash
cd backend-bootstrap
terraform init
terraform apply
```

> **Important:** Note the output values (**Bucket Name** and **DynamoDB Table Name**) generated here. You will need them to configure the backend in the next step.

### 2) Deploy the Infrastructure

Navigate to the main stack directory:

```bash
cd ../stacks/static-site
```

Initialize Terraform: update the `backend-config/prod.hcl` file with the bucket name created in Step 1, then run:

```bash
terraform init -backend-config=backend-config/prod.hcl
```

Plan and apply: deploy the production environment using the provided variable file.

```bash
terraform plan -var-file="env/prod.tfvars" -out=tfplan
terraform apply "tfplan"
```

### 3) Deploy Website Content

Once the infrastructure is created, upload your static files to the newly created S3 bucket.

```bash
# Replace YOUR_BUCKET_NAME with the output from the previous step
aws s3 cp ../../site/index.html s3://YOUR_BUCKET_NAME/index.html
```

---

## 🛠 Modules Overview

| Module | Description |
|---|---|
| `s3_site_bucket` | Creates a private S3 bucket with encryption and public access blocking enabled. |
| `cloudfront_oac` | Configures the CDN distribution and sets up Origin Access Control so direct S3 access is blocked. |
| `waf_cloudfront` | Deploys WAF Web ACLs to filter malicious traffic before it hits the CDN. |
| `visitor` | Deploys the Python Lambda function (`counter.py`) to track site visits and stores data in DynamoDB. |
| `logs_bucket` | Centralized bucket for storing S3 and CloudFront access logs. |

---

## 🔄 CI/CD

This project includes a GitHub Actions workflow located at `.github/workflows/terraform-ci.yaml`.

- **Triggers:** pushes to the `main` branch.
- **Actions:**
  - Sets up AWS credentials
  - Installs Terraform
  - Runs `terraform fmt` and `terraform validate`
  - Plans and applies changes automatically (configurable)

---

## 🛡️ Security Features

- **Private S3:** The website bucket is not public. It is only accessible via CloudFront using OAC.
- **Encryption:** All data in transit (HTTPS) and at rest (SSE-S3/KMS) is encrypted.
- **WAF Protection:** CloudFront is protected by AWS WAF rules to mitigate common attacks.
- **State Locking:** DynamoDB is used to prevent concurrent state modifications during deployments.

---

## 📄 License

This project is licensed under the MIT License.
