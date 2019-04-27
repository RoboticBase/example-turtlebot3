# Turtlebot3 試験環境 インストールマニュアル #1


## 構築環境(2019年4月26日現在)


# roboticbaseのインストール

## RoboticBase/example-turtlebot3の取得
1. ベースファイルの取得

    ```
    $ cd ${HOME}
    $ git clone https://github.com/RoboticBase/example-turtlebot3
    ```

## 環境変数の設定
1. 環境変数の設定

    ```
    $ export CORE_ROOT=$HOME/core
    $ export PJ_ROOT=$HOME/example-turtlebot3
    $ cd $PJ_ROOT;pwd
    ```

    - 実行結果（例）

        ```
        /home/fiware/example-turtlebot3
        ```

1. 環境ファイルのコピー

    ```
    $ cd $PJ_ROOT/docs/environments/azure_aks
    $ cp env.template env
    ```

1. 環境ファイルの設定

    ```
    $ vi env
    ```

    ```bash
    #!/bin/bash
    export MQTT__raspberrypi="password_of_raspberrypi"; echo "MQTT__raspberrypi=${MQTT__raspberrypi}"
    export MQTT__ros="password_of_ros"; echo "MQTT__ros=${MQTT__ros}"

    export FIWARE_SERVICE="fiwaredemo"; echo "FIWARE_SERVICE=${FIWARE_SERVICE}"
    export ROBOT_SERVICEPATH="/robot"; echo "ROBOT_SERVICEPATH=${ROBOT_SERVICEPATH}"
    export ROBOT_ID="turtlebot3"; echo "ROBOT_ID=${ROBOT_ID}"
    export ROBOT_TYPE="robot"; echo "ROBOT_TYPE=${ROBOT_TYPE}"
    export GAMEPAD_SERVICEPATH="/gamepad"; echo "GAMEPAD_SERVICEPATH=${GAMEPAD_SERVICEPATH}"
    export GAMEPAD_ID="gamepad"; echo "GAMEPAD_ID=${GAMEPAD_ID}"
    export GAMEPAD_TYPE="gamepad"; echo "GAMEPAD_TYPE=${GAMEPAD_TYPE}"
    export DEPLOYER_SERVICEPATH="/deployer"; echo "DEPLOYER_SERVICEPATH=${DEPLOYER_SERVICEPATH}"
    export DEPLOYER_ID="deployer_01"; echo "DEPLOYER_ID=${DEPLOYER_ID}"
    export DEPLOYER_TYPE="deployer"; echo "DEPLOYER_TYPE=${DEPLOYER_TYPE}"
    ```

    * `MQTT__raspberrypi` と `MQTT__ros` の値（どちらもMQTTユーザのパスワード）を変更してください

1. プロジェクトルートに移動

    ```
    $ cd $PJ_ROOT
    ```

1. 環境ファイルの実行

    ```
    $ source $CORE_ROOT/docs/environments/azure_aks/env
    $ source $PJ_ROOT/docs/environments/azure_aks/env
    ```

## AKSでcommand proxy serviceを起動

1. cmd-proxy-serviceの作成

    ```
    $ kubectl apply -f controller/cmd-proxy-service.yaml
    ```

    - 実行結果（例）

        ```
        service/cmd-proxy created
        ```

1. cmd-proxy-deploymentの作成

    ```
    $ envsubst < controller/cmd-proxy-deployment.yaml | kubectl apply -f -
    ```

    - 実行結果（例）

        ```
        deployment.apps/cmd-proxy created
        ```

1. cmd-proxyのpods状態確認

    ```
    $ kubectl get pods -l app=cmd-proxy
    ```

    - 実行結果（例）

        ```
        NAME                         READY   STATUS    RESTARTS   AGE
        cmd-proxy-5fb7b6fd57-qfwfd   1/1     Running   0          25s
        cmd-proxy-5fb7b6fd57-w5f5r   1/1     Running   0          25s
        cmd-proxy-5fb7b6fd57-x2bkk   1/1     Running   0          25s
        ```

1. cmd-proxyのservices状態確認

    ```
    $ kubectl get services -l app=cmd-proxy
    ```

    - 実行結果（例）

        ```
        NAME        TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
        cmd-proxy   ClusterIP   10.0.193.29   <none>        8888/TCP   52s
        ```


## AKSでrobot visualizationを起動

1. robot-visualization-serviceの作成

    ```
    $ kubectl apply -f controller/robot-visualization-service.yaml
    ```

    - 実行結果（例）

        ```
        service/robot-visualization created
        ```

1. robot-visualization-deploymentの作成

    ```
    $ export MONGODB_DATABASE="sth_${FIWARE_SERVICE}"
    $ export MONGODB_COLLECTION="sth_${ROBOT_SERVICEPATH}_${ROBOT_ID}_${ROBOT_TYPE}"
    $ env BEARER_AUTH=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens | map(select(.allowed_paths[] | contains ("^/visualizer/positions/$"))) | .[0].token' -r) envsubst < controller/robot-visualization-deployment.yaml | kubectl apply -f -
    ```

    - 実行結果（例）

        ```
        deployment.apps/robot-visualization created
        ```

1. robot-visualizationのpods状態確認

    ```
    $ kubectl get pods -l app=robot-visualization
    ```

    - 実行結果（例）

        ```
        NAME                                   READY   STATUS    RESTARTS   AGE
        robot-visualization-774bbdc8d7-2pbt6   1/1     Running   0          2m
        robot-visualization-774bbdc8d7-d5rw7   1/1     Running   0          2m
        robot-visualization-774bbdc8d7-fdhkm   1/1     Running   0          2m
        ```

1. robot-visualizationのservices状態確認

    ```
    $ kubectl get services -l app=robot-visualization
    ```

    - 実行結果（例）

        ```
        NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
        robot-visualization   ClusterIP   10.111.11.84   <none>        8888/TCP   3m
        ```
