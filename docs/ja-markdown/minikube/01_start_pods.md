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
    $ cd $PJ_ROOT/docs/environments/minikube
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
    $ source $CORE_ROOT/docs/environments/minikube/env
    $ source $PJ_ROOT/docs/environments/minikube/env
    ```

## command proxy serviceの設定

1. cmd-proxy-minikube-serviceの作成

    ```
    $ kubectl apply -f controller/cmd-proxy-minikube-service.yaml
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
        cmd-proxy-5fb7b6fd57-6zfs9   1/1     Running   0          109s
        cmd-proxy-5fb7b6fd57-b8hnv   1/1     Running   0          109s
        cmd-proxy-5fb7b6fd57-h69km   1/1     Running   0          109s
        ```

1. cmd-proxyのservices状態確認

    ```
    $ kubectl get services -l app=cmd-proxy
    ```

    - 実行結果（例）

        ```
        NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
        cmd-proxy   ClusterIP   10.104.44.219   <none>        8888/TCP   2m54s
        ```


## robot visualizationの設定

1. robot-visualization-minikube-serviceの作成

    ```
    $ kubectl apply -f controller/robot-visualization-minikube-service.yaml
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
        robot-visualization-84cc796765-5dwc9   1/1     Running   0          63s
        robot-visualization-84cc796765-btjcw   1/1     Running   0          64s
        robot-visualization-84cc796765-j9hlk   1/1     Running   0          63s
        ```

1. robot-visualizationのservices状態確認

    ```
    $ kubectl get services -l app=robot-visualization
    ```

    - 実行結果（例）

        ```
        NAME                  TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
        robot-visualization   ClusterIP   10.97.80.63   <none>        8888/TCP   107s
        ```
