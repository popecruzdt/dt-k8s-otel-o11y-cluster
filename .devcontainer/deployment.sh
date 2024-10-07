#!/usr/bin/env bash

NAME=$(whoami)-k8s-otel-o11y   

# #istio setup
export PATH=$PWD/istio-1.22.1/bin:$PATH
istioctl install -f istio/istio-operator.yaml --skip-confirmation

sleep 30 
##########################
# update istio ingress
kubectl patch svc -n istio-system istio-ingressgateway --patch "$(cat deployment/patch.yaml)"
kubectl delete pod --all -n istio-system   

### 
# deploy astronomy shop
sed -i "s,NAME_TO_REPLACE,$NAME," astronomy-shop/default-values.yaml
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
kubectl create namespace astronomy-shop
kubectl label namespace astronomy-shop istio-injection=enabled
helm install astronomy-shop open-telemetry/opentelemetry-demo --values astronomy-shop/default-values.yaml --namespace astronomy-shop --version "0.31.0"

### delete me
#kubectl create namespace log-generator
# kubectl create namespace dynatrace

# sed -i "s,TENANTURL_TOREPLACE,$DT_URL," /workspaces/$RepositoryName/dynatrace/dynakube.yaml
# sed -i "s,CLUSTER_NAME_TO_REPLACE,github-codespace-cluster,"  /workspaces/$RepositoryName/dynatrace/dynakube.yaml

### delete me ?
#clusterName=`kubectl config view --minify -o jsonpath='{.clusters[].name}'`
#sed -i "s,{ENTER_YOUR_CLUSTER_NAME},$clusterName,"  /workspaces/$RepositoryName/dynatrace/values.yaml
#sed -i "s,{ENTER_YOUR_INGEST_TOKEN},$DT_LOG_INGEST_TOKEN,"  /workspaces/$RepositoryName/dynatrace/values.yaml

### delete me 
#sed -i "s,{YOUR_DT_URL},$DT_URL,"  /workspaces/$RepositoryName/deployment/LogGenerator.yaml
#sed -i "s,{YOUR_DT_LOG_INGEST_TOKEN},$DT_LOG_INGEST_TOKEN,"  /workspaces/$RepositoryName/deployment/LogGenerator.yaml
#Extract the tenant name from DT_URL variable
#tenantId=`echo $DT_URL | awk -F "[/]" '{print $3}'`
#sed -i "s,{ENTER_YOUR_TENANT_ID},$tenantId,"  /workspaces/$RepositoryName/dynatrace/values.yaml

### delete me
# Create secret for k6 to use
# kubectl -n log-generator create secret generic dt-details \
#   --from-literal=DT_ENDPOINT=$DT_URL \
#   --from-literal=DT_API_TOKEN=$DT_OPERATOR_TOKEN

# Deploy Dynatrace
# kubectl -n dynatrace create secret generic dynakube --from-literal="apiToken=$DT_OPERATOR_TOKEN" --from-literal="dataIngestToken=$DT_DATAINGEST_TOKEN"

# wget -O /workspaces/$RepositoryName/dynatrace/kubernetes.yaml https://github.com/Dynatrace/dynatrace-operator/releases/latest/download/kubernetes.yaml                                                           
# wget -O /workspaces/$RepositoryName/dynatrace/kubernetes-csi.yaml https://github.com/Dynatrace/dynatrace-operator/releases/latest/download/kubernetes-csi.yaml
# sed -i "s,cpu: 300m,cpu: 100m," /workspaces/$RepositoryName/dynatrace/kubernetes.yaml
# sed -i "s,cpu: 300m,cpu: 100m," /workspaces/$RepositoryName/dynatrace/kubernetes-csi.yaml
# # Shrink resource utilisation to work on GitHub codespaces (ie. a small environment)
# # Apply (slightly) customised manifests
# kubectl apply -f /workspaces/$RepositoryName/dynatrace/kubernetes.yaml
# kubectl apply -f /workspaces/$RepositoryName/dynatrace/kubernetes-csi.yaml
# kubectl -n dynatrace wait pod --for=condition=ready --selector=app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/component=webhook --timeout=300s
# kubectl -n dynatrace apply -f /workspaces/$RepositoryName/dynatrace/dynakube.yaml

#kubectl create secret generic dynatrace-otelcol-dt-api-credentials \
#  --from-literal=DT_ENDPOINT=$DT_URL \
#  --from-literal=DT_API_TOKEN=$DT_DATAINGEST_TOKEN

#helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
#helm repo update
#helm upgrade -i dynatrace-collector open-telemetry/opentelemetry-collector -f collector-values.yaml --wait

#install fluentbit for log ingestion
#helm repo add fluent https://fluent.github.io/helm-charts
#helm repo update
#helm install fluent-bit fluent/fluent-bit  -f /workspaces/$RepositoryName/dynatrace/values.yaml --create-namespace --namespace dynatrace-fluent-bit

### delete me
#kubectl apply -f deployment/LogGenerator.yaml -n log-generator

# Wait for Dynatrace to be ready
#kubectl -n dynatrace wait --for=condition=Ready pod --all --timeout=10m

### delete me
# Wait for travel advisor system to be ready
#kubectl -n log-generator wait --for=condition=Ready pod --all --timeout=10m

### Deploy dt-boutique
#kubectl apply -f https://raw.githubusercontent.com/kyledharrington/dt-boutique/main/kind-dt-boutique.yaml -n dt-boutique
