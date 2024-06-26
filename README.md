id: dt-k8s-otel-istio-lab
summary: dynatrace istio service mesh observability for kubernetes using opentelemetry
author: Tony Pope-Cruz
last update: 6/25/2024

# Kubernetes Istio Service Mesh Observability with OpenTelemetry & Dynatrace
<!-- ------------------------ -->
## Overview 
Duration: 10

### What You’ll Learn Today
Provide a executive summary of the topic we're going to cover 
- what is it?
- why is it important?
- who is the target audience/ persona
- how does this benefit the audience/ persona?
- What problem are we solving?
- What is the value of this 
- what will the audidence actually learn?

![ENVISION THE FUTURE!](img/concepts.png)

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

<!-- -------------------------->
## Technical Specification 
Duration: 5

### Detail the technical requirements 
- Technologies in use
  - Versioning if relevant  
- Relevant architecture/ network / traffic flow diagram
- Prerequisites for setup
  - VM specification/ container/  host sizing, 
  - cli binaries / git repos/ other software needed


![I'm a relevant image!](img/lab-environment.png)


Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.


<!-- -------------------------->
## Setup
Duration: 15

### Prerequisites


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
```
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
sed -i "s,NAME_TO_REPLACE,$NAME," astronomy-shop/default-values.yaml
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
Duration: 15

### Make the sausage
- execute the demo on how to solve the problem statement you posed
- This might just be more steps (?)
- This might just be a power point presentation

![I'm a relevant image!](img/livedemo.png)

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.


<!-- -------------------------->
## Wrap Up
Duration: 5
### What You Learned Today 
Review all the points you made at the start:
- What did the audience just learn?
- Why is this gained knowledge important?
- How will this knowledge now benefit the audience/ persona?
- What problem have we solved?
- Q&A 

<!-- ------------------------ -->
### Supplemental Material
Duration: 1

- Include all refence documentation links here
  - Any links included in the code lab should be here
  - Relevant links not explicitcly called out about (like code lab formatting beow)

- [Markdown Formatting Refernce](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
- [Codelab Formatting Guide](https://github.com/googlecodelabs/tools/blob/master/FORMAT-GUIDE.md)

`have a great time`

![kthnxbai](img/waving.gif)
