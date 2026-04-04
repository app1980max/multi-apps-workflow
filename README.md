<img width="1048" height="608" alt="image" src="https://github.com/user-attachments/assets/9943a8d3-4285-470b-8cc3-677f5b01e107" />


## Multi-Application-Workflow | 🏅
GitOps-style Terraform CI/CD workflow with GitHub Actions, multiple environments, and remote state backends. Here’s a breakdown and what it means for your setup:


🚀  Overview
```
✅ Terraform Configurations
✅ Code Push → GitHub Actions
✅ Workspaces
✅ Provision Resources
✅ Terraform State Validation
```


🎯 Workflow
```
curl -H "X-API-KEY: dev-key-123" http://weaviate.weaviate.svc.cluster.local:80/v1/meta

Verify your schema:
curl -H "X-API-KEY: dev-key-123" http://weaviate.weaviate.svc.cluster.local:80/v1/schema

Option A: Query only existing fields
curl -X POST http://weaviate.weaviate.svc.cluster.local:80/v1/graphql \
-H "Content-Type: application/json" \
-H "X-API-KEY: dev-key-123" \
-d '{"query": "{ Get { Products { name price _additional { vector } } } }"}'

Option B: Add the missing description property to the class
curl -X POST http://weaviate.weaviate.svc.cluster.local:80/v1/schema/properties \
-H "Content-Type: application/json" \
-H "X-API-KEY: dev-key-123" \
-d '{
  "class": "Products",
  "name": "description",
  "dataType": ["text"],
  "description": "Product description"
}'
```


🧪 Deployment Options
```
terraform init
terraform validate
terraform plan -var-file="template.tfvars"
terraform apply -var-file="template.tfvars" -auto-approve
```
