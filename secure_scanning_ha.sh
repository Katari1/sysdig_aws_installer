#/bin/bash

#Important framework functions.
. framework.sh

#Create namespace
broadcast 'g' "Creating Namespace"
kcns sysdigcloud

#Create configmap
broadcast 'g' "Creating configmap from sysdigcloud/config.yaml"
ka sysdigcloud/config.yaml

#Create pull secret
broadcast 'g' "Creating Pull Secret"
ka sysdigcloud/pull-secret.yaml

#Create K8 ssl secret
broadcast 'g' "Creating K8 SSL Secret"
kc "secret tls sysdigcloud-ssl-secret --cert=server.crt --key=server.key"

#Create scanning & anchore secrets
broadcast 'g' "Creating Scanning & Anchore  secrets"
ka sysdigcloud/scanning-secrets.yaml
ka sysdigcloud/anchore-secrets.yaml

#Create cassandra service &statefulset
broadcast 'g' "Creating Cassandra Instances"
ka datastores/as_kubernetes_pods/manifests/cassandra/cassandra-service.yaml
ka datastores/as_kubernetes_pods/manifests/cassandra/cassandra-statefulset.yaml

#Create elasticsearch service & pods
broadcast 'g' "Creating Elasticsearch Instances"
ka datastores/as_kubernetes_pods/manifests/elasticsearch/elasticsearch-service.yaml
ka datastores/as_kubernetes_pods/manifests/elasticsearch/elasticsearch-statefulset.yaml

#Create mysql config, service, and pods
broadcast 'g' "Creating Msql Instance"
ka datastores/as_kubernetes_pods/manifests/mysql/mysql-cluster-statefulset.yaml
ka datastores/as_kubernetes_pods/manifests/mysql/mysql-router-statefulset.yaml

#Create Redis service & Pods
broadcast 'g' "Creating Redis Instance"
ka datastores/as_kubernetes_pods/manifests/redis/redis-primary-svc-statefulset.yaml
ka datastores/as_kubernetes_pods/manifests/redis/redis-primary-statefulset.yaml
ka datastores/as_kubernetes_pods/manifests/redis/redis-secondary-svc-statefulset.yaml
ka datastores/as_kubernetes_pods/manifests/redis/redis-secondary-statefulset.yaml
ka datastores/as_kubernetes_pods/manifests/redis/redis-sentinel-svc-statefulset.yaml
ka datastores/as_kubernetes_pods/manifests/redis/redis-sentinel-statefulset.yaml

#Create postgres service & pods
broadcast 'g' "Creating Postres Instance"
ka datastores/as_kubernetes_pods/manifests/postgres/postgres-statefulset.yaml
ka datastores/as_kubernetes_pods/manifests/postgres/postgres-service.yaml

broadcast 'r' "Waiting for Pods To Come Up"
wait_for_pods 10

#Starting Stateless Deployment
broadcast 'g' "Deploying Backend Components"
ka sysdigcloud/api-deployment.yaml
ka sysdigcloud/anchore-core-config.yaml
ka sysdigcloud/anchore-core-deployment.yaml

#Sleep again
broadcast 'r' "Sleeping For One Minute"
sleep 60s

#Deploy Rest of Backend
ka sysdigcloud/anchore-worker-config.yaml
ka sysdigcloud/anchore-worker-deployment.yaml
ka sysdigcloud/anchore-service.yaml
ka sysdigcloud/scanning-api-deployment.yaml
ka sysdigcloud/scanning-alertmgr-deployment.yaml
ka sysdigcloud/scanning-service.yaml
ka sysdigcloud/collector-deployment.yaml
ka sysdigcloud/worker-deployment.yaml
ka sysdigcloud/api-headless-service.yaml
ka sysdigcloud/collector-headless-service.yaml

#Sleep againa
broadcast 'r' "Waiting for Pods to come up"
wait_for_pods 10
#Fix ingress entries
fix_ingress

broadcast 'g' "Creating Ingress Controller"
ka sysdigcloud/ingress_controller/ingress-clusterrole.yaml
ka sysdigcloud/ingress_controller/ingress-clusterrolebinding.yaml
ka sysdigcloud/ingress_controller/ingress-role.yaml
ka sysdigcloud/ingress_controller/ingress-rolebinding.yaml
ka sysdigcloud/ingress_controller/ingress-serviceaccount.yaml
ka sysdigcloud/ingress_controller/default-backend-service.yaml
ka sysdigcloud/ingress_controller/default-backend-deployment.yaml
ka sysdigcloud/ingress_controller/ingress-configmap.yaml
ka sysdigcloud/ingress_controller/ingress-tcp-services-configmap.yaml
ka sysdigcloud/ingress_controller/ingress-daemonset.yaml
ka sysdigcloud/api-ingress-with-secure.yaml
ka sysdigcloud/ingress_controller/ingress-loadbalancer.yaml

broadcast 'g' "Adding CNAME Record for ELB"
cname_manipulation

broadcast 'r' "Waiting For All Pods To Come Up"
wait_for_pods 10

#Check for DNS to be ready
check_dns 10


deploy_agents_v2
deploy_watchtower
setup_scanning
enable_k8s_audit ~/.ssh/testinfrastructure.pem admin
update_falco_rules



