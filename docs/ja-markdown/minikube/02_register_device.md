# Turtlebot3 試験環境 インストールマニュアル #2


## 構築環境(2019年7月18日現在)


# minikubeのfiwareにデバイスを登録


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
    $ source $CORE_ROOT/docs/environments/minikube/env
    $ source $PJ_ROOT/docs/environments/minikube/env
    ```

## コマンドのエイリアスを設定
1. エイリアスの設定

    ```
    $ alias now="python -c 'import datetime; print(datetime.datetime.now().strftime(\"%Y-%m-%dT%H:%M:%S.%f+09:00\"))'"
    ```

## RabbitMQのユーザ設定

1. RabbitMQのユーザ登録

    ```
    $ for e in $(env); do
    if [[ "${e}" =~ ^MQTT__([[:alnum:]_-]+)=([[:alnum:]_-]+)$ ]]; then
        username=${BASH_REMATCH[1]}
        password=${BASH_REMATCH[2]}
        
        kubectl exec rabbitmq-0 -- rabbitmqctl add_user ${username} ${password}
        kubectl exec rabbitmq-0 -- rabbitmqctl set_permissions -p / ${username} ".*" ".*" ".*"
    fi
    done
    ```

    - 実行結果（例）

        ```
        Adding user "iotagent" ...
        User "iotagent" already exists
        command terminated with exit code 70
        Setting permissions for user "iotagent" in vhost "/" ...
        Adding user "ros" ...
        Setting permissions for user "ros" in vhost "/" ...
        Adding user "raspberrypi" ...
        Setting permissions for user "raspberrypi" in vhost "/" ...
        ```

1. RabbitMQのユーザ確認

    ```
    $ kubectl exec rabbitmq-0 -- rabbitmqctl list_users
    ```

    - 実行結果（例）

        ```
        Listing users ...
        user    tags
        ros     []
        raspberrypi     []
        guest   [administrator]
        iotagent        []
        ```


## gamepad serviceの設定


1. gamepad serviceの登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/services/ -X POST -d @- <<__EOS__
    {
      "services": [
        {
          "apikey": "${GAMEPAD_TYPE}",
          "cbroker": "http://orion:1026",
          "resource": "/iot/d",
          "entity_type": "${GAMEPAD_TYPE}"
        }
      ]
    }
    __EOS__
    ```

    - 実行結果（例）

        ```json
        {}
        ```

1. gamepad serviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/services/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "count": 1,
          "services": [
            {
              "commands": [],
              "lazy": [],
              "attributes": [],
              "_id": "5cc19f5303576c000f3d0b1a",
              "resource": "/iot/d",
              "apikey": "gamepad",
              "service": "fiwaredemo",
              "subservice": "/gamepad",
              "__v": 0,
              "static_attributes": [],
              "internal_attributes": [],
              "entity_type": "gamepad"
            }
          ]
        }
        ```


## gamepad deviceの設定

1. gamepad deviceの登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/devices/ -X POST -d @- <<__EOS__
    {
      "devices": [
        {
          "device_id": "${GAMEPAD_ID}",
          "entity_name": "${GAMEPAD_ID}",
          "entity_type": "${GAMEPAD_TYPE}",
          "timezone": "Asia/Tokyo",
          "protocol": "UL20",
          "attributes": [
            {
              "name": "button",
              "type": "string"
            }
          ],
          "transport": "AMQP"
        }
      ]
    }
    __EOS__
    ```

    - 実行結果（例）

        ```json
        {}
        ```

1. idas側でgamepad deviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/devices/${GAMEPAD_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "device_id": "gamepad",
          "service": "fiwaredemo",
          "service_path": "/gamepad",
          "entity_name": "gamepad",
          "entity_type": "gamepad",
          "transport": "AMQP",
          "attributes": [
            {
              "object_id": "button",
              "name": "button",
              "type": "string"
            }
          ],
          "lazy": [],
          "commands": [],
          "static_attributes": [],
          "protocol": "UL20"
        }
        ```

1. orion側でgamepad deviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${GAMEPAD_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "id": "gamepad",
          "type": "gamepad",
          "TimeInstant": {
            "type": "ISO8601",
            "value": " ",
            "metadata": {}
          },
          "button": {
            "type": "string",
            "value": " ",
            "metadata": {}
          }
        }
        ```


