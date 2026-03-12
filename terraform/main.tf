# 1. ECR Repository for the Node.js App
resource "aws_ecr_repository" "demo_app" {
  name                 = "forticnapp-demo-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Ensures clean teardowns during terraform destroy
}

# 2. VPC for the EKS Cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "forticnapp-demo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ca-central-1a", "ca-central-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

# 3. Amazon EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "forticnapp-gitops-cluster"
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # Grants your current IAM SSO user full access to the cluster
  enable_cluster_creator_admin_permissions = true 

  eks_managed_node_groups = {
    demo_nodes = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 2
    }
  }
}
