# aws-template-developed-services

A Terraform/Terragrunt template repository for developing integrations and applications using AWS serverless
technologies under the Adena partner boundary.

## Using this template

Click **"Use this template"** in the GitHub UI to create a new repository from this template. After creating your
repository, search for all `REPLACE_ME` markers and update them:

- `accounts.yml` — replace all placeholder account IDs with real AWS account IDs
- `root.hcl` — update `Repository` tag, `account_environments`, `account_cost_centers`, and `account_owners` maps
- `tags.yml` — update `Repository` tag value to the consuming repository name
- `policies/boundaries/partner-boundary.json` — replace `REPLACE_PARTNER_NAME` with your partner path prefix
- `modules/example-module/main.tf` — replace `REPLACE_PARTNER_NAME` in the IAM role path
- `.github/workflows/` — update OIDC subject claim if repo is renamed

## Repository structure

```text
.
├── accounts/                        # Per-account Terragrunt configurations
│   └── developed-services/
│       └── eu-west-2/
│           └── example/
│               └── terragrunt.hcl   # Module deployment config
├── modules/                         # Reusable Terraform modules
│   └── example-module/              # Lambda execution role + CloudWatch log group
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── policies/
│   └── boundaries/
│       └── partner-boundary.json    # IAM permissions boundary scoped to serverless services
├── scripts/                         # Helper scripts for local development
├── .github/
│   ├── workflows/
│   │   ├── pr.yml                   # Static analysis on pull requests
│   │   ├── merge-to-main.yml        # Deploy on merge to main
│   │   └── break-glass.yml          # Emergency manual deploy
│   └── pull_request_template.md
├── accounts.yml                     # Account ID registry
├── tags.yml                         # Mandatory tag definitions
├── root.hcl                         # Terragrunt root configuration
├── Makefile                         # Developer convenience targets
└── .pre-commit-config.yaml          # Pre-commit hook configuration
```

## Serverless services in scope

The permissions boundary policy (`partner-boundary.json`) scopes partner workloads to the following AWS services:

| Category | Services |
|---|---|
| Compute | Lambda |
| API | API Gateway (REST, HTTP, WebSocket), Execute API |
| Data | DynamoDB, S3 |
| Messaging | SQS, SNS, EventBridge, EventBridge Scheduler |
| Orchestration | Step Functions |
| Observability | CloudWatch, X-Ray |
| Configuration | SSM Parameter Store, Secrets Manager, KMS |
| Identity | IAM (path-restricted), Cognito |
| Communication | SES |

## Pre-requisites

- Python 3.12
- Terraform >= 1.5
- Terragrunt >= 0.67
- pre-commit >= 3.0

## Local setup

```bash
make install-hooks
```

## GitHub setup

The following must be configured before workflows will function:

### GitHub Environments

1. Create environment **`test`**
   - No approval gate required
   - Restrict deployments to `main` branch

2. Create environment **`production`**
   - Required reviewers: minimum 1
   - Restrict deployments to `main` branch

### GitHub Secrets

Add the following secrets at the repository level:

| Secret | Description |
|---|---|
| `TF_DEPLOY_ROLE_TEST` | ARN of the IAM role to assume for test account deployments |
| `TF_DEPLOY_ROLE_PROD` | ARN of the IAM role to assume for production account deployments |

## OIDC trust policy

Add the following `Condition` block to the trust policy of the deployment roles in each account to allow GitHub
Actions to assume them via OIDC:

```json
{
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:MonsoonAccessorize/aws-template-developed-services:*"
  }
}
```

Update the `repo:` value if this template is used to create a repository with a different name.

## Role chain

GitHub Actions authenticates via OIDC and assumes the **TerraformDeploymentRole** in the target account
(test or prod). That role then assumes the **TerraformExecutionRole** in the shared services account to access
the S3 state bucket and DynamoDB lock table. Terraform resources are deployed back into the target account
using the TerraformExecutionRole's cross-account permissions.

```text
GitHub OIDC
  → TerraformDeploymentRole (example_test / example_prod account)
    → TerraformExecutionRole (shared_services account) — state bucket + lock table access
```

## Workflow summary

**PR (`pr.yml`):** Runs on every pull request targeting `main`. Executes the full pre-commit suite (formatting,
validation, linting, security scanning, and docs generation) against all files. `terragrunt_validate` is skipped
because it requires live AWS credentials.

**Merge to Main (`merge-to-main.yml`):** Triggered on push to `main`. Deploys to test first via
`terragrunt run-all apply`, then pauses for a required reviewer to approve via the `production` GitHub
Environment gate, then deploys to production.

**Break Glass (`break-glass.yml`):** A manually triggered (`workflow_dispatch`) emergency deployment that
bypasses the environment approval gate. Requires a written reason for audit purposes and logs a summary to the
GitHub Actions job summary. Use only when the normal deployment pipeline is unavailable.

## Permissions boundaries

All IAM roles created by partner workloads must be placed under the `/REPLACE_PARTNER_NAME/` IAM path and have
the `REPLACE_PARTNER_NAME-boundary` permissions boundary policy attached. This is enforced by the
`partner-boundary.json` policy applied to deployment roles.

Replace `REPLACE_PARTNER_NAME` with your partner's identifier (e.g., `adena`) throughout
`policies/boundaries/partner-boundary.json` and `modules/example-module/main.tf` before deploying.
