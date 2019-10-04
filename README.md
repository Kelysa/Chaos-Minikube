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

- minikube service list



### Auto-Scaling

- Check HPA demo live:

Open three different terminal

- Terminal 1 :``` watch -n 1 kubectl get pods ```

- Terminal 2 :``` watch -n 1 kubectl get hpa ```

- Terminal 3 :```ab -c 5 -n 1000 -t 100000 http://192.168.99.100:30001/```
