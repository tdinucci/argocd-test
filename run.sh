#! /bin/bash 
IP=$(ipconfig getifaddr en0)

echo "Local IP: $IP"
echo "service_cluster_ip: $IP" > chart/values.yaml

mkdir -p manifests
helm template chart -s templates/deployment-cluster.yaml > manifests/deployment-cluster.yaml
helm template chart -s templates/service-cluster.yaml > manifests/service-cluster.yaml

kind create cluster --image kindest/node:v1.23.13 --config manifests/deployment-cluster.yaml 
kind create cluster --image kindest/node:v1.23.13 --config manifests/service-cluster.yaml
##### kind create cluster --image kindest/node:v1.12.10 --config manifests/service-cluster.yaml

kubectl --context kind-deployments create namespace argocd
kubectl --context kind-deployments apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "\nWaiting for Argo CD components initialise..."
kubectl wait --timeout=120s --context kind-deployments -n argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server

ARGO_ADMIN_PASSWORD=$(kubectl --context kind-deployments -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

argocd login localhost --kube-context kind-deployments --username admin --password $ARGO_ADMIN_PASSWORD --port-forward --port-forward-namespace argocd
argocd cluster add kind-services --kube-context kind-deployments --name services-cluster --port-forward --port-forward-namespace argocd --yes

kubectl --context kind-services create namespace io-gmon
helm template chart -s templates/guestbook-application.yaml | kubectl apply --context kind-deployments -f -

rm -rf manifests

echo -e "\n\n\n*******************************"
echo "ArgoCD UI: https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGO_ADMIN_PASSWORD"
echo -e "\nTell your browser you're OK with an untrusted cert :) "
echo -e "*******************************\n\n"

kubectl --context kind-deployments port-forward svc/argocd-server -n argocd 8080:443
