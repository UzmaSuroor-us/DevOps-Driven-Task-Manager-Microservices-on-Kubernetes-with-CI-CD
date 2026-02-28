# GitHub Actions Secrets Setup

## Required Secrets

Configure these secrets in your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

### 1. Docker Hub Credentials

```
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password-or-token
```

**How to get Docker Hub token:**
1. Login to Docker Hub
2. Go to Account Settings → Security
3. Click "New Access Token"
4. Name: "GitHub Actions"
5. Copy the token

### 2. Kubernetes Config

```
KUBE_CONFIG=<your-kubeconfig-content>
```

**How to get kubeconfig:**

```bash
# For local cluster (kind/minikube)
cat ~/.kube/config | base64 -w 0

# For cloud providers (AWS EKS)
aws eks update-kubeconfig --name your-cluster-name --region us-east-1
cat ~/.kube/config | base64 -w 0

# For Azure AKS
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
cat ~/.kube/config | base64 -w 0

# For GCP GKE
gcloud container clusters get-credentials cluster-name --zone us-central1-a
cat ~/.kube/config | base64 -w 0
```

## Setup Steps

### 1. Add Secrets to GitHub

```bash
# Navigate to your repository on GitHub
# Settings → Secrets and variables → Actions → New repository secret

# Add each secret:
Name: DOCKER_USERNAME
Value: your-dockerhub-username

Name: DOCKER_PASSWORD
Value: your-dockerhub-token

Name: KUBE_CONFIG
Value: <base64-encoded-kubeconfig>
```

### 2. Verify Secrets

After adding secrets, they should appear in:
**Settings → Secrets and variables → Actions → Repository secrets**

You should see:
- ✅ DOCKER_USERNAME
- ✅ DOCKER_PASSWORD
- ✅ KUBE_CONFIG

### 3. Test Pipeline

```bash
# Push to main branch to trigger pipeline
git add .
git commit -m "Add CI/CD pipeline"
git push origin main

# Or create a pull request to test PR validation
git checkout -b feature/test-cicd
git push origin feature/test-cicd
# Create PR on GitHub
```

## Pipeline Triggers

### Main CI/CD Pipeline
- **Trigger**: Push to `main` or `develop` branches
- **Actions**:
  - Build & test all services
  - Build & push Docker images
  - Deploy to Kubernetes
  - Security scan

### PR Validation
- **Trigger**: Pull request to `main` or `develop`
- **Actions**:
  - Build all services
  - Run tests
  - Validate Docker Compose
  - Validate Kubernetes manifests

## Troubleshooting

### Docker Hub Authentication Failed
```bash
# Verify credentials
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

# Check token permissions (must have Read & Write)
```

### Kubernetes Deployment Failed
```bash
# Verify kubeconfig is valid
echo $KUBE_CONFIG | base64 -d > /tmp/kubeconfig
export KUBECONFIG=/tmp/kubeconfig
kubectl get nodes

# Check cluster connectivity
kubectl cluster-info
```

### Build Failed
```bash
# Check Java version (must be 17)
java -version

# Check Maven version
mvn -version

# Clean and rebuild locally
mvn clean install
```

## Optional: Self-Hosted Runner

For faster builds, use a self-hosted runner:

```bash
# On your server
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
./config.sh --url https://github.com/YOUR_USERNAME/task-manager --token YOUR_TOKEN
./run.sh
```

## Pipeline Status Badge

Add to README.md:

```markdown
![CI/CD Pipeline](https://github.com/YOUR_USERNAME/task-manager/workflows/CI/CD%20Pipeline/badge.svg)
```
