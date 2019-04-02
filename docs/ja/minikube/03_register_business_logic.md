# Turtlebot3 試験環境 インストールマニュアル #3


## 構築環境(2019年3月6日現在)


# minikubeのfiwareにbusiness logicを登録

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


## cmd-proxyの購読者登録

1. cmd-proxyの購読者登録

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
        "url": "http://cmd-proxy:8888/gamepad/"
        },
        "attrs": ["button"]
    }
    }
    __EOS__
    ```

    - 実行結果（例）

        ```
        HTTP/1.1 201 Created
        content-length: 0
        location: /v2/subscriptions/5c80b50b95aa76486e093459
        fiware-correlator: 3cc96826-409f-11e9-b556-0242ac110012
        date: Thu, 07 Mar 2019 06:07:07 GMT
        x-envoy-upstream-service-time: 188
        server: envoy
        ```

1. cmd-proxyの購読者登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/subscriptions/ | jq .
    ```

    - 実行結果（例）

        ```
        [
        {
            "id": "5c7f89b8207d0e5abee03ee8",
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
            "timesSent": 4,
            "lastNotification": "2019-03-07T06:45:41.00Z",
            "attrs": [
                "button"
            ],
            "attrsFormat": "legacy",
            "http": {
                "url": "http://cygnus-mongo:5050/notify"
            },
            "lastFailure": "2019-03-07T04:55:00.00Z",
            "lastSuccess": "2019-03-07T06:45:41.00Z"
            }
        },
        {
            "id": "5c80b50b95aa76486e093459",
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
            "timesSent": 3,
            "lastNotification": "2019-03-07T06:45:41.00Z",
            "attrs": [
                "button"
            ],
            "attrsFormat": "normalized",
            "http": {
                "url": "http://cmd-proxy:8888/gamepad/"
            },
            "lastFailure": "2019-03-07T06:40:22.00Z",
            "lastSuccess": "2019-03-07T06:45:41.00Z"
            }
        }
        ]
        ```


## gamepadのボタンを押下時、robotに送信されたコマンドの確認

1. ゲームパッドをエミュレーションするコマンドの作成

    ```
    $ d=$(date '+%Y-%m-%dT%H:%M:%S.%s+0900')
    $ echo "mosquitto_pub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /${GAMEPAD_TYPE}/${GAMEPAD_ID}/attrs -m \"${d}|button|triangle\""
    ```

    - 実行結果（例）

        ```
        mosquitto_pub -h 192.168.99.1 -p 1883 -d -u iotagent -P password_of_iotagent -t /gamepad/gamepad/attrs -m "2019-03-07T15:45:14.1551941114+0900|button|triangle"
        ```

1. エミュレーションコマンドの受信待機

    ```
    $ mosquitto_sub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /#
    ```

    - 実行結果（例）

        ```
        Client mosqsub/11062-roboticba sending CONNECT
        Client mosqsub/11062-roboticba received CONNACK
        Client mosqsub/11062-roboticba sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0)
        Client mosqsub/11062-roboticba received SUBACK
        Subscribed (mid: 1): 0
        ```

1. 別ターミナルで作成したエミュレーションコマンドの実行

    ```
    $ mosquitto_pub -h 192.168.99.1 -p 1883 -d -u iotagent -P password_of_iotagent -t /gamepad/gamepad/attrs -m "2019-03-07T15:45:14.1551941114+0900|button|triangle"
    ```

    - 実行結果（例）

        ```
        Client mosqpub/11079-roboticba sending CONNECT
        Client mosqpub/11079-roboticba received CONNACK
        Client mosqpub/11079-roboticba sending PUBLISH (d0, q0, r0, m1, '/gamepad/gamepad/attrs', ... (51 bytes))
        Client mosqpub/11079-roboticba sending DISCONNECT
        ```

1. 受信待機側の端末で下記が表示されていることを確認

    ```
    Client mosqsub/11062-roboticba received PUBLISH (d0, q0, r0, m0, '/gamepad/gamepad/attrs', ... (51 bytes))
    2019-03-07T15:45:14.1551941114+0900|button|triangle
    Client mosqsub/11062-roboticba received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/cmd', ... (24 bytes))
    turtlebot3@move|triangle
    ```

