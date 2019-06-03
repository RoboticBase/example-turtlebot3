# Change Log

## [Unreleased]
* We will employ the example of "wirecloud" running on RoboticBase-core
* We will employ the example of "kurento" running on RoboticBase-core

## [0.4.2]
### Changed
* create the subdomains and routing rules of "kibana" and "grafana", and expose them to Internet.

## [0.4.1]
### Changed
* update components and documents to adjust [FIWARE Release 7.6](https://github.com/FIWARE/catalogue/releases/tag/FIWARE_7.6)
    * Business Logic components

        |component|version|(previous version)|
        |:--|:--|:--|
        |cmd-proxy|0.2.0|-|
        |robot-visualization|0.2.1|-|
    * Remote Deploy components

        |component|version|(previous version)|
        |:--|:--|:--|
        |mqtt-kube-operator|0.2.0|(0.1.0)|
    * Robot environments

        |component|version|(previous version)|
        |:--|:--|:--|
        |OS|Ubuntu 16.04.6|(Ubuntu 16.04.5)|
        |docker|18.09.5|(18.06.1)|
        |minikube|1.0.0|(0.34.1)|

## [0.4.0]
### Changed
* split repository ([core](https://github.com/RoboticBase/core) and [example-turtlebot3](https://github.com/RoboticBase/example-turtlebot3))
* update components and documents to adjust [FIWARE Release 7.5.1](https://github.com/Fiware/catalogue/releases)

* cmd-proxy
    * techsketch/fiware-cmd-proxy:0.1.1 -> roboticbase/fiware-cmd-proxy:0.2.0
* robot-visualization
    * techsketch/fiware-robot-visualization:0.2.0 -> roboticbase/fiware-robot-visualization:0.2.1
    * change `CYGNUS_MONGO_ATTR_PERSISTENCE` (column -> row)

## [0.3.0]
### Added
* employed "Cygnus ElasticsearchSink"
* employed "ROS bridge and ROS operator"

## [0.2.0]
### Changed
* testd on Azure AKS(1.11.2) and minikube(1.10.0)
* employed "RabbitMQ" as MQTT Broker and Message Queue instead of "VerneMQ".
    * "etcd" and "fiware-mqtt-msgfilter" were no longer needed.

### Added
* employed "Prometheus & Grafana" as monitoring of Kubernetes.
* employed "Elasticsearch & fluentd & Kibana" as logging of Kubernetes.
* added "[mqtt-kube-operator](https://github.com/tech-sketch/mqtt-kube-operator)" in order to enable remote deployment of ROS programs.

### Removed
* discontinued to use "VerneMQ"
* discontinued to use "etcd"
* discontinued to use "fiware-mqtt-msgfilter"

## [0.1.1]
### Changed
* testd on Azure AKS(1.10.3) and minikube(1.10.0)

### Added
* employed "jupyter notebook" as operable documents.
* employed "turtlebot3 (simulator and real robot)" as ROS robot.

### Removed
* discontinued to use "turtlesim" and "gopigo".

## [0.1.0]
### Added
* deployed FIWARE (orion, iotagent-ul, cygnus) on Kubernetes.
    * tested on Azure AKS(1.9.6) and minikube(1.9.4).
* employed "Ambassador" as API Gateway.
* employed "VerneMQ" as MQTT Broker.
    * in order to ignore duplicated messages, "etcd" and "[fiware-mqtt-msgfilter](https://github.com/tech-sketch/fiware-mqtt-msgfilter)" were used.
* employed "turtlesim" and "gopigo" as ROS robot.
