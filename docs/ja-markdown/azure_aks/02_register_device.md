# Turtlebot3 試験環境 インストールマニュアル #2


## 構築環境(2019年4月26日現在)


# Azure Kubernetes Service(AKS)のfiwareにデバイスを登録


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
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" -H "Content-Type: application/json" https://api.${DOMAIN}/idas/ul20/manage/iot/services/ -X POST -d @- <<__EOS__
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
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${GAMEPAD_SERVICEPATH}" https://api.${DOMAIN}/idas/ul20/manage/iot/services/ | jq .
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
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" -H "Content-Type: application/json" https://api.${DOMAIN}/idas/ul20/manage/iot/devices/ -X POST -d @- <<__EOS__
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
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${GAMEPAD_SERVICEPATH}" https://api.${DOMAIN}/idas/ul20/manage/iot/devices/${GAMEPAD_ID}/ | jq .
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
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${GAMEPAD_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/entities/${GAMEPAD_ID}/ | jq .
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
    $ curl -i -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" -H "Content-Type: application/json" https://api.${DOMAIN}/orion/v2/subscriptions/ -X POST -d @- <<__EOS__
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
        location: /v2/subscriptions/5c74f32bb570e1414fe2e4e9
        fiware-correlator: 36042ab6-399d-11e9-8200-ceae8a55b16d
        date: Tue, 26 Feb 2019 08:04:59 GMT
        x-envoy-upstream-service-time: 158
        server: envoy
        ```

1. cygnus-mongoがgamepad deviceの購読者として設定されたことを確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/subscriptions/ | jq .
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
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" https://api.${DOMAIN}/idas/ul20/manage/iot/services/ -X POST -d @- <<__EOS__
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
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" https://api.${DOMAIN}/idas/ul20/manage/iot/services/ | jq .
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
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" https://api.${DOMAIN}/idas/ul20/manage/iot/devices/ -X POST -d @- <<__EOS__
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
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" https://api.${DOMAIN}/idas/ul20/manage/iot/devices/${ROBOT_ID}/ | jq .
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
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/entities/${ROBOT_ID}/ | jq .
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

1. cygnus-mongoをrobot deviceの購読者として設定 (robot position)

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -i -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" https://api.${DOMAIN}/orion/v2/subscriptions/ -X POST -d @- <<__EOS__
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
        location: /v2/subscriptions/5c74f609a9302c623b9a3b45
        fiware-correlator: ebba1586-399e-11e9-866d-42e322af3492
        date: Tue, 26 Feb 2019 08:17:13 GMT
        x-envoy-upstream-service-time: 3
        server: envoy
        ```

1. cygnus-mongoがrobot deviceの購読者として設定されたことを確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/subscriptions/ | jq .
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
    $ echo "mosquitto_sub -h mqtt.${DOMAIN} -p 8883 --cafile ${CORE_ROOT}/secrets/DST_Root_CA_X3.pem -d -u iotagent -P ${MQTT__iotagent} -t /#"
    ```
    - 実行結果（例）

        ```
        mosquitto_sub -h mqtt.example.com -p 8883 --cafile /home/fiware/core/secrets/DST_Root_CA_X3.pem -d -u iotagent -P password_of_iotagent -t /#
        ```

1. 別ターミナルで上記のコマンドを実行
    - 実行結果（例）

        ```
        Client mosq/e2bUj8YgCn16fupuXH sending CONNECT
        Client mosq/e2bUj8YgCn16fupuXH received CONNACK (0)
        Client mosq/e2bUj8YgCn16fupuXH sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0, Options: 0x00)
        Client mosq/e2bUj8YgCn16fupuXH received SUBACK
        Subscribed (mid: 1): 0
        ```

1. gamepadをエミュレーションするコマンドを実行

    ```
    $ d=$(date '+%Y-%m-%dT%H:%M:%S.%s+0900')
    $ mosquitto_pub -h mqtt.${DOMAIN} -p 8883 --cafile ${CORE_ROOT}/secrets/DST_Root_CA_X3.pem -d -u iotagent -P ${MQTT__iotagent} -t /${GAMEPAD_TYPE}/${GAMEPAD_ID}/attrs -m "${d}|button|circle"
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
        Client mosqsub|24799-FIWARE-PC received PUBLISH (d0, q0, r0, m0, '/gamepad/gamepad/attrs', .     .. (49 bytes))
        2019-04-25T21:07:07.1556194027+0900|button|circle
        ```

1. gamepad entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/entities/${GAMEPAD_ID}/ | jq .
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
    $ kubectl exec mongodb-0 -c mongodb-replicaset -- mongo sth_${FIWARE_SERVICE} --eval "db.getCollection(\"sth_${GAMEPAD_SERVICEPATH}_${GAMEPAD_ID}_${GAMEPAD_TYPE}\").find().sort({recvTime: -1})"
    ```

    - 実行結果（例）

        ```
        MongoDB shell version v4.1.10
        connecting to: mongodb://127.0.0.1:27017/sth_fiwaredemo?compressors=disabled&gssapiServiceName=mongodb
        Implicit session: session { "id" : UUID("937dccec-3160-4689-bbf4-ff38877d46a1") }
        MongoDB server version: 4.1.10
        { "_id" : ObjectId("5cc1a391650bcb0011bff77e"), "recvTime" : ISODate("2019-04-25T12:07:07.155Z"), "attrName" : "button", "attrType" : "string", "attrValue" : "circle" }
        ```

