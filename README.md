## NOTICE❗️❗️❗️

Please make sure you are currently under Wi-Fi ShifuTest(Password:12345678) so that you can connect to our device. 🪧

## Require

1. make sure you are **running** Shifu Demo from Task 1

2. Get the following images from Shifu Team:

   ```text
   shifu-tdengine-demo-arch64.tar.gz
   shifu-tdengine-demo-amd64.tar.gz
   ```

## Prepare

load all images to docker 🪞

```bash
tar -xvzf shifu-tdengine-demo-arch64.tar.gz
cd shifu-tdengine-demo
make docker-load-images
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
Create STable testTable (ts TIMESTAMP, rawData varchar(255)) TAGS (defaultTag varchar(255));
Create Table testSubTable Using testTable TAGS('Shifu');
Insert Into testSubTable Values(Now,'TestData');
Select * From testSubTable;
exit
```

🎉🎉 Congratulations on your successful installation of TDEngine! 👁️

## Install Shifu

you just need to use one command to install Shifu 😋

```bash
kubectl apply -f shifu_install.yml
```

## Run Shifu TelemetryService
First, you need to modify the value of  `spec/serviceSettings/SQLSetting/serverAddress` on  `devicedeploy/http-deviceshifu-telemetryservice.yaml`.
```yaml
--- #telemetry_service.yaml
spec:
  telemetrySeriveEndpoint: http://telemetryservice.shifu-service.svc.cluster.local
  serviceSettings:
    SQLSetting:
      serverAddress: 192.168.0.37:6041 # edit it to your your IP
      username: root
      secret: taosdata
      dbName: shifu
      dbTable: testSubTable
      dbtype: TDEngine

```

You can also change the dbTable to your table name in your TDEngine database, and of course you can change everything to what you want under SQLSetting. 🤗

Then, you can use the following command to install the telemetry service into your Kind cluster.

```bash
kubectl apply -f telemetryservicedeploy
```

🚀 Congratulations on your successful installation of Telemetry Service of Shifu! Flowing is the last Step you need to do. 👍

## Run deviceShifu to Connect to Temperature and humidity meter

You can only use on command to start it, too 🐎。

```bash
kubectl apply -f devicedeploy
```

# Enjoy the results of your work🕹

You can use the following command to access the TDEngine docker container.

```bash
docker exec -it tdengine taos
```

Use the following SQL command to display the data you have collected.

```sql
use shifu;
Select * From testSubTable;
```

😘 Thank you for experiencing all the demos. have fun today!