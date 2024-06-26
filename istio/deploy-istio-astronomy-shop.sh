### get the ip adress of ingress ####
IP=""
while [ -z $IP ]; do
  echo "Waiting for external IP"
  IP=$(kubectl get svc istio-ingressgateway -n istio-system -ojson | jq -j '.status.loadBalancer.ingress[].ip')
  [ -z "$IP" ] && sleep 10
done
echo 'Found external IP: '$IP

### Update the ip adress for the ingress
sed -i "s,IP_TO_REPLACE,$IP," istio/istio-astronomy-shop.yaml

### Deploy the Kubernetes manifest
kubectl apply -f istio/istio-astronomy-shop.yaml