## robotのx、y、z、thetaテスト

1. 全てのTopicをsubscribeするコマンドを作成

    ```
    $ echo "mosquitto_sub -h mqtt.${DOMAIN} -p 8883 --cafile ${CORE_ROOT}/secrets/DST_Root_CA_X3.pem -d -u iotagent -P ${MQTT__iotagent} -t /#"
    ```
    - 実行結果（例）

        ```
        mosquitto_sub -h mqtt.example.com -p 8883 --cafile /home/fiware/core/secrets/DST_Root_CA_X3.pem -d -u iotagent -P password_of_iotagent -t /#
        ```

1. 別ターミナルで上記のコマンドを実行
    - 実行結果（例）

        ```
        Client mosq/e2bUj8YgCn16fupuXH sending CONNECT
        Client mosq/e2bUj8YgCn16fupuXH received CONNACK (0)
        Client mosq/e2bUj8YgCn16fupuXH sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0, Options: 0x00)
        Client mosq/e2bUj8YgCn16fupuXH received SUBACK
        Subscribed (mid: 1): 0
        ```

1. robotをエミュレーションするコマンドを実行

    ```
    $ d=$(date '+%Y-%m-%dT%H:%M:%S.%s+0900')
    $ mosquitto_pub -h mqtt.${DOMAIN} -p 8883 --cafile ${CORE_ROOT}/secrets/DST_Root_CA_X3.pem -d -u iotagent -P ${MQTT__iotagent} -t /${ROBOT_TYPE}/${ROBOT_ID}/attrs -m "${d}|x|0.1|y|0.2|z|0.3|theta|0.4"
    ```

    - 実行結果（例）

        ```
        Client mosqpub|837-FIWARE-PC sending CONNECT
        Client mosqpub|837-FIWARE-PC received CONNACK (0)
        Client mosqpub|837-FIWARE-PC sending PUBLISH (d0, q0, r0, m1, '/robot/turtlebot3/attrs', ... (63 bytes))
        Client mosqpub|837-FIWARE-PC sending DISCONNECT
        ```

1. 別ターミナルで下記が表示されていることを確認

    ```
    Client mosqsub|12080-FIWARE-PC received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/attrs', ... (95 bytes))
    2019-04-25T21:11:28.1556194288+0900|x|0.1|y|0.2|z|0.3|theta|0.4
    ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/entities/${ROBOT_ID}/ | jq .
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
    $ OP_IN='$in'
    $ kubectl exec mongodb-0 -c mongodb-replicaset -- mongo sth_${FIWARE_SERVICE} --eval "db.getCollection(\"sth_${ROBOT_SERVICEPATH}_${ROBOT_ID}_${ROBOT_TYPE}\").find().sort({recvTime: -1})"
    ```

    - 実行結果（例）

        ```
        MongoDB shell version v4.1.10
        connecting to: mongodb://127.0.0.1:27017/sth_fiwaredemo?compressors=disabled&gssapiServiceName=mongodb
        Implicit session: session { "id" : UUID("618344b8-fabf-4b30-8883-3d5e2f05bcf5") }
        MongoDB server version: 4.1.10
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb9"), "recvTime" : ISODate("2019-04-25T12:11:47.631Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "UNKNOWN" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb5"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "x", "attrType" : "float32", "attrValue" : "0.1" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb6"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "y", "attrType" : "float32", "attrValue" : "0.2" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb7"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "z", "attrType" : "float32", "attrValue" : "0.3" }
        { "_id" : ObjectId("5cc1a4030a25f60012cd9bb8"), "recvTime" : ISODate("2019-04-25T12:11:28.155Z"), "attrName" : "theta", "attrType" : "float32", "attrValue" : "0.4" }
        { "_id" : ObjectId("5cc1a2ad0a25f60012cd9bb4"), "recvTime" : ISODate("2019-04-25T12:06:02.803Z"), "attrName" : "move_status", "attrType" : "commandStatus", "attrValue" : "UNKNOWN" }
        ```


