# Turtlebot3 試験環境 インストールマニュアル #8


## 構築環境(2019年3月19日現在)


# turtlebot3コンテナの削除


## 環境設定

1. 環境変数の設定

   ```
   $ export CORE_ROOT=$HOME/core
   $ cd $CORE_ROOT;pwd
   ```

    - 実行結果（例）

        ```
        /home/fiware/core
        ```

   ```
   $ export PJ_ROOT=$HOME/example-turtlebot3
   $ cd $PJ_ROOT;pwd
   ```

    - 実行結果（例）

        ```
        /home/fiware/example-turtlebot3
        ```

1. 環境ファイルの実行

    ```
    $ source $CORE_ROOT/docs/minikube/env
    $ source $PJ_ROOT/docs/minikube/env
    ```

1. minikubeのexternal Interface名を確認

    ```
    $ export LANG=C
    $ ifconfig 
    ```

    - 実行結果（例）

        ```
        docker0   Link encap:Ethernet  HWaddr 02:42:c5:c0:3e:8f  
                inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
                inet6 addr: fe80::42:c5ff:fec0:3e8f/64 Scope:Link
                UP BROADCAST MULTICAST  MTU:1500  Metric:1
                RX packets:0 errors:0 dropped:0 overruns:0 frame:0
                TX packets:719 errors:0 dropped:0 overruns:0 carrier:0
                collisions:0 txqueuelen:0 
                RX bytes:0 (0.0 B)  TX bytes:94805 (94.8 KB)

        enp0s25   Link encap:Ethernet  HWaddr 70:58:12:df:c6:b3  
                inet addr:172.16.10.25  Bcast:172.16.255.255  Mask:255.255.0.0
                inet6 addr: fe80::2f10:a3f2:1147:afdc/64 Scope:Link
                UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                RX packets:17277974 errors:0 dropped:4 overruns:0 frame:0
                TX packets:9452435 errors:0 dropped:0 overruns:0 carrier:0
                collisions:0 txqueuelen:1000 
                RX bytes:7937676158 (7.9 GB)  TX bytes:767611835 (767.6 MB)
                Interrupt:20 Memory:f7c00000-f7c20000 

        lo        Link encap:Local Loopback  
                inet addr:127.0.0.1  Mask:255.0.0.0
                inet6 addr: ::1/128 Scope:Host
                UP LOOPBACK RUNNING  MTU:65536  Metric:1
                RX packets:14175937 errors:0 dropped:0 overruns:0 frame:0
                TX packets:14175937 errors:0 dropped:0 overruns:0 carrier:0
                collisions:0 txqueuelen:1 
                RX bytes:1585161123 (1.5 GB)  TX bytes:1585161123 (1.5 GB)

        vboxnet0  Link encap:Ethernet  HWaddr 0a:00:27:00:00:00  
                inet addr:192.168.99.1  Bcast:192.168.99.255  Mask:255.255.255.0
                inet6 addr: fe80::800:27ff:fe00:0/64 Scope:Link
                UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                RX packets:0 errors:0 dropped:0 overruns:0 frame:0
                TX packets:5233 errors:0 dropped:0 overruns:0 carrier:0
                collisions:0 txqueuelen:1000 
                RX bytes:0 (0.0 B)  TX bytes:1690139 (1.6 MB)

        wlp3s0    Link encap:Ethernet  HWaddr               10:0b:a9:64:99:64  
                UP BROADCAST MULTICAST  MTU:1500  Metric:1
                RX packets:0 errors:0 dropped:0 overruns:0 frame:0
                TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
                collisions:0 txqueuelen:1000 
                RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
        ```

        ※このパソコンの場合はenp0s25

1. minikubeのexternal ipを設定

    ```
    $ export IFNAME=enp0s25
    $ export EXTERNAL_HOST_IPADDR=$(ifconfig $IFNAME | awk '/inet / {print $2}' | cut -d: -f2);echo ${EXTERNAL_HOST_IPADDR}
    ```

    - 実行結果（例）

        ```
        172.16.10.25
        ```

## A.turtlebot3シミュレータの場合

1. turtlebot3-fake-deployment-minikubeの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/turtlebot3-fake/yaml/turtlebot3-fake-deployment-minikube.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. turtlebot3-fake-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/turtlebot3-fake/yaml/turtlebot3-fake-service.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

## A.(alterntive)turtlebot3シミュレータの場合

1. turtlebot3シミュレータ環境の停止

    1. telepresence shellで、exit
    1. port forwadingを閉じる


## B.turtlebot3ロボットの場合

1. 環境設定

    ```
    $ export TURTLEBOT3_WORKSPACE=~/catkin_ws
    ```

1. turtlebot3-bringup-deployment-minikubeの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/turtlebot3-bringup/yaml/turtlebot3-bringup-deployment-minikube.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. turtlebot3-bringup-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/turtlebot3-bringup/yaml/turtlebot3-bringup-service.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```


## fiware-ros-turtlebot3-operatoの削除

1. fiware-ros-turtlebot3-operator-deployment-minikube-wideの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-operator-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-service.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-operator-configmapの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-configmap.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```


## fiware-ros-turtlebot3-bridgeの削除

1. fiware-ros-turtlebot3-bridge-deployment-minikubeの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-bridge/yaml/fiware-ros-turtlebot3-bridge-deployment-minikube.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-bridge-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-bridge/yaml/fiware-ros-turtlebot3-bridge-service.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-bridge-configmapの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-bridge/yaml/fiware-ros-turtlebot3-bridge-configmap.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. iware-ros-turtlebot3-bridge-secretの削除

    ```
    $ export MQTT_YAML_BASE64=""
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-turtlebot3-bridge/yaml/fiware-ros-turtlebot3-bridge-secret.yaml > /tmp/fiware-ros-turtlebot3-bridge-secret.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete /tmp/fiware-ros-turtlebot3-bridge-secret.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-turtlebot3-bridge-secret.yaml
    ```


## ros-masterの削除

1. ros-master-deployment-minikubeの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/ros-master/yaml/ros-master-deployment-minikube.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. ros-master-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/ros-master/yaml/ros-master-service.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```


## minikubeの削除【turtlebot3-pc】

1. minikubeの停止【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo minikube stop
    ```

1. minikubeの削除【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo minikube delete
    ```

1. 環境ファイルの削除【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo rm -rf /etc/kubernetes/
    turtlebot3-pc$ sudo rm -rf $HOME/.minikube/
    turtlebot3-pc$ rm -rf $HOME/.kube/
    ```