## cygnus-mongoをgamepad deviceの購読者として設定

1. cygnus-mongoをgamepad deviceの購読者として登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -i -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/orion/v2/subscriptions/ -X POST -d @- <<__EOS__
    {
      "subject": {
        "entities": [{
          "idPattern": "${GAMEPAD_ID}.*",
          "type": "${GAMEPAD_TYPE}"
        }],
        "condition": {
          "attrs": ["button"]
        }
      },
      "notification": {
        "http": {
          "url": "http://cygnus-mongo:5050/notify"
        },
        "attrs": ["button"],
        "attrsFormat": "legacy"
      }
    }
    __EOS__
    ```

    - 実行結果（例）

        ```
        HTTP/1.1 201 Created
        content-length: 0
        location: /v2/subscriptions/5c7f89b8207d0e5abee03ee8
        fiware-correlator: d3a4ce4c-3fec-11e9-b8be-0242ac110013
        date: Wed, 06 Mar 2019 08:50:03 GMT
        x-envoy-upstream-service-time: 2713
        server: envoy
        ```

1. cygnus-mongoがgamepad deviceの購読者として設定されたことを確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/subscriptions/ | jq .
    ```

    - 実行結果（例）

        ```json
        [
          {
            "id": "5cc1a019e94c6631c96628f2",
            "status": "active",
            "subject": {
              "entities": [
                {
                  "idPattern": "gamepad.*",
                  "type": "gamepad"
                }
              ],
              "condition": {
                "attrs": [
                  "button"
                ]
              }
            },
            "notification": {
              "timesSent": 1,
              "lastNotification": "2019-04-25T11:55:05.00Z",
              "attrs": [
                "button"
              ],
              "attrsFormat": "legacy",
              "http": {
                "url": "http://cygnus-mongo:5050/notify"
              },
              "lastSuccess": "2019-04-25T11:55:05.00Z",
              "lastSuccessCode": 200
            }
          }
        ]
        ```


## robot serviceの設定

1. robot serviceの登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/services/ -X POST -d @- <<__EOS__
    {
      "services": [
        {
          "apikey": "${ROBOT_TYPE}",
          "cbroker": "http://orion:1026",
          "resource": "/iot/d",
          "entity_type": "${ROBOT_TYPE}"
        }
      ]
    }
    __EOS__
    ```

    - 実行結果（例）

        ```json
        {}
        ```

1. robot serviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/services/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "count": 1,
          "services": [
            {
              "commands": [],
              "lazy": [],
              "attributes": [],
              "_id": "5cc1a0e0b3d72f000f4f4c8d",
              "resource": "/iot/d",
              "apikey": "robot",
              "service": "fiwaredemo",
              "subservice": "/robot",
              "__v": 0,
              "static_attributes": [],
              "internal_attributes": [],
              "entity_type": "robot"
            }
          ]
        }
        ```


## robot deviceの設定

