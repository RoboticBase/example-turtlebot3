# Turtlebot3 試験環境 インストールマニュアル #6


## 構築環境(2019年3月19日現在)

# gemepadの準備

gamepadを利用する場合はCの手順、Webコントローラーを利用する場合はDの手順を実施します

## C.gamepadでturtlebot3を操作

## Raspberry Piにgamepadを接続

1. sshでRaspberry Piに接続

1. gamepadコントローラのベースファイルの取得

    ```
    rasberrypi$ git clone https://github.com/RoboticBase/fiware-gamepad-controller.git
    ```

## MQTTブローカーの設定

1. mqttファイルの編集

    ``` 
    raspberrypi$ cp conf/pxkwcr-minikube.yaml.template conf/pxkwcr-minikube.yaml
    raspberrypi$ vi conf/pxkwcr-minikube.yaml
    ```

    ※host,username,passwordの項目を編集してください

    ```
    name: "FUJIWORK PXKWCR Controller"
    controller:
      buttons:
        - key: 0
          value: "triangle"
        - key: 1
          value: "circle"
        - key: 2
      value: "cross"
        - key: 3
          value: "square"
      hats:
        - x: 0
          y: 1
          value: "up"
        - x: 0
          y: -1
          value: "down"
        - x: 1
          y: 0
          value: "right"
        - x: -1
          y: 0
          value: "left"
    mqtt:
      host: "${MQTT_HOST}"
      port: 1883
      username: "raspberrypi"
      password: "${RASPI_RASSWORD}"
      topics:
        - key: "controller"
          value: "/demo1/gamepad/attrs"
    ```

1. bridge node用のPythonライブラリのインストール

    ```
    raspoberypi$ pip install -r requirements/common.txt
    ```

## gamepadの起動

1. gemepadの起動

    ```
    raspberrypi$ ./main.py pxkwcr-minikube
    ```

    - 実行結果（例）

        ```
        2018/07/19 14:20:12 [   INFO] src.controller - connected mqtt broker[192.168.99.1:1883], response_code=0
        ```

## turtlebot3の動作確認

1. gamepadの「〇」をクリック

1. turtlebot3が移動したことを確認


## D.WEBコントローラーでturtlebot3を操作


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


## Webコントローラでturtlebot3を操作

1. web controllerの表示

    ```
    $ xdg-open http://${HOST_IPADDR}:8080/controller/web/
    ```


## gamepadでturtlebot3を操作

1. ユーザ名とパスワードの確認

    ```
    $ cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.basic_auths | map(select(.allowed_paths[] | contains ("/controller/web"))) | .[0].username' -r
    ```

    ```
    $ cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.basic_auths | map(select(.allowed_paths[] | contains ("/controller/web"))) | .[0].password' -r
    ```

1. turtlebot3の動作確認【turtlebot3-pc】

    1. 「ユーザ名」と「パスワード」を入力し、「OK」をクリック

	    ![webcontroller001](images/webcontroller/webcontroller001.png)

    1. web controllerの「〇」をクリック

        ![webcontroller002](images/webcontroller/webcontroller002.png)

    1. turtlebot3が移動したことを確認

        ![webcontroller003](images/webcontroller/webcontroller003.png)


## robotのプログラムを変更

1. fiware-ros-turtlebot3-operator-deployment-minikube-wideを削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

    - 実行結果（例）

        ```
        delete /home/ros/example-turtlebot3/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml to http://172.16.10.25:8080
        status_code=204, body=
        ```

1. turtlebot3-operatorのpodを確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=turtlebot3-operator
    ```

    - 実行結果（例）

        ```
        No resources found.
        ```

1. fiware-ros-turtlebot3-operator-deployment-minikube-narrowを作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-minikube-narrow.yaml > /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-narrow.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-narrow.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-narrow.yaml
    ```

    - 実行結果（例）

        ```
        apply /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-narrow.yaml to http://172.16.10.25:8080
        status_code=204, body=
        ```

1. turtlebot3-operatorのpodを確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=turtlebot3-operator
    ```

    - 実行結果（例）

        ```
        NAME                                  READY   STATUS    RESTARTS   AGE
        turtlebot3-operator-c7ff5cf64-dsnmg   1/1     Running   0          2m
        ```

1. turtlebot3の動作確認【turtlebot3-pc】

    1. web controllerの「〇」をクリック

        ![webcontroller002](images/webcontroller/webcontroller002.png)

    1. turtlebot3が移動したことを確認（先ほどより小さい円で動作）

        ![webcontroller004](images/webcontroller/webcontroller004.png)

1. fiware-ros-turtlebot3-operator-deployment-acr-narrowを削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-minikube-narrow.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}```
    ```

    - 実行結果（例)

        ```
        delete /home/ros/example-turtlebot3/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-minikube-narrow.yaml to http://172.16.10.25:8080
        status_code=204, body=
        ```

1. turtlebot3-operatorのpodを確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=turtlebot3-operator
    ```

    - 実行結果（例)

        ```
        No resources found.
        ```

1. fiware-ros-turtlebot3-operator-deployment-minikube-wideを作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml > /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ ./tools/deploy_yaml.py /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml http://${HOST_IPADDR}:8080 ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml
    ```

    - 実行結果（例）

        ```
        apply /tmp/fiware-ros-turtlebot3-operator-deployment-minikube-wide.yaml to http://172.16.10.25:8080
        status_code=204, body=
        ```

1. turtlebot3-operatorのpodを確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=turtlebot3-operator
    ```

    - 実行結果（例)

        ```
        NAME                                   READY   STATUS    RESTARTS   AGE
        turtlebot3-operator-769d467f69-zxhbq   1/1     Running   0          2m
        ```

1. turtlebot3の動作確認【turtlebot3-pc】

    1. web controllerの「〇」をクリック

        ![webcontroller002](images/webcontroller/webcontroller002.png)

    1. turtlebot3が移動したことを確認

        ![webcontroller005](images/webcontroller/webcontroller005.png)
