# echo 'Deploying App on Kubernetes'
# sudo su -s /bin/bash jenkins
# envsubst < k8s/petclinic_chart/values-template.yaml > k8s/petclinic_chart/values.yaml
# sed -i s/HELM_VERSION/${BUILD_NUMBER}/ k8s/petclinic_chart/Chart.yaml
# AWS_REGION=$AWS_REGION helm repo add stable-petclinic s3://microservices-app-helm-charts-ashuto91/stable/myapp/ || echo "repository name already exists"
# AWS_REGION=$AWS_REGION helm repo update
# helm package k8s/petclinic_chart
# AWS_REGION=$AWS_REGION helm s3 push --force petclinic_chart-${BUILD_NUMBER}.tgz stable-petclinic
# kubectl create ns petclinic-prod-ns || echo "namespace petclinic-prod-ns already exists"
# kubectl delete secret regcred -n petclinic-prod-ns || echo "there is no regcred secret in petclinic-prod-ns namespace"
# kubectl create secret generic regcred -n petclinic-prod-ns --from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json --type=kubernetes.io/dockerconfigjson
# AWS_REGION=$AWS_REGION helm repo update
# AWS_REGION=$AWS_REGION helm upgrade --install petclinic-app-release stable-petclinic/petclinic_chart --version ${BUILD_NUMBER} --namespace petclinic-prod-ns


#!/bin/bash

echo 'Deploying App on Kubernetes'

# Switch to the jenkins user and run the necessary commands
sudo su -s /bin/bash jenkins << 'EOF'
# Ensure the PATH includes the directories where helm and kubectl are located
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin

# Replace environment variables in values-template.yaml
envsubst < k8s/petclinic_chart/values-template.yaml > k8s/petclinic_chart/values.yaml

# Replace HELM_VERSION in Chart.yaml with the BUILD_NUMBER
sed -i s/HELM_VERSION/${BUILD_NUMBER}/ k8s/petclinic_chart/Chart.yaml

# Add Helm repository if it doesn't already exist
AWS_REGION=$AWS_REGION helm repo add stable-petclinic s3://microservices-app-helm-charts-ashuto91/stable/myapp/ || echo "repository name already exists"

# Update Helm repositories
AWS_REGION=$AWS_REGION helm repo update

# Package the Helm chart
helm package k8s/petclinic_chart

# Push the Helm chart to the repository
AWS_REGION=$AWS_REGION helm s3 push --force petclinic_chart-${BUILD_NUMBER}.tgz stable-petclinic

# Create namespace if it doesn't exist
kubectl create ns petclinic-prod-ns || echo "namespace petclinic-prod-ns already exists"

# Delete and recreate the regcred secret in the petclinic-prod-ns namespace
kubectl delete secret regcred -n petclinic-prod-ns || echo "there is no regcred secret in petclinic-prod-ns namespace"
kubectl create secret generic regcred -n petclinic-prod-ns --from-file=.dockerconfigjson=/var/lib/jenkins/.docker/config.json --type=kubernetes.io/dockerconfigjson

# Update Helm repositories again
AWS_REGION=$AWS_REGION helm repo update

# Upgrade or install the Helm release
AWS_REGION=$AWS_REGION helm upgrade --install petclinic-app-release stable-petclinic/petclinic_chart --version ${BUILD_NUMBER} --namespace petclinic-prod-ns
EOF