1. robot deviceの登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/devices/ -X POST -d @- <<__EOS__
    {
      "devices": [
        {
          "device_id": "${ROBOT_ID}",
          "entity_name": "${ROBOT_ID}",
          "entity_type": "${ROBOT_TYPE}",
          "timezone": "Asia/Tokyo",
          "protocol": "UL20",
          "attributes": [
            {
              "name": "x",
              "type": "float32"
            },
            {
              "name": "y",
              "type": "float32"
            },
            {
              "name": "z",
              "type": "float32"
            },
            {
              "name": "theta",
              "type": "float32"
            },
            {
              "name": "voltage",
              "type": "float32"
            },
            {
              "name": "current",
              "type": "float32"
            },
            {
              "name": "charge",
              "type": "float32"
            },
            {
              "name": "capacity",
              "type": "float32"
            },
            {
              "name": "design_capacity",
              "type": "float32"
            },
            {
              "name": "percentage",
              "type": "float32"
            }
          ],
          "commands": [
            {
              "name": "move",
              "type": "string"
            }
          ],
          "transport": "AMQP"
        }
      ]
    }
    __EOS__
    ```

    - 実行結果（例）

        ```json
        {}
        ```

1. idas側のrobot deviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/devices/${ROBOT_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "device_id": "turtlebot3",
          "service": "fiwaredemo",
          "service_path": "/robot",
          "entity_name": "turtlebot3",
          "entity_type": "robot",
          "transport": "AMQP",
          "attributes": [
            {
              "object_id": "x",
              "name": "x",
              "type": "float32"
            },
            {
              "object_id": "y",
              "name": "y",
              "type": "float32"
            },
            {
              "object_id": "z",
              "name": "z",
              "type": "float32"
            },
            {
              "object_id": "theta",
              "name": "theta",
              "type": "float32"
            },
            {
              "object_id": "voltage",
              "name": "voltage",
              "type": "float32"
            },
            {
              "object_id": "current",
              "name": "current",
              "type": "float32"
            },
            {
              "object_id": "charge",
              "name": "charge",
              "type": "float32"
            },
            {
              "object_id": "capacity",
              "name": "capacity",
              "type": "float32"
            },
            {
              "object_id": "design_capacity",
              "name": "design_capacity",
              "type": "float32"
            },
            {
              "object_id": "percentage",
              "name": "percentage",
              "type": "float32"
            }
          ],
          "lazy": [],
          "commands": [
            {
              "object_id": "move",
              "name": "move",
              "type": "string"
            }
          ],
          "static_attributes": [],
          "protocol": "UL20"
        }
        ```


1. orion側のrobot deviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${ROBOT_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "id": "turtlebot3",
          "type": "robot",
          "TimeInstant": {
            "type": "ISO8601",
            "value": " ",
            "metadata": {}
          },
          "capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "charge": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "current": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "design_capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "move_info": {
            "type": "commandResult",
            "value": " ",
            "metadata": {}
          },
          "move_status": {
            "type": "commandStatus",
            "value": "UNKNOWN",
            "metadata": {}
          },
          "percentage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "theta": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "voltage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "x": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "y": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "z": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "move": {
            "type": "string",
            "value": "",
            "metadata": {}
          }
        }
        ```


## cygnus-mongoをrobot deviceの購読者として設定 (robot position)

1. cygnus-mongoをrobot deviceの購読者として登録 (robot position)

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -i -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/orion/v2/subscriptions/ -X POST -d @- <<__EOS__
    {
      "subject": {
        "entities": [{
          "idPattern": "${ROBOT_ID}.*",
          "type": "${ROBOT_TYPE}"
        }],
        "condition": {
          "attrs": ["x", "y", "z", "theta", "move_status", "move_info"]
        }
      },
      "notification": {
        "http": {
          "url": "http://cygnus-mongo:5050/notify"
        },
        "attrs": ["x", "y", "z", "theta", "move_status", "move_info"],
        "attrsFormat": "legacy"
      }
    }
    __EOS__
    ```

    - 実行結果（例）

        ```
        HTTP/1.1 201 Created
        content-length: 0
        location: /v2/subscriptions/5c7f8d3976d1de49620cdc43
        fiware-correlator: ea0937f2-3fee-11e9-8bed-0242ac110011
        date: Wed, 06 Mar 2019 09:04:57 GMT
        x-envoy-upstream-service-time: 8
        server: envoy
        ```

