# RoboticBase example: Deploy robot programs on TurtleBot3

This repository is example of "RoboticBase-core". The latest version (0.4.1) conforms to [FIWARE Release 7.6](https://github.com/FIWARE/catalogue/releases/tag/FIWARE_7.6).

## Description
"RoboticBase" is a robot management platform based on [FIWARE](http://www.fiware.org/) which enables you to manage and operate many kinds of robots and IoT devices as interactions of contexts.

"RoboticBase" allows robots to collaborate with IoT devices, Open Data, human beings and so on. You can connect a robot to "RoboticBase" using the open APIs of the robot, and operate the robot through those APIs. In turn, "RoboticBase" has an ability to manage ROS. If you connect a ROS robot to "RoboticBase", you can operate the robot directly without restrictions.  
For example, you can deploy a ROS program to the robot and access the raw data of the robot through "RoboticBase".

![roboticbase-core-architecture.png](/docs/images/roboticbase-core-architecture.png)

|component|summary|version|
|:--|:--|:--|
|[kubernetes](https://kubernetes.io/)|Container Orchestration Platform|1.13 or higher|
|[fiware-cmd-proxy](https://github.com/RoboticBase/fiware-cmd-proxy)|Business Logic component to handle the gamepad and robot|0.2.0|
|[robot-visualization](https://github.com/RoboticBase/fiware-robot-visualization)|Business Logic component to visualize the locus of robot|0.2.1|

|gamepad|summary|version|
|:--|:--|:--|
|[gamepad](https://github.com/RoboticBase/fiware-gamepad-controller)|Gamepad Controller connecting FIWARE|0.2.0|

|robot(Android)|summary|version|
|:--|:--|:--|
|[robot(Android)](https://github.com/RoboticBase/fiware_xperiahello)|Android Application for [Xperia Hello!](https://www.sonymobile.co.jp/product/smartproducts/g1209/)|0.1.0|

|turtlebot3|summary|version|
|:--|:--|:--|
|[kubernetes](https://kubernetes.io/)|Container Orchestration Platform|1.14.1|
|[deployer](https://github.com/RoboticBase/mqtt-kube-operator)|MQTT client to deploy (or delete) a resource to its own Kubernetes|0.2.0|
|[bridge](https://github.com/RoboticBase/fiware_ros_bridge)|ROS package to act as a bridge FIWARE orion and ROS|0.2.2|
|[operator](https://github.com/RoboticBase/fiware_ros_turtlebot3_operator)|ROS package to control turtlebot3 (simulator and physical robot)|0.2.1|

## An experiment to prove our concept
We and University of Aizu have been performed an experiment to guide a visitor by collaborating with heterogeneous robots, IoT devices and people through this Robot Platform on Nov. 6th - 8th , 2018.

Please see this repository [ogcaizu/ogc-poc1](https://github.com/ogcaizu/ogc-poc1).

[![video](http://img.youtube.com/vi/D9NPxxYgPa0/0.jpg)](https://youtu.be/D9NPxxYgPa0)

## Requirements

* kubernetes client PC
    * `azure cli` is required when you use Azure AKS.

||version|
|:--|:--|
|OS|macOS Sierra 10.12.6 or Ubuntu 16.04|
|azure cli|2.0.63|
|kubectl|1.14.1|
|helm|2.13.1|

* Azure AKS

||version|
|:--|:--|
|region|japaneast|
|kubernetes|1.13.5|

* minikube
    * when you use monitoring & logging, you have to give **4 cpu & 8192 MB memories** to minikube.

||version|
|:--|:--|
|VirtualBox|5.2.28 r130011|
|minikube|1.0.0|
|kubernetes|1.14.1|

## getting started
### jupyter notebook (english)
1. deploy [RoboticBase-core](https://github.com/RoboticBase/core)

1. install python3

1. install jupyter notebook

    ```bash
    $ cd docs/en-jupyter_notebook/
    $ ./setup_jupyter_notebook.sh
    ```
1. start jupyter notebook

    ```bash
    $ ./start_jupyter_notebook.sh
    ```

1. execute the commands in order according to the following documents:
    * when using Azure AKS
        * 01 start business logics on Azure AKS -- [01_start_pods.ipynb](/docs/en-jupyter_notebook/azure_aks/01_start_pods.ipynb).
        * 02 register iot device & robot to FIWARE  -- [02_register_device.ipynb](/docs/en-jupyter_notebook/azure_aks/02_register_device.ipynb).
        * 03 register business logic to FIWARE -- [03_register_business_logic.ipynb](/docs/en-jupyter_notebook/azure_aks/03_register_business_logic.ipynb).
        * 04 prepare remote deploy in turtlebot3 -- [04_prepare_remote_deploy.ipynb](/docs/en-jupyter_notebook/azure_aks/04_prepare_remote_deploy.ipynb).
        * 05 deploy ROS programs to turtlebot3 through FIWARE -- [05_deploy_containers_to_turtlebot3.ipynb](/docs/en-jupyter_notebook/azure_aks/05_deploy_containers_to_turtlebot3.ipynb).
        * 06 operate turtlebot3 through FIWARE -- [06_operate_turtlebot3.ipynb](/docs/en-jupyter_notebook/azure_aks/06_operate_turtlebot3.ipynb).
        * 07 visualize the locus of turtlebot3 -- [07_visualize_data.ipynb](/docs/en-jupyter_notebook/azure_aks/07_visualize_data.ipynb).
        * 08 delete ROS programs from turtlebot3 through FIWARE -- [08_delete_containers_from_turtlebot3.ipynb](/docs/en-jupyter_notebook/azure_aks/08_delete_containers_from_turtlebot3.ipynb).
    * when using minikube
        * 01 start business logics on minikube -- [01_start_pods.ipynb](/docs/en-jupyter_notebook/minikube/01_start_pods.ipynb).
        * 02 register iot device & robot to FIWARE  -- [02_register_device.ipynb](/docs/en-jupyter_notebook/minikube/02_register_device.ipynb).
        * 03 register business logic to FIWARE -- [03_register_business_logic.ipynb](/docs/en-jupyter_notebook/minikube/03_register_business_logic.ipynb).
        * 04 prepare remote deploy in turtlebot3 -- [04_prepare_remote_deploy.ipynb](/docs/en-jupyter_notebook/minikube/04_prepare_remote_deploy.ipynb).
        * 05 deploy ROS programs to turtlebot3 through FIWARE -- [05_deploy_containers_to_turtlebot3.ipynb](/docs/en-jupyter_notebook/minikube/05_deploy_containers_to_turtlebot3.ipynb).
        * 06 operate turtlebot3 through FIWARE -- [06_operate_turtlebot3.ipynb](/docs/en-jupyter_notebook/minikube/06_operate_turtlebot3.ipynb).
        * 07 visualize the locus of turtlebot3 -- [07_visualize_data.ipynb](/docs/en-jupyter_notebook/minikube/07_visualize_data.ipynb).
        * 08 delete ROS programs from turtlebot3 through FIWARE -- [08_delete_containers_from_turtlebot3.ipynb](/docs/en-jupyter_notebook/minikube/08_delete_containers_from_turtlebot3.ipynb).

### markdown (japanese)
1. ターミナルを開き、Markdownのドキュメントに従ってコマンドを実行してください
    * Azure AKSを用いる場合
        * 01 AKS上にビジネスロジックを起動 -- [01_start_pods.md](/docs/ja-markdown/azure_aks/01_start_pods.md).
        * 02 FIWAREへIoTデバイスとロボットを登録  -- [02_register_device.md](/docs/ja-markdown/azure_aks/02_register_device.md).
        * 03 FIWAREへビジネスロジックを登録 -- [03_register_business_logic.md](/docs/ja-markdown/azure_aks/03_register_business_logic.md).
        * 04 ロボットへのリモートデプロイの準備 -- [04_prepare_remote_deploy.md](/docs/ja-markdown/azure_aks/04_prepare_remote_deploy.md).
        * 05 FIWAREからロボットへROSプログラムをデプロイ -- [05_deploy_containers_to_turtlebot3.md](/docs/ja-markdown/azure_aks/05_deploy_containers_to_turtlebot3.md).
        * 06 FIWAREを通じてロボットを操作 -- [06_operate_turtlebot3.md](/docs/ja-markdown/azure_aks/06_operate_turtlebot3.md).
        * 07 ロボットの軌跡を可視化 -- [07_visualize_data.md](/docs/ja-markdown/azure_aks/07_visualize_data.md).
        * 08 ロボットからROSプログラムを削除 -- [08_delete_containers_from_turtlebot3.md](/docs/ja-markdown/azure_aks/08_delete_containers_from_turtlebot3.md).
    * minikubeを用いる場合
        * 01 minikube上にビジネスロジックを起動 -- [01_start_pods.md](/docs/ja-markdown/minikube/01_start_pods.md).
        * 02 FIWAREへIoTデバイスとロボットを登録  -- [02_register_device.md](/docs/ja-markdown/minikube/02_register_device.md).
        * 03 FIWAREへビジネスロジックを登録 -- [03_register_business_logic.md](/docs/ja-markdown/minikube/03_register_business_logic.md).
        * 04 ロボットへのリモートデプロイの準備 -- [04_prepare_remote_deploy.md](/docs/ja-markdown/minikube/04_prepare_remote_deploy.md).
        * 05 FIWAREからロボットへROSプログラムをデプロイ -- [05_deploy_containers_to_turtlebot3.md](/docs/ja-markdown/minikube/05_deploy_containers_to_turtlebot3.md).
        * 06 FIWAREを通じてロボットを操作 -- [06_operate_turtlebot3.md](/docs/ja-markdown/minikube/06_operate_turtlebot3.md).
        * 07 ロボットの軌跡を可視化 -- [07_visualize_data.md](/docs/ja-markdown/minikube/07_visualize_data.md).
        * 08 ロボットからROSプログラムを削除 -- [08_delete_containers_from_turtlebot3.md](/docs/ja-markdown/minikube/08_delete_containers_from_turtlebot3.md).


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
* [RoboticBase/fiware_ros_bridge](https://github.com/RoboticBase/fiware_ros_bridge)
    * A [ROS](http://wiki.ros.org/) pakage witten by python2 in order to act as a bridge between FIWARE and ROS nodes.
    * When a MQTT message is received from a MQTT topic, this package create ROS message and publish a ROS message to a ROS topic.
    * At the opposite, when a ROS message is received from a ROS topic, this package publish a MQTT message to a MQTT topic.
* [RoboticBase/fiware_ros_turtlebot3_operator](https://github.com/RoboticBase/fiware_ros_turtlebot3_operator)
    * A [ROS](http://wiki.ros.org/) pakage witten by python2 in order to control "turtlebot3" and receive its odometries.
    * You can use this package with either actual robot or simulator.

### Remote Deploy components
* [RoboticBase/mqtt-kube-operator](https://github.com/RoboticBase/mqtt-kube-operator)
    * A MQTT client to deploy (or delete) a resource to its own Kubernetes.

## License

[Apache License 2.0](/LICENSE)

## Copyright
Copyright (c) 2018-2019 [TIS Inc.](https://www.tis.co.jp/)
