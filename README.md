## IMPORTANT❗️❗️❗️

### Please make sure you are currently under Wi-Fi ShifuTest(Password:12345678) so that you can connect to our device. 🪧

## Prepare

load all images to docker 🪞

```bash
make buildx-build-driver-image
make kind-load-images
```

## Install TDEngine

run tdengine docker container 🏃‍♂️

```bash
docker run -d -p 6030:6030 -p 6041:6041 -p 6043-6049:6043-6049 -p 6043-6049:6043-6049/udp --name tdengine tdengine/tdengine:3.0.1.4
```

make sure it is running:

```bash
docker ps| grep tdengine
```

```text
8dc20c5ea43b   tdengine/tdengine:3.0.1.4                        "/tini -- /usr/bin/e…"   About a minute ago   Up About a minute   0.0.0.0:6030->6030/tcp, 0.0.0.0:6041->6041/tcp, 0.0.0.0:6043-6049->6043-6049/tcp, 0.0.0.0:6043-6049->6043-6049/udp   tdengine
```

go into tedngine and init table 🚪
```bash
docker exec -it tdengine taos
```

Init TDEngine and Insert a default Data 🕹

```sql
Create database shifu;
Use shifu;
Create TABLE Temperature (ts TIMESTAMP, v FLOAT);
Create TABLE Humidity (ts TIMESTAMP, v FLOAT);
SHOW TABLES;
exit
```

🎉🎉 Congratulations on your successful installation of TDEngine! 👁️

## Install Shifu

you just need to use one command to install Shifu 😋

```bash
kubectl apply -f shifu_install.yml
```

## Run Shifu TelemetryService
First, you need to modify `devicedeploy/http-deviceshifu-telemetryservice.yaml`, and change the value of  `spec/serviceSettings/SQLSetting/serverAddress`.

```yaml
--- #telemetry_service.yaml
apiVersion: shifu.edgenesis.io/v1alpha1
kind: TelemetryService
metadata:
  name: push-endpoint-1
  namespace: devices
spec:
  telemetrySeriveEndpoint: http://telemetryservice.shifu-service.svc.cluster.local
  serviceSettings:
    SQLSetting:
      serverAddress: [YOUR_IP]:6041 # edit it to your your IP
      username: root
      secret: taosdata
      dbName: shifu
      dbTable: Temperature
      dbtype: TDengine
---
apiVersion: shifu.edgenesis.io/v1alpha1
kind: TelemetryService
metadata:
  name: push-endpoint-2
  namespace: devices
spec:
  telemetrySeriveEndpoint: http://telemetryservice.shifu-service.svc.cluster.local
  serviceSettings:
    SQLSetting:
      serverAddress: [YOUR_IP]:6041 # edit it to your your IP
      username: root
      secret: taosdata
      dbName: shifu
      dbTable: Humidity
      dbtype: TDengine


```

You can also change the dbTable to your table name in your TDEngine database, and of course you can change everything to what you want under SQLSetting. 🤗

Then, you can use the following command to install the telemetry service into your Kind cluster.

```bash
kubectl apply -f telemetryservicedeploy
```

🚀 Congratulations on your successful installation of Shifu's Telemetry Service! Following is the last step you need to do. 👍

## Run deviceShifu to Connect to Temperature and humidity meter

🐎 One-liner:

```bash
kubectl apply -f devicedeploy
```
By default, the tdengine's secret which store the username and password in the file `http-deviceshifu-secret.yaml`
If you want to create secret by yourself, you can use following command to create
```bash
kubectl create secret  generic taosdata --from-literal=username="root" --from-literal=password="taosdata" -n devices
```

# Enjoy the results of your work🕹

You can use the following command to access the TDEngine docker container.

```bash
docker exec -it tdengine taos
```

Use the following SQL command to display the data you have collected.

```sql
use shifu;
Select * From Temperature;
Select * From Humidity;
```

You should see something like this:
![temp&hum](images/temp&hum.png)

t is the current temperature reading, and h is the current humidity reading.


😘 Thank you for experimenting all the demos. Have fun today!

# Clean up

```bash
kubectl delete -f devicedeploy && kubectl delete -f telemetryservicedeploy
docker stop tdengine
```
