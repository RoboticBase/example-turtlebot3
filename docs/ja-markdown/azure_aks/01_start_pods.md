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

## example-turtlebot3用のTokenやBasic認証の設定を `auth-tokens.json` に追加

1. `auth-tokens.json` を更新
    * macOS

        ```
        $ cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.|=.+[{
          "host": "web\\..+$",
          "settings": {
            "bearer_tokens": [
              {
                "token": "'$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | head -c 32)'",
                "allowed_paths": ["^/visualizer/positions/$"]
              }
            ],
            "basic_auths": [
              {
                "username": "'$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | head -c 8)'",
                "password": "'$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | head -c 16)'",
                "allowed_paths": ["/controller/web/", "/visualizer/locus/"]
              }
            ],
            "no_auths": {
              "allowed_paths": ["^.*/static/.*$"]
            }
          }
        }]' | tee /tmp/auth-tokens.json
        ```
        ```
        $ mv ${CORE_ROOT}/secrets/auth-tokens.json ${CORE_ROOT}/secrets/auth-tokens.json.back
        ```
        ```
        $ mv /tmp/auth-tokens.json ${CORE_ROOT}/secrets/auth-tokens.json
        ```
    * Ubuntu

        ```
        $ cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.|=.+[{
          "host": "web\\..+$",
          "settings": {
            "bearer_tokens": [
              {
                "token": "'$(cat /dev/urandom 2>/dev/null | head -n 40 | tr -cd 'a-zA-Z0-9' | head -c 32)'",
                "allowed_paths": ["^/visualizer/positions/$"]
              }
            ],
            "basic_auths": [
              {
                "username": "'$(cat /dev/urandom 2>/dev/null | head -n 40 | tr -cd 'a-zA-Z0-9' | head -c 8)'",
                "password": "'$(cat /dev/urandom 2>/dev/null | head -n 40 | tr -cd 'a-zA-Z0-9' | head -c 16)'",
                "allowed_paths": ["/controller/web/", "/visualizer/locus/"]
              }
            ],
            "no_auths": {
              "allowed_paths": ["^.*/static/.*$"]
            }
          }
        }]' | tee /tmp/auth-tokens.json
        ```
        ```
        $ mv ${CORE_ROOT}/secrets/auth-tokens.json ${CORE_ROOT}/secrets/auth-tokens.json.back
        ```
        ```
        $ mv /tmp/auth-tokens.json ${CORE_ROOT}/secrets/auth-tokens.json
        ```

    * 実行結果（例）

        ```json
        [
          {
            "host": "api\\..+$",
            "settings": {
              "bearer_tokens": [
                {
                  "token": "WXhHypvQL0QTBCAVrqUD6eLFen13g8vj",
                  "allowed_paths": [
                    "^/orion/.*$",
                    "^/idas/.*$"
                  ]
                }
              ],
              "basic_auths": [],
              "no_auths": {
                "allowed_paths": []
              }
            }
          },
          {
            "host": "kibana\\..+$",
            "settings": {
              "bearer_tokens": [],
              "basic_auths": [
                {
                  "username": "Hsgf5pdB",
                  "password": "BCsQuZvbG9CW5tSQ",
                  "allowed_paths": [
                    "^.*$"
                  ]
                }
              ],
              "no_auths": {
                "allowed_paths": []
              }
            }
          },
          {
            "host": "grafana\\..+$",
            "settings": {
              "bearer_tokens": [],
              "basic_auths": [],
              "no_auths": {
                "allowed_paths": [
                  "^.*$"
                ]
              }
            }
          },
          {
            "host": "web\\..+$",
            "settings": {
              "bearer_tokens": [
                {
                  "token": "Vi5NtQ0KCyHHXPaltXyifh7CTpgtmBDV",
                  "allowed_paths": [
                    "^/visualizer/positions/$"
                  ]
                }
              ],
              "basic_auths": [
                {
                  "username": "4cBTquF1",
                  "password": "Vltnne0C89oLfcjz",
                  "allowed_paths": [
                    "/controller/web/",
                    "/visualizer/locus/"
                  ]
                }
              ],
              "no_auths": {
                "allowed_paths": [
                  "^.*/static/.*$"
                ]
              }
            }
          }
        ]
        ```