1.  cygnus-mongoがrobot deviceの購読者として設定されたことを確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/subscriptions/ | jq .
    ```

    - 実行結果（例）

        ```json
        [
          {
            "id": "5cc1a2aae94c6631c96628f4",
            "status": "active",
            "subject": {
              "entities": [
                {
                  "idPattern": "turtlebot3.*",
                  "type": "robot"
                }
              ],
              "condition": {
                "attrs": [
                  "x",
                  "y",
                  "z",
                  "theta",
                  "move_status",
                  "move_info"
                ]
              }
            },
            "notification": {
              "timesSent": 1,
              "lastNotification": "2019-04-25T12:06:02.00Z",
              "attrs": [
                "x",
                "y",
                "z",
                "theta",
                "move_status",
                "move_info"
              ],
              "attrsFormat": "legacy",
              "http": {
                "url": "http://cygnus-mongo:5050/notify"
              },
              "lastSuccess": "2019-04-25T12:06:02.00Z",
              "lastSuccessCode": 200
            }
          }
        ]
        ```

## gamepadのボタンテスト
1. 全てのTopicをsubscribeするコマンドを作成

    ```
    $ echo "mosquitto_sub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /#"
    ```
    - 実行結果（例）

        ```
        mosquitto_sub -h 192.168.99.1 -p 1883 -d -u iotagent -P password_of_iotagent -t /#
        ```

1. 別ターミナルで上記のコマンドを実行
    - 実行結果（例）

        ```
        Client mosqsub/31214-roboticba sending CONNECT
        Client mosqsub/31214-roboticba received CONNACK
        Client mosqsub/31214-roboticba sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0)

        Client mosqsub/31214-roboticba received SUBACK
        Subscribed (mid: 1): 0
        ```

1. gamepadをエミュレーションするコマンドを実行

    ```
    $ mosquitto_pub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /${GAMEPAD_TYPE}/${GAMEPAD_ID}/attrs -m "$(now)|button|circle"
    ```

    - 実行結果（例）

        ```
        Client mosqpub|21891-FIWARE-PC sending CONNECT
        Client mosqpub|21891-FIWARE-PC received CONNACK (0)
        Client mosqpub|21891-FIWARE-PC sending PUBLISH (d0, q0, r0, m1, '/gamepad/gamepad/attrs', ... (49 bytes))
        Client mosqpub|21891-FIWARE-PC sending DISCONNECT
        ```

1. 別ターミナルで下記が表示されていることを確認

    - 実行結果（例）

        ```
        Client mosqpub/31264-roboticba sending PUBLISH (d0, q0, r0, m1, '/gamepad/gamepad/attrs', ... (49 bytes))
        2019-04-25T21:07:07.1556194027+0900|button|circle
        ```

1. gamepad entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${GAMEPAD_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "id": "gamepad",
          "type": "gamepad",
          "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-04-25T21:07:07.1556194027+0900",
            "metadata": {}
          },
          "button": {
            "type": "string",
            "value": "circle",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:07:07.1556194027+0900"
              }
            }
          }
        }
        ```

1. cygnus-mongoの確認

    ```
    $ c=$(echo sth_${GAMEPAD_SERVICEPATH}xffff${GAMEPAD_ID}xffff${GAMEPAD_TYPE} | perl -pe 's/\//x002f/g; s/\$/x0024/g; s/=/xffff/g;')
    $ kubectl exec mongodb-0 -c mongodb-replicaset -- mongo sth_${FIWARE_SERVICE} --eval "db.getCollection(\"${c}\").find().sort({recvTime: -1})"
    ```

    - 実行結果（例）

        ```
        MongoDB shell version v4.1.13
        connecting to: mongodb://127.0.0.1:27017/sth_fiwaredemo?compressors=disabled&gssapiServiceName=mongodb
        Implicit session: session { "id" : UUID("f1e7f9e1-f389-4edb-99de-b2627d551106") }
        MongoDB server version: 4.1.13
        { "_id" : ObjectId("5cc1a391650bcb0011bff77e"), "recvTime" : ISODate("2019-04-25T12:07:07.155Z"), "attrName" : "button", "attrType" : "string", "attrValue" : "circle" }
        ```

