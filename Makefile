NO_COLOR=\033[0m
INFO_COLOR=\033[0;33m

PHONY: start
start: octoshield pacman


.PHONY: pacman
pacman:
	@minikube start -p pacman
	@minikube profile pacman
	$(call pp,"Creating 'monitoring' namespace...")
	@kubectl create namespace monitoring  > /dev/null
	$(call pp,"Starting Prometheus...")
	@kubectl create configmap prometheus-config --from-file=prometheus/prometheus-config.yaml -nmonitoring  > /dev/null
	@kubectl apply -f prometheus/prometheus.yaml -nmonitoring > /dev/null
	@kubectl create -f prometheus/prometheus-node-exporter.yaml -nmonitoring > /dev/null
	$(call pp,"Prometheus URL:")
	@minikube service --url --namespace=monitoring prometheus
	$(call pp,"Starting Alertmanager...")
	@kubectl create configmap alertmanager-config --from-file=alertmanager/alertmanager-config.yaml -nmonitoring  > /dev/null
	@kubectl create -f alertmanager/alertmanager.yaml -nmonitoring  > /dev/null
	$(call pp,"Alertmanager URL:")
	@minikube service --url --namespace=monitoring alertmanager
	$(call pp,"Starting Grafana...")
	@kubectl create -f grafana/grafana.yaml -nmonitoring  > /dev/null
	$(call pp,"Grafana URL \(default credentials admin/admin\):")
	@minikube service --url --namespace=monitoring grafana # Add Prometheus as a datasource http://prometheus:9090 (defaults to admin/admin)
	
	
	$(call pp,"Octoshield URL:")
	@minikube service octoshield --url
	@rm -rf build/config.yml
	@minikube profile octoshield 
	@echo "token: TEST_TOKEN\nserverUrl: $(minikube service octoshield --url)\nenv: PREPROD\ntags:\n  pod: pacman" >> build/octoshield/config.yml
	$(call pp,"build pacman")
	minikube profile pacman
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

.PHONY: octoshield
octoshield:
	@minikube start -p octoshield
	minikube profile octoshield
	$(call pp,"starting Octoshield")
	@kubectl apply -f octoshield
	$(call pp,"Octoshield URL:")
	@minikube service octoshield --url


PHONY: stop
stop:
	$(call pp,"Deleting octoshield cluster")
	@ minikube delete -p octoshield
	$(call pp,"Deleting pacman cluster")
	@ minikube delete -p pacman
	@minikube delete
	$(call pp,"Done...")

define pp
    @echo "$(INFO_COLOR)$(1)$(NO_COLOR)"
endef