## robotのmoveテスト

1. 全てのTopicをsubscribeするコマンドを作成

    ```
    $ echo "mosquitto_sub -h mqtt.${DOMAIN} -p 8883 --cafile ${CORE_ROOT}/secrets/DST_Root_CA_X3.pem -d -u iotagent -P ${MQTT__iotagent} -t /#"
    ```
    - 実行結果（例）

        ```
        mosquitto_sub -h mqtt.example.com -p 8883 --cafile /home/fiware/core/secrets/DST_Root_CA_X3.pem -d -u iotagent -P password_of_iotagent -t /#
        ```

1. 別ターミナルで上記のコマンドを実行
    - 実行結果（例）

        ```
        Client mosq/e2bUj8YgCn16fupuXH sending CONNECT
        Client mosq/e2bUj8YgCn16fupuXH received CONNACK (0)
        Client mosq/e2bUj8YgCn16fupuXH sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0, Options: 0x00)
        Client mosq/e2bUj8YgCn16fupuXH received SUBACK
        Subscribed (mid: 1): 0
        ```

1. robotへ命令するコマンドを実行

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -i -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${ROBOT_SERVICEPATH}" -H "Content-Type: application/json" https://api.${DOMAIN}/orion/v2/entities/${ROBOT_ID}/attrs?type=${ROBOT_TYPE} -X PATCH -d @-<<__EOS__
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
        fiware-correlator: 400d6d90-39a4-11e9-aead-42e322af3492
        date: Tue, 26 Feb 2019 08:55:21 GMT
        x-envoy-upstream-service-time: 27
        server: envoy
        ```

1. 別ターミナルで下記が表示されていることを確認

    ```
    Client mosqsub|1291-FIWARE-PC received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/cmd', ... (22 bytes))
    turtlebot3@move|square
    ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/entities/${ROBOT_ID}/ | jq .
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
    $ mosquitto_pub -h mqtt.${DOMAIN} -p 8883 --cafile ${CORE_ROOT}/secrets/DST_Root_CA_X3.pem -d -u iotagent -P ${MQTT__iotagent} -t /${ROBOT_TYPE}/${ROBOT_ID}/cmdexe -m "${ROBOT_ID}@move|executed square command"
    ```

    - 実行結果（例）

        ```
        Client mosqpub|1688-FIWARE-PC sending CONNECT
        Client mosqpub|1688-FIWARE-PC received CONNACK (0)
        Client mosqpub|1688-FIWARE-PC sending PUBLISH (d0, q0, r0, m1, '/robot/turtlebot3/cmdexe', ... (39 bytes))
        Client mosqpub|1688-FIWARE-PC sending DISCONNECT
        ```

1. 別ターミナルで下記が表示されていることを確認

    ```
    Client mosqsub|1642-FIWARE-PC received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/cmdexe', ... (39 bytes))
    turtlebot3@move|executed square command
    ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" https://api.${DOMAIN}/orion/v2/entities/${ROBOT_ID}/ | jq .
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
    $ OP_IN='$in'
    $ kubectl exec mongodb-0 -c mongodb-replicaset -- mongo sth_${FIWARE_SERVICE} --eval "db.getCollection(\"sth_${ROBOT_SERVICEPATH}_${ROBOT_ID}_${ROBOT_TYPE}\").find().sort({recvTime: -1})"
    ```

    - 実行結果（例）

        ```
        MongoDB shell version v4.1.10
        connecting to: mongodb://127.0.0.1:27017/sth_fiwaredemo?compressors=disabled&gssapiServiceName=mongodb
        Implicit session: session { "id" : UUID("b9483e50-253b-4194-b07c-d81ec86da0cd") }
        MongoDB server version: 4.1.10
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
