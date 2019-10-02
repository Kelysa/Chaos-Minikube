## Run 
Apply all k8s manifests to create monitoring namespace with Prometheus and Grafana:
```bash
make start
```
  
Delete all previously created resources:
```bash
make stop
```

Wait 2-3 minute before using minikube dashboard

## Configure Grafana
Add Prometheus data source and set the HTTP URL `http://prometheus:9090`.  
Test by running the following query via Explore:
```
avg(irate(container_cpu_usage_seconds_total{namespace=~"monitoring"}[5m]) * 100) by (pod_name)
```

- kubectl describe node minikube

- kubectl top node

- kubectl top pods --all-namespaces
