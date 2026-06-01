# Staging Environment

Staging is a production-like environment deployed on every push to `develop`.

## Access

| Service | URL |
|---|---|
| API | https://staging-api.bluecollar.app |
| App | https://staging.bluecollar.app |

## Infrastructure

Managed by Terraform in `deploy/terraform/environments/staging/`.
Differences from production:

| Resource | Staging | Production |
|---|---|---|
| RDS instance | db.t3.micro | db.t3.medium |
| Multi-AZ | No | Yes |
| Deletion protection | No | Yes |

## Deployment

Triggered automatically on push to `develop` via `.github/workflows/deploy-staging.yml`:
1. Build and push Docker image tagged `staging-<sha>` and `staging-latest`
2. `terraform apply` for staging infrastructure
3. `prisma migrate deploy` against staging DB
4. Seed staging data
5. Smoke tests

To trigger manually: Actions → "Deploy to Staging" → Run workflow.

## Configuration

Copy `.env.staging` and fill in secrets. In CI, secrets are stored under the `staging` GitHub environment.

## Data seeding

Staging is seeded with realistic fake data on every deploy:
```bash
DATABASE_URL=<staging_url> npm run seed
```

## Resetting staging data

```bash
DATABASE_URL=<staging_url> npm run seed:reset
```
