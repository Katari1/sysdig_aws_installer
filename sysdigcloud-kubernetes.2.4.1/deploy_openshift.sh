#/bin/bash

#Important framework functions.
. framework.sh

#Create namespace
broadcast 'g' "Creating Namespace and prepping openshift cluster"
openshift_prep

#Creating storageclass
#broadcast 'g' "Creating Local Disk Storageclass"
#oc -n sysdigcloud apply -f storageclass/local-disk.yaml

#creating local storage configmap
#broadcast 'g' "Creating local storage configmap"
#oc -n sysdigcloud apply -f storageclass/local-disk-configmap.yaml

#broadcast 'g' "Creating template and deploying provisioner"
#oc -n sysdigcloud apply -f storageclass/local-storage-provisioner-template.yaml
#broadcast 'r' "Waiting for Pods To Come Up"
#wait_for_pods 10

#Creating PV & PVCs
#broadcast 'g' "Creating PV & PVCs"
#ka pv/

#Create configmap
broadcast 'g' "Creating configmap from sysdigcloud/config.yaml"
ka sysdigcloud/config.yaml

#Create pull secret
broadcast 'g' "Creating Pull Secret"
ka sysdigcloud/pull-secret.yaml

#Create K8 ssl secret
broadcast 'g' "Creating K8 SSL Secret"
kc "secret tls sysdigcloud-ssl-secret --cert=server.crt --key=server.key"
kc "secret tls sysdigcloud-ssl-secret-collector --cert=server.crt --key=server.key"
#Create scanning & anchore secrets
broadcast 'g' "Creating Scanning & Anchore  secrets"
ka sysdigcloud/scanning-secrets.yaml
ka sysdigcloud/anchore-secrets.yaml

#Create cassandra service &statefulset
broadcast 'g' "Creating Cassandra Instances"
ka datastores/as_kubernetes_pods/manifests/cassandra/cassandra-service.yaml
ka datastores/as_kubernetes_pods/manifests/cassandra/cassandra-statefulset.yaml

#Checking for elasticsearch certs
broadcast 'g' 'Checking for Elasticsearch Certs'
generate_elasticsearch_certs

#Creating Secure ELasticsearch Secrets
broadcast 'g' 'Creating Secret for Elasticsearch Certs'
kc "secret generic ca-certs --from-file=generated_elasticsearch_certs"

#Creat Elasticsearch secret for Searchguard Roles
broadcast 'g' 'Creating Elasticsearch Secrets for Searchguard'
ka datastores/as_kubernetes_pods/manifests/elasticsearch/sg_users/sg_admin_secret.yml
ka datastores/as_kubernetes_pods/manifests/elasticsearch/sg_users/sg_readonly_secret.yml
#Creating Searchguard Config Files
kc "secret generic sg-config-files --from-file=datastores/as_kubernetes_pods/manifests/elasticsearch/sgconfig"

#Create elasticsearch service & pods
broadcast 'g' "Creating Elasticsearch Instances"
ka datastores/as_kubernetes_pods/manifests/elasticsearch/elasticsearch-service.yaml
ka datastores/as_kubernetes_pods/manifests/elasticsearch/elasticsearch-statefulset.yaml

#Create mysql config, service, and pods
broadcast 'g' "Creating Msql Instance"
ka datastores/as_kubernetes_pods/manifests/mysql/mysql-sts.yaml

#Create Redis service & Pods
broadcast 'g' "Creating Redis Instance"
ka datastores/as_kubernetes_pods/manifests/redis/redis-deployment.yaml

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
ka sysdigcloud/scanning-alertmgr-service.yaml
#ka sysdigcloud/collector-deployment.yaml
ka sysdigcloud/openshift/openshift-collector-service.yaml
ka sysdigcloud/worker-deployment.yaml
ka sysdigcloud/openshift/openshift-collector-deployment.yaml
ka sysdigcloud/api-headless-service.yaml
#ka sysdigcloud/collector-headless-service.yaml
oc -n sysdigcloud apply -f  sysdigcloud/openshift/openshift-collector-router.yaml
ka sysdigcloud/anchore-enterprise-license.yaml
ka sysdigcloud/anchore-reports-config.yaml
ka sysdigcloud/anchore-reports-service.yaml
ka sysdigcloud/anchore-reports-deployment.yaml

#Sleep againa
broadcast 'r' "Waiting for Pods to come up"
wait_for_pods 10

#Fix ingress entries
fix_ingress

broadcast 'g' "Creating Ingress Controller"
#ka sysdigcloud/ingress_controller/ingress-clusterrole.yaml
#ka sysdigcloud/ingress_controller/ingress-clusterrolebinding.yaml
#ka sysdigcloud/ingress_controller/ingress-role.yaml
#ka sysdigcloud/ingress_controller/ingress-rolebinding.yaml
#ka sysdigcloud/ingress_controller/ingress-serviceaccount.yaml
#ka sysdigcloud/ingress_controller/default-backend-service.yaml
#ka sysdigcloud/ingress_controller/default-backend-deployment.yaml
#ka sysdigcloud/ingress_controller/ingress-configmap.yaml
#ka sysdigcloud/ingress_controller/ingress-tcp-services-configmap.yaml
#ka sysdigcloud/ingress_controller/ingress-daemonset.yaml
ka sysdigcloud/api-ingress-with-secure.yaml
oc -n sysdigcloud apply -f  sysdigcloud/openshift/openshift-collector-router.yaml

broadcast 'r' "Waiting For All Pods To Come Up"
wait_for_pods 10



