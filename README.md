# RoboticBase example: Deploy robot programs on TurtleBot3

This repository is example of "RoboticBase-core".

## Description
"RoboticBase" is a robot management platform based on [FIWARE](http://www.fiware.org/) which enables you to manage and operate many kinds of robots and IoT devices as interactions of contexts.

"RoboticBase" allows robots to collaborate with IoT devices, Open Data, human beings and so on. You can connect a robot to "RoboticBase" using the open APIs of the robot, and operate the robot through those APIs. In turn, "RoboticBase" has an ability to manage ROS. If you connect a ROS robot to "RoboticBase", you can operate the robot directly without restrictions.  
For example, you can deploy a ROS program to the robot and access the raw data of the robot through "RoboticBase".

![roboticbase-core-architecture.png](/docs/images/roboticbase-core-architecture.png)

|component|summary|
|:--|:--|
|[kubernetes](https://kubernetes.io/)|Container Orchestration Platform|
|fiware-cmd-proxy|Business Logic component working with FIWARE orion|

|gamepad|summary|
|:--|:--|
|[gamepad](https://github.com/RoboticBase/fiware-gamepad-controller)|Gamepad Controller connecting FIWARE|

|robot(Android)|summary|
|:--|:--|
|[robot(Android)](https://github.com/RoboticBase/fiware_xperiahello)|Android Application for [Xperia Hello!](https://www.sonymobile.co.jp/product/smartproducts/g1209/)|

|turtlebot3|summary|
|:--|:--|
|[deployer](https://github.com/RoboticBase/mqtt-kube-operator)|MQTT client to deploy (or delete) a resource to its own Kubernetes|
|[bridge](https://github.com/RoboticBase/fiware_ros_turtlebot3_bridge)|ROS package to act as a bridge FIWARE orion and ROS|
|[operator](https://github.com/RoboticBase/fiware_ros_turtlebot3_operator)|ROS package to control turtlebot3 (simulator and physical robot)|

## An experiment to prove our concept
We and University of Aizu have been performed an experiment to guide a visitor by collaborating with heterogeneous robots, IoT devices and people through this Robot Platform on Nov. 6th - 8th , 2018.

Please see this repository [ogcaizu/ogc-poc1](https://github.com/ogcaizu/ogc-poc1).

[![video](http://img.youtube.com/vi/D9NPxxYgPa0/0.jpg)](https://youtu.be/D9NPxxYgPa0)

## Requirements

### When you use macOS,

* kubernetes client PC

||version|
|:--|:--|
|OS|macOS Sierra 10.12.6|
|azure cli|2.0.45|
|kubectl|1.11.2|
|helm|2.10.0|
|envsubst|0.19.8.1|

* minikube
    * when you use monitoring & logging, you have to give **4 cpu & 8192 MB memories** to minikube.

||version|
|:--|:--|
|OS|macOS Sierra 10.12.6|
|VirtualBox|5.2.12 r122591|
|minikube|0.34.1|
|kubernetes|1.12.5|

### When you use Ubuntu,
* kubernetes client PC

||version|
|:--|:--|
|OS|Ubuntu 16.04|
|kubectl|1.12.2|
|helm|2.11.0|
|envsubst|0.19.7|

* minikube
    * when you use monitoring & logging, you have to give **4 cpu & 8192 MB memories** to minikube.

||version|
|:--|:--|
|OS|Ubuntu 16.04|
|VirtualBox|5.2.14 r123301|
|minikube|0.34.1|
|kubernetes|1.12.5|

* Azure AKS
    * when you use monitoring & logging, you have to use the vm series which supports `Premium Storage` such as `Dsv3-series`.

||version|
|:--|:--|
|region|japaneast|
|kubernetes|1.12.5|

## getting started
1. deploy [RoboticBase-core](https://github.com/RoboticBase/core)

1. install jupyter notebook

    ```bash
    $ cd docs
    $ ./setup_jupyter_notebook.sh
    ```
1. start jupyter notebook

    ```bash
    $ ./start_jupyter_notebook.sh
    ```

### Microsoft Azure AKS

1. setup environment variables

    ```bash
    $ cp azure_aks/env.template azure_aks/env
    $ vi env
    ```
1. start pods on Azure AKS -- [/docs/azure_aks/01_start_pods.ipynb](/docs/azure_aks/02_start_pods.ipynb).
1. register iot device & robot to FIWARE  -- [/docs/azure_aks/02_register_device.ipynb](/docs/azure_aks/02_register_device.ipynb).
1. register business logic to FIWARE -- [/docs/azure_aks/03_register_business_logic.ipynb](/docs/azure_aks/03_register_business_logic.ipynb).
1. prepare minikube in turtlebot3, and start `mqtt-kube-operator` in order to enable remote deployment -- [/docs/azure_aks/04_prepare_remote_deploy.ipynb](/docs/azure_aks/04_prepare_remote_deploy.ipynb).
1. deploy programs to turtlebot3 through FIWARE -- [/docs/azure_aks/05_deploy_containers_to_turtlebot3.ipynb](/docs/azure_aks/05_deploy_containers_to_turtlebot3.ipynb).
1. operate turtlebot3 step by step using [/docs/azure_aks/06_operate_turtlebot3.ipynb](/docs/azure_aks/06_operate_turtlebot3.ipynb).
1. visualize the data of turtlebot3 step by step using [/docs/azure_aks/07_visualize_data.ipynb](/docs/azure_aks/07_visualize_data.ipynb).
1. delete programs from turtlebot3 through FIWARE -- [/docs/azure_aks/08_delete_containers_from_turtlebot3.ipynb](/docs/azure_aks/08_delete_containers_from_turtlebot3.ipynb).

### minikube

1. setup environment variables

    ```bash
    $ cp minikube/env.template minikube/env
    $ vi env
    ```
1. start pods on Azure AKS -- [/docs/minikube/01_start_pods.ipynb](/docs/minikube/02_start_pods.ipynb).
1. register iot device & robot to FIWARE  -- [/docs/minikube/02_register_device.ipynb](/docs/minikube/02_register_device.ipynb).
1. register business logic to FIWARE -- [/docs/minikube/03_register_business_logic.ipynb](/docs/minikube/03_register_business_logic.ipynb).
1. prepare minikube in turtlebot3, and start `mqtt-kube-operator` in order to enable remote deployment -- [/docs/minikube/04_prepare_remote_deploy.ipynb](/docs/minikube/04_prepare_remote_deploy.ipynb).
1. deploy programs to turtlebot3 through FIWARE -- [/docs/minikube/05_deploy_containers_to_turtlebot3.ipynb](/docs/minikube/05_deploy_containers_to_turtlebot3.ipynb).
1. operate turtlebot3 step by step using [/docs/minikube/06_operate_turtlebot3.ipynb](/docs/minikube/06_operate_turtlebot3.ipynb).
1. visualize the data of turtlebot3 step by step using [/docs/minikube/07_visualize_data.ipynb](/docs/minikube/07_visualize_data.ipynb).
1. delete programs from turtlebot3 through FIWARE -- [/docs/minikube/08_delete_containers_from_turtlebot3.ipynb](/docs/minikube/08_delete_containers_from_turtlebot3.ipynb).


## Related Repositories (Cloud)
### Business Logic components
* [RoboticBase/fiware-cmd-proxy](https://github.com/RoboticBase/fiware-cmd-proxy)
    * A web application working with [FIWARE orion context broker](https://github.com/telefonicaid/fiware-orion) in order to receive a command from gamepad or web controler and to send a command to ROS robot.
* [RoboticBase/fiware-robot-visualization](https://github.com/RoboticBase/fiware-robot-visualization)
    * A web application working with [FIWARE cygnus](https://github.com/telefonicaid/fiware-cygnus) in order to visualize the locus of ROS robot.

## Related Repositories (Device & Robot)
### gamepad controller
* [RoboticBase/fiware-gamepad-controller](https://github.com/RoboticBase/fiware-gamepad-controller)
    * A python3.6 application in order to receive gamepad events and to send a command corresponding the event to FIWARE.

### android application for Xperia Hello!
* [RoboticBase/fiware_xperiahello](https://github.com/RoboticBase/fiware_xperiahello)
    * An android application for Xperia Hello! It connect to FIWARE using MQTT(S).

### ROS package
* [RoboticBase/fiware_ros_turtlebot3_bridge](https://github.com/RoboticBase/fiware_ros_turtlebot3_bridge)
    * A [ROS](http://wiki.ros.org/) pakage witten by python2 in order to act as a bridge between FIWARE and ROS nodes.
    * When a MQTT message is received from a MQTT topic, this package create ROS message and publish a ROS message to a ROS topic.
    * At the opposite, when a ROS message is received from a ROS topic, this package publish a MQTT message to a MQTT topic.
* [RoboticBase/fiware_ros_turtlebot3_operator](https://github.com/RoboticBase/fiware_ros_turtlebot3_operator)
    * A [ROS](http://wiki.ros.org/) pakage witten by python2 in order to control "turtlebot3" and receive its odometries.
    * You can use this package with either actual robot or simulator.

### Support components
* [RoboticBase/mqtt-kube-operator](https://github.com/RoboticBase/mqtt-kube-operator)
    * A MQTT client to deploy (or delete) a resource to its own Kubernetes.

## License

[Apache License 2.0](/LICENSE)

## Copyright
Copyright (c) 2018 [TIS Inc.](https://www.tis.co.jp/)
