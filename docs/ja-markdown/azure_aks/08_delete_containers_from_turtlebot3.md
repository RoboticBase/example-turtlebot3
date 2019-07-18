# Turtlebot3 試験環境 インストールマニュアル #8


## 構築環境(2019年7月18日現在)


# turtlebot3コンテナの削除


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

1. 環境ファイルの実行

    ```
    $ source $CORE_ROOT/docs/environments/azure_aks/env
    $ source $PJ_ROOT/docs/environments/azure_aks/env
    ```

## A.turtlebot3シミュレータの場合

1. turtlebot3-fake-deployment-acrの削除

    ```
    $ export TURTLEBOT3_USER=turtlebot3
    $ export TURTLEBOT3_UID=1000
    $ envsubst < ${PJ_ROOT}/ros/turtlebot3-fake/yaml/turtlebot3-fake-deployment-acr.yaml > /tmp/turtlebot3-fake-deployment-acr.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete /tmp/turtlebot3-fake-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/turtlebot3-fake-deployment-acr.yaml
    ```

1. turtlebot3-fake-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/turtlebot3-fake/yaml/turtlebot3-fake-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}

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

1. turtlebot3-bringup-deployment-acrの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/turtlebot3-bringup/yaml/turtlebot3-bringup-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. turtlebot3-bringup-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/turtlebot3-bringup/yaml/turtlebot3-bringup-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```


## fiware-ros-turtlebot3-operatorの削除

1. fiware-ros-turtlebot3-operator-deployment-acr-wideの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-acr-wide.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-operator-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-operator-configmapの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-configmap.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```


## fiware-ros-bridgeの削除

1. fiware-ros-bridge-deployment-acrの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-bridge-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-bridge-configmapの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-configmap.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. fiware-ros-turtlebot3-bridge-secretの削除

    ```
    $ export MQTT_YAML_BASE64=""
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-secret.yaml > /tmp/fiware-ros-bridge-secret.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete /tmp/fiware-ros-bridge-secret.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-bridge-secret.yaml
    ```


## ros-masterの削除

1. ros-master-deployment-acrの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/ros-master/yaml/ros-master-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. ros-master-serviceの削除

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py --delete ${PJ_ROOT}/ros/ros-master/yaml/ros-master-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
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
