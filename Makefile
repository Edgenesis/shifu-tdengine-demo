buildx-build-driver-image:
	docker buildx build -f Dockerfile.modbusdriver -t edgehub/modbus-th-driver:nightly . --load

buildx-build-image-deviceshifu-http-http:
	docker buildx build --platform=linux/amd64 -f shifu/dockerfiles/Dockerfile.deviceshifuHTTP \
		-t edgehub/deviceshifu-http-http:nightly --load

build-shifu-image:
	cd shifu && docker buildx build --platform=linux/amd64 -f shifu/pkg/k8s/crd/Dockerfile -t edgehub/shifu-controller:nightly . --load

pull-tdengint-image:
	docker pull tdengine/tdengine:3.0.1.4

docker-save-images:
	docker save > ./images/kube-rbac-proxy.tar.gz
	docker save > ./images/modbus-th-driver.tar.gz
	docker save > ./images/shifu-controller.tar.gz
	docker save > ./images/tdengine.tar.gz
	docker save > ./images/telemetryservice.tar.gz

docker-load-images:
	docker load < ./images/kube-rbac-proxy.tar.gz
	docker load < ./images/modbus-th-driver.tar.gz
	docker load < ./images/shifu-controller.tar.gz
	docker load < ./images/tdengine.tar.gz
	docker load < ./images/telemetryservice.tar.gz

kind-load-images:
	kind load docker-image quay.io/brancz/kube-rbac-proxy:v0.13.1
	kind load docker-image edgehub/modbus-th-driver:nightly
	kind load docker-image edgehub/shifu-controller:nightly
	kind load docker-image tdengine/tdengine:3.0.1.4
	kind load docker-image edgehub/telemetryservice:nightly
