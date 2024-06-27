id: dt-k8s-otel-o11y-cluster
summary: astronomy-shop demo application on kubernetes setup
author: Tony Pope-Cruz

# OpenTelemetry Demo astronomy-shop on Kubernetes Setup
<!-- ------------------------ -->
## Overview 
Total Duration: 10

### What You’ll Learn Today
In this lab we'll create a Kubernetes cluster in GCP (GKE) and deploy the OpenTelemetry Demo application, astronomy-shop.  This is a foundation/prerequisite for several other labs utilizing this infrastructure deployment.

Lab tasks:
1. Create a Kubernetes cluster on Google GKE
2. Deploy OpenTelemetry's demo application, astronomy-shop
3. Deploy Istio Service Mesh

<!-- -------------------------->
## Technical Specification 
Duration: 2

#### Technologies Used
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine)
  - tested on GKE v1.29.4-gke.1043002
- [OpenTelemetry Demo astronomy-shop](https://opentelemetry.io/docs/demo/)
  - tested on release 1.10.0
- [Istio](https://istio.io/latest/docs/)
  - tested on v1.22.1

#### Reference Architecture
TODO

#### Prerequisites
- Google Cloud Account
- Google Cloud Project
- Google Cloud Access to Create and Manage GKE Clusters
- Google CloudShell Access
- [gcloud CLI](https://cloud.google.com/sdk/docs/install#linux)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [istio](https://istio.io/latest/docs/setup/getting-started/#download)
<!-- -------------------------->
## Setup
Duration: 8

#### Clone the repo to your home directory
Command:
```sh
git clone https://github.com/popecruzdt/dt-k8s-otel-o11y-cluster.git
```
Sample output:
> Cloning into 'dt-k8s-otel-o11y-cluster'...\
> ...\
> Receiving objects: 100% (12/12), 10.61 KiB | 1.77 MiB/s, done.

#### Move into repo base directory
Command:
```sh
cd dt-k8s-otel-o11y-cluster
```

#### Define user variables
*note: these can be updated with any regions you have access to*
```
example: 

ZONE=us-central1-c
NAME=<INITIALS>-k8s-otel-o11y
```
### GKE Cluster

#### Create GKE Kubernetes Cluster
Command:
```
gcloud container clusters create ${NAME} --zone=${ZONE} --machine-type=e2-standard-8 --num-nodes=1
```
Sample output:
> NAME: tpc-k8s-otel-o11y\
> LOCATION: us-central1-c\
> MASTER_VERSION: 1.29.4-gke.1043002\
> MASTER_IP: 34.46.195.237\
> MACHINE_TYPE: e2-standard-8\
> NODE_VERSION: 1.29.4-gke.1043002\
> NUM_NODES: 1\
> STATUS: RUNNING

#### Verify Cluster
Command:
```
kubectl version
```
Sample output:
> Client Version: v1.29.5\
> Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3\
> Server Version: v1.29.4-gke.1043002

#### Verify Helm
Command:
```
helm version
```
Sample output:
> version.BuildInfo{Version:"v3.9.3",\
> GitCommit:"414ff28d4029ae8c8b05d62aa06c7fe3dee2bc58",\
> GitTreeState:"clean", GoVersion:"go1.17.13"}

### Istio Service Mesh
https://istio.io/latest/docs/setup/getting-started/#download

#### Install Istio client (1.22+)
Command:
```
curl -L https://istio.io/downloadIstio | sh -
```

#### Move to the Istio package directory
Command:
```
cd istio-1.XX.Y
```
Where `XX.Y` is the version that was installed\

#### Add the `istioctl` client to path
Command:
```
export PATH=$PWD/bin:$PATH
```

#### Deploy Istio operator using `istioctl`
Command:
```
cd ..
istioctl install -f istio/istio-operator.yaml --skip-confirmation
```
Sample output:
> ✔ Istio core installed\
> ✔ Istiod installed\
> ✔ Egress gateways installed\
> ✔ Ingress gateways installed\
> ✔ Installation complete

### OpenTelemetry Demo - astronomy-shop
https://opentelemetry.io/docs/demo/kubernetes-deployment/

#### Add OpenTelemetry Helm repository
Command:
```
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
```
Sample output:
> "open-telemetry" has been added to your repositories

#### Create astronomy-shop namespace
Command:
```
kubectl create namespace astronomy-shop
```
Sample output:
> namespace/astronomy-shop created

#### Label astronomy-shop namespace for Istio
Command:
```
kubectl label namespace astronomy-shop istio-injection=enabled
```
Sample output:
> namespace/astronomy-shop labeled

#### Customize astronomy-shop helm values
```yaml
default:
  # List of environment variables applied to all components
  env:
    - name: OTEL_SERVICE_NAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: "metadata.labels['app.kubernetes.io/component']"
    - name: OTEL_COLLECTOR_NAME
      value: '{{ include "otel-demo.name" . }}-otelcol'
    - name: OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      value: cumulative
    - name: OTEL_RESOURCE_ATTRIBUTES
      value: 'service.name=$(OTEL_SERVICE_NAME),service.namespace=NAME_TO_REPLACE,service.version={{ .Chart.AppVersion }}'
```
> service.namespace=NAME_TO_REPLACE\
> service.namespace=INITIALS-k8s-otel-o11y

Command:
```sh
sed -i'' -e "s,NAME_TO_REPLACE,$NAME," astronomy-shop/default-values.yaml
```

#### Install astronomy-shop
Command:
```
helm install astronomy-shop open-telemetry/opentelemetry-demo --values astronomy-shop/default-values.yaml --namespace astronomy-shop
```
Sample output:
> NAME: astronomy-shop\
> LAST DEPLOYED: Fri Jun 14 20:27:54 2024\
> NAMESPACE: astronomy-shop\
> STATUS: deployed\
> REVISION: 1

#### Validate pods are running
Command:
```sh
kubectl get pod -n astronomy-shop

NAME                                                    READY   STATUS    RESTARTS      AGE
astronomy-shop-accountingservice-7b76cc8bb4-snwh8       2/2     Running   0             118s
astronomy-shop-adservice-f467c4d7b-v5k2h                2/2     Running   0             117s
astronomy-shop-cartservice-55b7c7979b-4zl4q             2/2     Running   0             116s
astronomy-shop-checkoutservice-b6ccc7778-h7vsj          2/2     Running   0             117s
astronomy-shop-currencyservice-68fdc6f644-p5dc2         2/2     Running   0             117s
astronomy-shop-emailservice-6448cfb47c-59ws4            2/2     Running   0             116s
astronomy-shop-flagd-9d96446f7-tc67j                    2/2     Running   0             118s
astronomy-shop-frauddetectionservice-69d59c47fc-wcm7k   2/2     Running   0             118s
astronomy-shop-frontend-b9fd4569-b2fc9                  2/2     Running   0             118s
astronomy-shop-frontendproxy-7db64d4858-gpl7t           2/2     Running   0             118s
astronomy-shop-imageprovider-686f9b8fcd-lrqfk           2/2     Running   0             117s
astronomy-shop-kafka-ccc558cf7-gvvnp                    2/2     Running   0             118s
astronomy-shop-loadgenerator-799b79c864-9865g           2/2     Running   0             116s
astronomy-shop-otelcol-7cb6b8487-z6k2f                  2/2     Running   0             118s
astronomy-shop-paymentservice-5b4998c7cc-bffz5          2/2     Running   0             116s
astronomy-shop-productcatalogservice-5884fcbcb7-6sncb   2/2     Running   0             116s
astronomy-shop-quoteservice-67bc5fd5-98gnp              2/2     Running   0             116s
astronomy-shop-recommendationservice-5dc597f5d4-ndp56   2/2     Running   0             117s
astronomy-shop-redis-6686b85c9d-zwvtl                   2/2     Running   0             116s
astronomy-shop-shippingservice-85d587457c-77brp         2/2     Running   0             116s
```

#### Deploy the Istio gateway for `astronomy-shop`
Command:
```sh
chmod 744 istio/deploy-istio-astronomy-shop.sh
```

Command:
```sh
./istio/deploy-istio-astronomy-shop.sh
```
Sample output:
> Waiting for external IP\
> Found external IP: 35.223.120.37\
> gateway.networking.istio.io/astronomy-shop-gateway created\
> virtualservice.networking.istio.io/astronomy-shop-httproute created

<!-- ------------------------ -->
## Demo The New Functionality
TODO

<!-- -------------------------->
## Wrap Up

### What You Learned Today 
By completing this lab, you created a Kubernetes cluster on GCP (GKE) and deployed the OpenTelemetry Demo application, astronomy-shop.
- The Kubernetes cluster can run containerized workloads
- The astronomy-shop application offers a convenient way to demo/explore cloud native technologies
- Istio Service Mesh provides networking, security, and observability capabilities for Kubernetes
- You are ready to proceed with additional labs that depend on this infrastructure deployment

<!-- ------------------------ -->
### Supplemental Material
TODO
