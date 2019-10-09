NO_COLOR=\033[0m
INFO_COLOR=\033[0;33m

PHONY: start
start:
	@minikube start
	$(call pp,"Creating 'monitoring' namespace...")
	@kubectl create namespace monitoring --context=minikube > /dev/null
	$(call pp,"Starting Prometheus...")
	@kubectl create configmap prometheus-config --from-file=prometheus/prometheus-config.yaml -nmonitoring --context=minikube > /dev/null
	@kubectl apply -f prometheus/prometheus.yaml -nmonitoring --context=minikube > /dev/null
	@kubectl create -f prometheus/prometheus-node-exporter.yaml -nmonitoring --context=minikube > /dev/null
	$(call pp,"Prometheus URL:")
	@minikube service --url --namespace=monitoring prometheus
	$(call pp,"Starting Alertmanager...")
	@kubectl create configmap alertmanager-config --from-file=alertmanager/alertmanager-config.yaml -nmonitoring --context=minikube > /dev/null
	@kubectl create -f alertmanager/alertmanager.yaml -nmonitoring --context=minikube > /dev/null
	$(call pp,"Alertmanager URL:")
	@minikube service --url --namespace=monitoring alertmanager
	$(call pp,"Starting Grafana...")
	@kubectl create -f grafana/grafana.yaml -nmonitoring --context=minikube > /dev/null
	$(call pp,"Grafana URL \(default credentials admin/admin\):")
	@minikube service --url --namespace=monitoring grafana # Add Prometheus as a datasource http://prometheus:9090 (defaults to admin/admin)
	
	
	$(call pp,"starting Octoshield")
	@kubectl apply -f octoshield
	$(call pp,"Octoshield URL:")
	@minikube service octoshield --url
	@rm -rf build/config.yml
	@echo "token: TEST_TOKEN\nserverUrl: $(minikube service octoshield --url)\nenv: PREPROD\ntags:\n  pod: pacman" >> build/config.yml
	$(call pp,"build pacman")
	@sudo docker build -t pacman build/ > /dev/null
	$(call pp,"tag pacman")
	@sudo docker tag pacman kelysa/pacman:lastest 
	$(call pp,"push pacman")
	@sudo docker push kelysa/pacman
	$(call pp,"starting pacman")
	@minikube addons enable metrics-server
	@kubectl create -f pacman/persistentvolume.yml
	@kubectl create -f pacman/deployment.yml
	@kubectl create -f pacman/hpa.yml
	@kubectl create -f pacman/service.yml
	$(call pp,"Pacman URL:")
	@minikube service pacman --url
	$(call pp,"Done...")

PHONY: stop
stop:
	$(call pp,"Deleting 'monitoring' namespace...")
	@kubectl delete namespace monitoring --context=minikube > /dev/null
	@kubectl delete clusterrolebinding prometheus --context=minikube > /dev/null
	@kubectl delete clusterrole prometheus --context=minikube > /dev/null
	minikube stop
	minikube delete
	$(call pp,"Done...")

define pp
    @echo "$(INFO_COLOR)$(1)$(NO_COLOR)"
endef
