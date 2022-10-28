buildx-build-driver-image:
	docker buildx build --platform=linux/amd64 -f Dockerfile.modbusdriver -t edgehub/modbus-th-driver:nightly . --load

buildx-build-image-deviceshifu-http-http:
	cd shifu && docker buildx build --platform=linux/$(shell go env GOARCH) -f dockerfiles/Dockerfile.deviceshifuHTTP \
		-t edgehub/deviceshifu-http-http:nightly . --load && cd ..

build-shifu-image:
	cd shifu && docker buildx build --platform=linux/$(shell go env GOARCH) -f pkg/k8s/crd/Dockerfile -t edgehub/shifu-controller:nightly . --load && cd ..

build-telemetryservice:
	cd shifu && make buildx-build-image-telemetry-service && cd ..

pull-tdengint-image:
	docker pull tdengine/tdengine:3.0.1.4

pull-rbac-image:
	docker pull quay.io/brancz/kube-rbac-proxy:v0.13.1

docker-save-images:
	docker save quay.io/brancz/kube-rbac-proxy:v0.13.1 > ./images/kube-rbac-proxy.tar.gz
	docker save edgehub/modbus-th-driver:nightly > ./images/modbus-th-driver.tar.gz
	docker save edgehub/shifu-controller:nightly > ./images/shifu-controller.tar.gz
	docker save tdengine/tdengine:3.0.1.4 > ./images/tdengine.tar.gz
	docker save edgehub/telemetryservice:nightly > ./images/telemetryservice.tar.gz
	docker save edgehub/deviceshifu-http-http:nightly > ./images/deviceshifu-http-http.tar.gz

docker-load-images:
	docker load < ./images/kube-rbac-proxy.tar.gz
	docker load < ./images/modbus-th-driver.tar.gz
	docker load < ./images/shifu-controller.tar.gz
	docker load < ./images/tdengine.tar.gz
	docker load < ./images/telemetryservice.tar.gz
	docker load < ./images/deviceshifu-http-http.tar.gz

kind-load-images:
	kind load docker-image quay.io/brancz/kube-rbac-proxy:v0.13.1
	kind load docker-image edgehub/modbus-th-driver:nightly
	kind load docker-image edgehub/shifu-controller:nightly
	kind load docker-image edgehub/deviceshifu-http-http:nightly
	kind load docker-image edgehub/telemetryservice:nightly