1. gamepad entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${GAMEPAD_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${GAMEPAD_ID}/ | jq .
    ```

    - 実行結果（例）

        ```
        {
        "id": "gamepad",
        "type": "gamepad",
        "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-03-07T15:45:14.1551941114+0900",
            "metadata": {}
        },
        "button": {
            "type": "string",
            "value": "triangle",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T15:45:14.1551941114+0900"
            }
            }
        }
        }
        ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${ROBOT_ID}/ | jq .
    ```

    - 実行結果（例）

        ```
        {
        "id": "turtlebot3",
        "type": "robot",
        "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-03-07T06:45:44.00Z",
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
                "value": "2019-03-07T05:35:34.827Z"
            }
            }
        },
        "move_status": {
            "type": "commandStatus",
            "value": "PENDING",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T06:45:44.139Z"
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
                "value": "2019-03-07T14:18:18.1551935898+0900"
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
                "value": "2019-03-07T14:18:18.1551935898+0900"
            }
            }
        },
        "y": {
            "type": "float32",
            "value": "0.2",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T14:18:18.1551935898+0900"
            }
            }
        },
        "z": {
            "type": "float32",
            "value": "0.3",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T14:18:18.1551935898+0900"
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

1. コマンド受信結果をエミュレーションするコマンドの作成

    ```
    $ echo "mosquitto_pub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /${ROBOT_TYPE}/${ROBOT_ID}/cmdexe -m \"${ROBOT_ID}@move|executed triangle command\""
    ```

    - 実行結果（例）

        ```
        mosquitto_pub -h 192.168.99.1 -p 1883 -d -u iotagent -P password_of_iotagent -t /robot/turtlebot3/cmdexe -m "turtlebot3@move|executed triangle command"
        ```

1. エミュレーションコマンドの受信待機

    ```
    $ mosquitto_sub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /#
    ```

    - 実行結果（例）

        ```
        Client mosqsub/11439-roboticba sending CONNECT
        Client mosqsub/11439-roboticba received CONNACK
        Client mosqsub/11439-roboticba sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0)
        Client mosqsub/11439-roboticba received SUBACK
        Subscribed (mid: 1): 0 
        ```

1. 別ターミナルで作成したエミュレーションコマンドの実行

    ```
    $ mosquitto_pub -h 192.168.99.1 -p 1883 -d -u iotagent -P password_of_iotagent -t /robot/turtlebot3/cmdexe -m "turtlebot3@move|executed triangle command"
    ```

    - 実行結果（例）

        ```
        Client mosqpub/11456-roboticba sending CONNECT
        Client mosqpub/11456-roboticba received CONNACK
        Client mosqpub/11456-roboticba sending PUBLISH (d0, q0, r0, m1, '/robot/turtlebot3/cmdexe', ... (41 bytes))
        Client mosqpub/11456-roboticba sending DISCONNECT
        ```

1. 受信待機側の端末で下記が表示されていることを確認

    ```
    Client mosqsub/11439-roboticba received PUBLISH (d0, q0, r0, m0, '/robot/turtlebot3/cmdexe', ... (41 bytes))
    turtlebot3@move|executed triangle command
    ```

1. robot entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${ROBOT_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${ROBOT_ID}/ | jq .
    ```

    - 実行結果（例）

        ```
        {
        "id": "turtlebot3",
        "type": "robot",
        "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-03-07T06:49:15.00Z",
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
            "value": "executed triangle command",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T06:49:15.204Z"
            }
            }
        },
        "move_status": {
            "type": "commandStatus",
            "value": "OK",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T06:49:15.204Z"
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
                "value": "2019-03-07T14:18:18.1551935898+0900"
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
                "value": "2019-03-07T14:18:18.1551935898+0900"
            }
            }
        },
        "y": {
            "type": "float32",
            "value": "0.2",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T14:18:18.1551935898+0900"
            }
            }
        },
        "z": {
            "type": "float32",
            "value": "0.3",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-07T14:18:18.1551935898+0900"
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