1. sth-cometの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/comet/STH/v1/contextEntities/type/${GAMEPAD_TYPE}/id/${GAMEPAD_ID}/attributes/button?lastN=100 | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "contextResponses": [
            {
              "contextElement": {
                "attributes": [
                  {
                    "name": "button",
                    "values": [
                      {
                        "recvTime": "2019-02-14T09:18:35.155Z",
                        "attrType": "string",
                        "attrValue": "circle"
                      }
                    ]
                  }
                ],
                "id": "gamepad",
                "isPattern": false,
                "type": "gamepad"
              },
              "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
              }
            }
          ]
        }
        ```

## robotのx、y、z、thetaテスト
1. 全てのTopicをsubscribeするコマンドを作成

    ```
    $ echo "mosquitto_sub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /#"
    ```
    - 実行結果（例）

        ```
        mosquitto_sub -h 192.168.99.1 -p 1883 -d -u iotagent -P password_of_iotagent -t /#
        ```

1. 別ターミナルで上記のコマンドを実行
    - 実行結果（例）

        ```
        Client mosqsub/31214-roboticba sending CONNECT
        Client mosqsub/31214-roboticba received CONNACK
        Client mosqsub/31214-roboticba sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0)

        Client mosqsub/31214-roboticba received SUBACK
        Subscribed (mid: 1): 0
        ```

1. robotをエミュレーションするコマンドを実行

    ```
    $ mosquitto_pub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /${ROBOT_TYPE}/${ROBOT_ID}/attrs -m "$(now)|x|0.1|y|0.2|z|0.3|theta|0.4"
    ```

    - 実行結果（例）

        ```
        Client mosqpub/1431-roboticbas sending CONNECT
        Client mosqpub/1431-roboticbas received CONNACK
        Client mosqpub/1431-roboticbas sending PUBLISH (d0, q0, r0, m1, '/robot/turtlebot3/attrs', ... (63 bytes))
        Client mosqpub/1431-roboticbas sending DISCONNECT
        ```

1. 別ターミナルで下記が表示されていることを確認

    ```
    Client mosqsub/1414-roboticbas received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/attrs', ... (63 bytes))
    2019-04-25T21:11:28.1556194288+0900|x|0.1|y|0.2|z|0.3|theta|0.4
    ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${ROBOT_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "id": "turtlebot3",
          "type": "robot",
          "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-04-25T21:11:28.1556194288+0900",
            "metadata": {}
          },
          "capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "charge": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "current": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "design_capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "move_info": {
            "type": "commandResult",
            "value": " ",
            "metadata": {}
          },
          "move_status": {
            "type": "commandStatus",
            "value": "UNKNOWN",
            "metadata": {}
          },
          "percentage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "theta": {
            "type": "float32",
            "value": "0.4",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "voltage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "x": {
            "type": "float32",
            "value": "0.1",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "y": {
            "type": "float32",
            "value": "0.2",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "z": {
            "type": "float32",
            "value": "0.3",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "move": {
            "type": "string",
            "value": "",
            "metadata": {}
          }
        }
        ```

1. cygnus-mongoの確認

    ```
    $ c=$(echo sth_${ROBOT_SERVICEPATH}xffff${ROBOT_ID}xffff${ROBOT_TYPE} | perl -pe 's/\//x002f/g; s/\$/x0024/g; s/=/xffff/g;')
    $ kubectl exec mongodb-0 -c mongodb-replicaset -- mongo sth_${FIWARE_SERVICE} --eval "db.getCollection(\"${c}\").find().sort({recvTime: -1})"
    ```

    - 実行結果（例）

        ```
        MongoDB shell version v4.1.13
        connecting to: mongodb://127.0.0.1:27017/sth_fiwaredemo?compressors=disabled&gssapiServiceName=mongodb
        Implicit session: session { "id" : UUID("80d1d87c-2eed-4a86-9ebf-d53cb14c5621") }
        MongoDB server version: 4.1.13
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb9"), "recvTime" : ISODate("2019-04-25T12:11:47.631Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "UNKNOWN" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb5"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "x", "attrType" : "float32", "attrValue" : "0.1" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb6"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "y", "attrType" : "float32", "attrValue" : "0.2" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb7"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "z", "attrType" : "float32", "attrValue" : "0.3" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb8"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "theta", "attrType" : "float32", "attrValue" : "0.4" }
        { "_id" : ObjectId("5cc1a2ad0a25f60012cd9bb4"), "recvTime" : ISODate("2019-04-25T12:06:02.803Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "UNKNOWN" }
        ```

1. sth-cometの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ for a in "x" "y" "z" "theta"; do
      curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/comet/STH/v1/contextEntities/type/${ROBOT_TYPE}/id/${ROBOT_ID}/attributes/${a}?lastN=100 | jq .
    done
    ```

    - 実行結果（例）

        ```json
        {
          "contextResponses": [
            {
              "contextElement": {
                "attributes": [
                  {
                    "name": "x",
                    "values": [
                      {
                        "recvTime": "2019-02-14T09:22:19.155Z",
                        "attrType": "float32",
                        "attrValue": "0.1"
                      }
                    ]
                  }
                ],
                "id": "turtlebot3",
                "isPattern": false,
                "type": "robot"
              },
              "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
              }
            }
          ]
        }
        ```
        ```json
        {
          "contextResponses": [
            {
              "contextElement": {
                "attributes": [
                  {
                    "name": "y",
                    "values": [
                      {
                        "recvTime": "2019-02-14T09:22:19.155Z",
                        "attrType": "float32",
                        "attrValue": "0.2"
                      }
                    ]
                  }
                ],
                "id": "turtlebot3",
                "isPattern": false,
                "type": "robot"
              },
              "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
              }
            }
          ]
        }
        ```
        ```json
        {
          "contextResponses": [
            {
              "contextElement": {
                "attributes": [
                  {
                    "name": "z",
                    "values": [
                      {
                        "recvTime": "2019-02-14T09:22:19.155Z",
                        "attrType": "float32",
                        "attrValue": "0.3"
                      }
                    ]
                  }
                ],
                "id": "turtlebot3",
                "isPattern": false,
                "type": "robot"
              },
              "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
              }
            }
          ]
        }
        ```
        ```json
        {
          "contextResponses": [
            {
              "contextElement": {
                "attributes": [
                  {
                    "name": "theta",
                    "values": [
                      {
                        "recvTime": "2019-02-14T09:22:19.155Z",
                        "attrType": "float32",
                        "attrValue": "0.4"
                      }
                    ]
                  }
                ],
                "id": "turtlebot3",
                "isPattern": false,
                "type": "robot"
              },
              "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
              }
            }
          ]
        }
        ```

## robotのmoveテスト
1. 全てのTopicをsubscribeするコマンドを作成

    ```
    $ echo "mosquitto_sub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /#"
    ```
    - 実行結果（例）

        ```
        mosquitto_sub -h 192.168.99.1 -p 1883 -d -u iotagent -P password_of_iotagent -t /#
        ```

1. 別ターミナルで上記のコマンドを実行
    - 実行結果（例）

        ```
        Client mosqsub/31214-roboticba sending CONNECT
        Client mosqsub/31214-roboticba received CONNACK
        Client mosqsub/31214-roboticba sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0)

        Client mosqsub/31214-roboticba received SUBACK
        Subscribed (mid: 1): 0
        ```

1. robotへ命令するコマンドを実行

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -i -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/orion/v2/entities/${ROBOT_ID}/attrs?type=${ROBOT_TYPE} -X PATCH -d @-<<__EOS__
    {
      "move": {
        "value": "square"
      }
    }
    __EOS__
    ```

    - 実行結果（例）

        ```
        HTTP/1.1 204 No Content
        content-length: 0
        fiware-correlator: 21c29ec2-4099-11e9-b8be-0242ac110013
        date: Thu, 07 Mar 2019 05:23:25 GMT
        x-envoy-upstream-service-time: 666
        server: envoy
        ```

1. 別ターミナルで下記が表示されていることを確認

    ```
    Client mosqsub/1763-roboticbas received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/cmd', ... (22 bytes))
    turtlebot3@move|square
    ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${ROBOT_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "id": "turtlebot3",
          "type": "robot",
          "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-04-25T12:14:46.00Z",
            "metadata": {}
          },
          "capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "charge": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "current": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "design_capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "move_info": {
            "type": "commandResult",
            "value": " ",
            "metadata": {}
          },
          "move_status": {
            "type": "commandStatus",
            "value": "PENDING",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T12:14:46.714Z"
              }
            }
          },
          "percentage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "theta": {
            "type": "float32",
            "value": "0.4",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "voltage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "x": {
            "type": "float32",
            "value": "0.1",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "y": {
            "type": "float32",
            "value": "0.2",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "z": {
            "type": "float32",
            "value": "0.3",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "move": {
            "type": "string",
            "value": "",
            "metadata": {}
          }
        }
        ```

1. コマンド実行結果の送信処理をエミュレート

    ```
    $ mosquitto_pub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /${ROBOT_TYPE}/${ROBOT_ID}/cmdexe -m "${ROBOT_ID}@move|executed square command"
    ```


    - 実行結果（例）

        ```
        Client mosqpub/3091-roboticbas sending CONNECT
        Client mosqpub/3091-roboticbas received CONNACK
        Client mosqpub/3091-roboticbas sending PUBLISH (d0, q0, r0, m1, '/robot/turtlebot3/cmdexe', ... (39 bytes))
        Client mosqpub/3091-roboticbas sending DISCONNECT
        ```

1. 別ターミナルで下記が表示されていることを確認

    ```
    Client mosqsub/3056-roboticbas received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/cmdexe', ... (39 bytes))
    turtlebot3@move|executed square command
    ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${ROBOT_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "id": "turtlebot3",
          "type": "robot",
          "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-04-25T12:16:05.00Z",
            "metadata": {}
          },
          "capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "charge": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "current": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "design_capacity": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "move_info": {
            "type": "commandResult",
            "value": "executed square command",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T12:16:05.676Z"
              }
            }
          },
          "move_status": {
            "type": "commandStatus",
            "value": "OK",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T12:16:05.676Z"
              }
            }
          },
          "percentage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "theta": {
            "type": "float32",
            "value": "0.4",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "voltage": {
            "type": "float32",
            "value": " ",
            "metadata": {}
          },
          "x": {
            "type": "float32",
            "value": "0.1",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "y": {
            "type": "float32",
            "value": "0.2",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "z": {
            "type": "float32",
            "value": "0.3",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T21:11:28.1556194288+0900"
              }
            }
          },
          "move": {
            "type": "string",
            "value": "",
            "metadata": {}
          }
        }
        ```

1. cygnus-mongoの確認

    ```
    $ c=$(echo sth_${ROBOT_SERVICEPATH}xffff${ROBOT_ID}xffff${ROBOT_TYPE} | perl -pe 's/\//x002f/g; s/\$/x0024/g; s/=/xffff/g;')
    $ kubectl exec mongodb-0 -c mongodb-replicaset -- mongo sth_${FIWARE_SERVICE} --eval "db.getCollection(\"${c}\").find().sort({recvTime: -1})"
    ```

    - 実行結果（例）

        ```
        MongoDB shell version v4.1.13
        connecting to: mongodb://127.0.0.1:27017/sth_fiwaredemo?compressors=disabled&gssapiServiceName=mongodb
        Implicit session: session { "id" : UUID("53f1a2e0-a08e-41ce-bb18-ad5c666d77e9") }
        MongoDB server version: 4.1.13
        { "_id" : ObjectId("5cc1a5050a25f60012cd9bc3"), "recvTime" : ISODate("2019-04-25T12:16:05.676Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "OK" }
        { "_id" : ObjectId("5cc1a5050a25f60012cd9bc4"), "recvTime" : ISODate("2019-04-25T12:16:05.676Z"), "attrName" : "move_info", "attrType" : "commandResult", "attrValue" : "executed square command" }
        { "_id" : ObjectId("5cc1a4b70a25f60012cd9bbe"), "recvTime" : ISODate("2019-04-25T12:14:46.714Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "PENDING" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb9"), "recvTime" : ISODate("2019-04-25T12:11:47.631Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "UNKNOWN" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb5"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "x", "attrType" : "float32", "attrValue" : "0.1" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb6"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "y", "attrType" : "float32", "attrValue" : "0.2" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb7"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "z", "attrType" : "float32", "attrValue" : "0.3" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb8"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "theta", "attrType" : "float32", "attrValue" : "0.4" }
        { "_id" : ObjectId("5cc1a4b70a25f60012cd9bba"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "x", "attrType" : "float32", "attrValue" : "0.1" }
        { "_id" : ObjectId("5cc1a4b70a25f60012cd9bbb"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "y", "attrType" : "float32", "attrValue" : "0.2" }
        { "_id" : ObjectId("5cc1a4b70a25f60012cd9bbc"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "z", "attrType" : "float32", "attrValue" : "0.3" }
        { "_id" : ObjectId("5cc1a4b70a25f60012cd9bbd"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "theta", "attrType" : "float32", "attrValue" : "0.4" }
        { "_id" : ObjectId("5cc1a5050a25f60012cd9bbf"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "x", "attrType" : "float32", "attrValue" : "0.1" }
        { "_id" : ObjectId("5cc1a5050a25f60012cd9bc0"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "y", "attrType" : "float32", "attrValue" : "0.2" }
        { "_id" : ObjectId("5cc1a5050a25f60012cd9bc1"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "z", "attrType" : "float32", "attrValue" : "0.3" }
        { "_id" : ObjectId("5cc1a5050a25f60012cd9bc2"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "theta", "attrType" : "float32", "attrValue" : "0.4" }
        { "_id" : ObjectId("5cc1a2ad0a25f60012cd9bb4"), "recvTime" : ISODate("2019-04-25T12:06:02.803Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "UNKNOWN" }
        ```

1. sth-cometの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ for a in "move_status" "move_info"; do
      curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/comet/STH/v1/contextEntities/type/${ROBOT_TYPE}/id/${ROBOT_ID}/attributes/${a}?lastN=100 | jq .
    done
    ```

    - 実行結果（例）

        ```json
        {
          "contextResponses": [
            {
              "contextElement": {
                "attributes": [
                  {
                    "name": "move_status",
                    "values": [
                      {
                        "recvTime": "2019-02-14T09:22:33.167Z",
                        "attrType": "commandStatus",
                        "attrValue": "UNKNOWN"
                      },
                      {
                        "recvTime": "2019-02-15T22:29:47.910Z",
                        "attrType": "commandStatus",
                        "attrValue": "UNKNOWN"
                      },
                      {
                        "recvTime": "2019-02-15T22:30:29.911Z",
                        "attrType": "commandStatus",
                        "attrValue": "PENDING"
                      },
                      {
                        "recvTime": "2019-02-15T22:30:52.006Z",
                        "attrType": "commandStatus",
                        "attrValue": "OK"
                      }
                    ]
                  }
                ],
                "id": "turtlebot3",
                "isPattern": false,
                "type": "robot"
              },
              "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
              }
            }
          ]
        }
        ```
        ```json
        {
          "contextResponses": [
            {
              "contextElement": {
                "attributes": [
                  {
                    "name": "move_info",
                    "values": [
                      {
                        "recvTime": "2019-02-15T22:30:52.006Z",
                        "attrType": "commandResult",
                        "attrValue": "executed square command"
                      }
                    ]
                  }
                ],
                "id": "turtlebot3",
                "isPattern": false,
                "type": "robot"
              },
              "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
              }
            }
          ]
        }
        ```