1. `auth` のログを監視
    * 別ターミナルを開いて、次のコマンドを実行

        ```
        $ kubectl logs -f -lapp=auth --all-containers=true
        ```
1. Kubernetesのsecretに登録されている `auth-tokens` を削除
    * secretを削除しても、 `auth` のログには変化が無い

        ```
        $ kubectl delete secret auth-tokens
        ```
1. secretsに更新済みの `auth-tokens` を再登録

    ```
    $ kubectl create secret generic auth-tokens --from-file=${CORE_ROOT}/secrets/auth-tokens.json
    ```
1. `auth-tokens` が更新されたことを確認
    * `auth` Podがsecretの変更を自動で検知し、認証認可情報をリロードする（数分間かかる場合がある）
    * 認証情報がリロードされると、次のようなログが表示される

        ```
        --------
        2019/05/21 01:51:07 hosts: [api\..+$ kibana\..+$ grafana\..+$ web\..+$]
        --------
        2019/05/21 01:51:07 bearerTokenAllowedPaths: map[api\..+$:map[XbZX1LpVv7DG9fu1X3WUq5kiqZyF34zI:[^/orion/.*$ ^/idas/.*$]] web\..+$:map[Udgzdg6xMD5ymtQlInFHsM5UVD9OA2Wi:[^/visualizer/positions/$]]]
        --------
        2019/05/21 01:51:07 basicAuthPaths, map[kibana\..+$:map[^.*$:map[1IGQBVF5:zRa2mxZVdBOyO6Zd]] web\..+$:map[/controller/web/:map[1JMF6D46:6u5M0bUhfjj7wMdM] /visualizer/locus/:map[1JMF6D46:6u5M0bUhfjj7wMdM]]]
        --------
        2019/05/21 01:51:07 noAuthPaths, map[grafana\..+$:[^.*$] web\..+$:[^.*/static/.*$] api\..+$:[] kibana\..+$:[]]
        --------
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
    $ env BEARER_AUTH=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[]|select(.host == "web\\..+$")|.settings.bearer_tokens | map(select(.allowed_paths[] | contains("^/visualizer/positions/$"))) | .[0].token' -r) envsubst < controller/robot-visualization-deployment.yaml | kubectl apply -f -
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

## ビジネスロジックのサブドメインをDNSレコードに追加
1. ambassadorのグローバルIPアドレスを取得

    ```
    $ HTTPS_IPADDR=$(kubectl get services -l app=ambassador -o json | jq '.items[0].status.loadBalancer.ingress[0].ip' -r)
    ```
1. ambassadorのサブドメイン（ web ）をDNSレコードを追加

    ```
    $ az network dns record-set a add-record --resource-group ${DNS_ZONE_RG} --zone-name "${DOMAIN}" --record-set-name "web" --ipv4-address "${HTTPS_IPADDR}"
    ```
    - 実行結果（例）

        ```json
        {
            "arecords": [
                {
                    "ipv4Address": "XX.XX.XX.XX"
                }
            ],
            "etag": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
            "fqdn": "web.example.com.",
            "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/dns-zone/providers/Microsoft.Network/dnszones/example.com/A/api",
            "metadata": null,
            "name": "web",
            "provisioningState": "Succeeded",
            "resourceGroup": "dns-zone",
            "targetResource": {
                "id": null
            },
            "ttl": 3600,
            "type": "Microsoft.Network/dnszones/A"
        }
        ```
1. webドメインの名前解決確認

    ```
    $ nslookup web.${DOMAIN}
    ```

    - 実行結果（例）

        ```
        Server:         127.0.1.1
        Address:        127.0.1.1#53

        Non-authoritative answer:
        Name:   web.example.com
        Address: XX.XX.XX.XX
        ```

1. grafanaドメインの確認

    ```
    $ curl -i https://web.${DOMAIN}/controller/web/
    ```

    - 実行結果（例）

        ```
        HTTP/1.1 401 Unauthorized
        www-authenticate: Basic realm="basic authentication required"
        content-length: 0
        date: Thu, 21 Feb 2019 00:32:29 GMT
        server: envoy
        ```
