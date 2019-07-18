# Turtlebot3 試験環境 インストールマニュアル #5


## 構築環境(2019年7月18日現在)

# Turtlebot3コンテナーの作成

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

## コマンドのエイリアスを設定
1. エイリアスの設定

    ```
$ if [ "$(uname)" == 'Darwin' ]; then
  alias b64='base64 '
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  alias b64='base64 -w 0 '
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi
```

## minikubeにturtlebot3のprivate registryを登録

1. Azure ACRにservice principalを削除

    ※既にservice principalが存在する場合には、service principalを作成する前に削除してください

    ```
    $ EXIST_ACR_ID=$(az ad sp list --display-name ${ACR_NAME}sp --query "[0].appId" -o tsv)
    $ az ad sp delete --id ${EXIST_ACR_ID}
    ```

1. Azure ACRにservice principalを作成 

    ```
    $ ACR_ID=$(az acr show --resource-group ${AKS_RG} --name ${ACR_NAME} --query "id" --output tsv)
    $ az ad sp create-for-rbac --scopes ${ACR_ID} --role Reader --name ${ACR_NAME}sp > /tmp/acrsp
    $ export ACR_USERNAME=$(cat /tmp/acrsp | jq .appId -r);echo "ACR_USERNAME=${ACR_USERNAME}"
    $ export ACR_PASSWORD=$(cat /tmp/acrsp | jq .password -r);echo "ACR_PASSWORD=${ACR_PASSWORD}"
    $ rm /tmp/acrsp
    ```

    - 実行結果（例）

        ```
        Changing "rbcacrsp" to a valid URI of "http://rbcacrsp", which is the required format used for service principal names
        ACR_USERNAME=xxxxxxxxxx
        ACR_PASSWORD=xxxxxxxxxx
        ```

1. Azure ACRをprivate registryとして登録

    ```
    $ echo "kubectl create secret docker-registry ${ACR_NAME} --docker-server ${ACR_NAME}.azurecr.io --docker-email ${EMAIL} --docker-username ${ACR_USERNAME} --docker-password ${ACR_PASSWORD}"
    ```

    - 実行結果（例）

        ```
        kubectl create secret docker-registry rbcacr --docker-server rbcacr.azurecr.io --docker-email xxxxx --docker-username xxxxx --docker-password xxxxx
        ```

1. 表示されたコマンドを実行【turtlebot3-pc】

    ```
    $ kubectl create secret docker-registry rbcacr --docker-server rbcacr.azurecr.io --docker-email xxxxxxxxxx --docker-username xxxxxxxxxx --docker-password xxxxxxxxxx
    ```

    - 実行結果（例）

        ```
        secret/rbcacr created
        ```

## リモートデプロイツールの準備
1. python3.7のdocker imageをベースに、リモートデプロイ用のライブラリをインストールしたdocker imageを作成

    ```
    $ docker run --name remote_deployer -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} python:3.7-alpine pip install -r ${PJ_ROOT}/tools/requirements.txt
    $ docker commit remote_deployer example_turtlebot3:0.0.1
    $ docker rm remote_deployer
    ```

    - 実行結果（例）

        ```
        Collecting requests>=2.19 (from -r /Users/nmatsui/example-turtlebot3/tools/requirements.txt (line 1))
          Downloading https://files.pythonhosted.org/packages/51/bd/23c926cd341ea6b7dd0b2a00aba99ae0f828be89d72b2190f27c11d4b7fb/requests-2.22.0-py2.py3-none-any.whl (57kB)
        Collecting PyYAML>=3.13 (from -r /Users/nmatsui/example-turtlebot3/tools/requirements.txt (line 2))
          Downloading https://files.pythonhosted.org/packages/9f/2c/9417b5c774792634834e730932745bc09a7d36754ca00acf1ccd1ac2594d/PyYAML-5.1.tar.gz (274kB)
        Collecting urllib3!=1.25.0,!=1.25.1,<1.26,>=1.21.1 (from requests>=2.19->-r /Users/nmatsui/example-turtlebot3/tools/requirements.txt (line 1))
          Downloading https://files.pythonhosted.org/packages/e6/60/247f23a7121ae632d62811ba7f273d0e58972d75e58a94d329d51550a47d/urllib3-1.25.3-py2.py3-none-any.whl (150kB)
        Collecting idna<2.9,>=2.5 (from requests>=2.19->-r /Users/nmatsui/example-turtlebot3/tools/requirements.txt (line 1))
          Downloading https://files.pythonhosted.org/packages/14/2c/cd551d81dbe15200be1cf41cd03869a46fe7226e7450af7a6545bfc474c9/idna-2.8-py2.py3-none-any.whl (58kB)
        Collecting chardet<3.1.0,>=3.0.2 (from requests>=2.19->-r /Users/nmatsui/example-turtlebot3/tools/requirements.txt (line 1))
          Downloading https://files.pythonhosted.org/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl (133kB)
        Collecting certifi>=2017.4.17 (from requests>=2.19->-r /Users/nmatsui/example-turtlebot3/tools/requirements.txt (line 1))
          Downloading https://files.pythonhosted.org/packages/60/75/f692a584e85b7eaba0e03827b3d51f45f571c2e793dd731e598828d380aa/certifi-2019.3.9-py2.py3-none-any.whl (158kB)
        Building wheels for collected packages: PyYAML
          Building wheel for PyYAML (setup.py): started
          Building wheel for PyYAML (setup.py): finished with status 'done'
          Stored in directory: /root/.cache/pip/wheels/ad/56/bc/1522f864feb2a358ea6f1a92b4798d69ac783a28e80567a18b
        Successfully built PyYAML
        Installing collected packages: urllib3, idna, chardet, certifi, requests, PyYAML
        Successfully installed PyYAML-5.1 certifi-2019.3.9 chardet-3.0.4 idna-2.8 requests-2.22.0 urllib3-1.25.3
        WARNING: You are using pip version 19.1, however version 19.1.1 is available.
        You should consider upgrading via the 'pip install --upgrade pip' command.
        sha256:05f652cd0e3dda6e9b4765b7cc8ebac7b579330534a1103f6a70e11005deb035
        remote_deployer
        ```


## turtlebot3の準備

### ros-masterの起動

1. ros-masterコンテナイメージの作成

    ```
    $ docker build -t ${REPOSITORY}/roboticbase/ros-master:0.2.0 ros/ros-master
    ```

    - 実行結果（例）

        ```
        Sending build context to Docker daemon  8.704kB
        Step 1/6 : FROM ubuntu:16.04
        16.04: Pulling from library/ubuntu
        7b722c1070cd: Pull complete
        5fbf74db61f1: Pull complete
        ed41cb72e5c9: Pull complete
        7ea47a67709e: Pull complete
        Digest: sha256:e4a134999bea4abb4a27bc437e6118fdddfb172e1b9d683129b74d254af51675
        Status: Downloaded newer image for ubuntu:16.04
        ---> 7e87e2b3bf7a
        Step 2/6 : MAINTAINER Nobuyuki Matsui <nobuyuki.matsui@gmail.com>
        ---> Running in f572f3044d12
        Removing intermediate container f572f3044d12
        ---> d895242d74e0
        Step 3/6 : ENV PYTHONUNBUFFERED 1
        ---> Running in a2c5667ac279
        Removing intermediate container a2c5667ac279
        ---> d2f9fa1e1484
        Step 4/6 : COPY ./kube_entrypoint.sh /opt/kube_entrypoint.sh
        ---> a988b079794e
        Step 5/6 : WORKDIR /opt/ros_ws
        ---> Running in 76fdae042a95
        Removing intermediate container 76fdae042a95
        ---> abc8ed408339
        Step 6/6 : RUN apt update && apt upgrade -y && mkdir -p /opt/ros_ws/src && rm -rf /var/lib/apt/lists/*
        ---> Running in 4344d53f11bc

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial InRelease [247 kB]
        Get:3 http://security.ubuntu.com/ubuntu xenial-security/main amd64 Packages [789 kB]
        Get:4 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [109 kB]
        Get:5 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [107 kB]
        Get:6 http://archive.ubuntu.com/ubuntu xenial/main amd64 Packages [1558 kB]
        Get:7 http://security.ubuntu.com/ubuntu xenial-security/restricted amd64 Packages [12.7 kB]
        Get:8 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [543 kB]
        Get:9 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [6116 B]
        Get:10 http://archive.ubuntu.com/ubuntu xenial/restricted amd64 Packages [14.1 kB]
        Get:11 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [9827 kB]
        Get:12 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [176 kB]
        Get:13 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 Packages [1183 kB]
        Get:14 http://archive.ubuntu.com/ubuntu xenial-updates/restricted amd64 Packages [13.1 kB]
        Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [947 kB]
        Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [19.1 kB]
        Get:17 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [7942 B]
        Get:18 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [8532 B]
        Fetched 15.7 MB in 4min 13s (61.7 kB/s)
        Reading package lists...
        Building dependency tree...
        Reading state information...
        9 packages can be upgraded. Run 'apt list --upgradable' to see them.

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Reading package lists...
        Building dependency tree...
        Reading state information...
        Calculating upgrade...
        The following packages will be upgraded:
            base-files libc-bin libc6 libkmod2 libsystemd0 libudev1 multiarch-support
            systemd systemd-sysv
        9 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
        Need to get 7377 kB of archives.
        After this operation, 4096 B of additional disk space will be used.
        Get:1 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 base-files amd64 9.4ubuntu4.8 [69.4 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libc6 amd64 2.23-0ubuntu11 [2577 kB]
        Get:3 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libc-bin amd64 2.23-0ubuntu11 [631 kB]
        Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkmod2 amd64 22-1ubuntu5.2 [39.9 kB]
        Get:5 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsystemd0 amd64 229-4ubuntu21.16 [204 kB]
        Get:6 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 systemd amd64 229-4ubuntu21.16 [3784 kB]
        Get:7 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 systemd-sysv amd64 229-4ubuntu21.16 [11.6 kB]
        Get:8 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libudev1 amd64 229-4ubuntu21.16 [54.1 kB]
        Get:9 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 multiarch-support amd64 2.23-0ubuntu11 [6822 B]
        debconf: delaying package configuration, since apt-utils is not installed
        Fetched 7377 kB in 31s (232 kB/s)
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../base-files_9.4ubuntu4.8_amd64.deb ...
        Unpacking base-files (9.4ubuntu4.8) over (9.4ubuntu4.7) ...
        Setting up base-files (9.4ubuntu4.8) ...
        Installing new version of config file /etc/issue ...
        Installing new version of config file /etc/issue.net ...
        Installing new version of config file /etc/lsb-release ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libc6_2.23-0ubuntu11_amd64.deb ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        Unpacking libc6:amd64 (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up libc6:amd64 (2.23-0ubuntu11) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        Processing triggers for libc-bin (2.23-0ubuntu10) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libc-bin_2.23-0ubuntu11_amd64.deb ...
        Unpacking libc-bin (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libkmod2_22-1ubuntu5.2_amd64.deb ...
        Unpacking libkmod2:amd64 (22-1ubuntu5.2) over (22-1ubuntu5.1) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libkmod2:amd64 (22-1ubuntu5.2) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libsystemd0_229-4ubuntu21.16_amd64.deb ...
        Unpacking libsystemd0:amd64 (229-4ubuntu21.16) over (229-4ubuntu21.15) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libsystemd0:amd64 (229-4ubuntu21.16) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../systemd_229-4ubuntu21.16_amd64.deb ...
        Unpacking systemd (229-4ubuntu21.16) over (229-4ubuntu21.15) ...
        Setting up systemd (229-4ubuntu21.16) ...
        Initializing machine ID from random generator.
        addgroup: The group `systemd-journal' already exists as a system group. Exiting.
        Operation failed: No such file or directory
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../systemd-sysv_229-4ubuntu21.16_amd64.deb ...
        Unpacking systemd-sysv (229-4ubuntu21.16) over (229-4ubuntu21.15) ...
        Setting up systemd-sysv (229-4ubuntu21.16) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libudev1_229-4ubuntu21.16_amd64.deb ...
        Unpacking libudev1:amd64 (229-4ubuntu21.16) over (229-4ubuntu21.15) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libudev1:amd64 (229-4ubuntu21.16) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../multiarch-support_2.23-0ubuntu11_amd64.deb ...
        Unpacking multiarch-support (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up multiarch-support (2.23-0ubuntu11) ...
        Removing intermediate container 4344d53f11bc
        ---> 7a70909e7100
        Successfully built 7a70909e7100
        Successfully tagged rbcacr.azurecr.io/roboticbase/ros-master:0.2.0
        ```

1. Azure ACRのログイン

    ```
    $ az acr login --name ${ACR_NAME}
    ```

    - 実行結果（例）

        ```
        Login Succeeded
        WARNING! Your password will be stored unencrypted in /home/fiware/.docker/config.json.
        Configure a credential helper to remove this warning. See
        https://docs.docker.com/engine/reference/commandline/login/#credentials-store
        ```

1. Azure ACRにros-masterのイメージを登録

    ```
    $ docker push ${REPOSITORY}/roboticbase/ros-master:0.2.0
    ```

    - 実行結果（例）

        ```
        The push refers to repository [rbcacr.azurecr.io/roboticbase/ros-master]
        6283b1a70e44: Pushed
        f46b81fb2353: Pushed
        b56fea77f8fe: Pushed
        68dda0c9a8cd: Pushed
        f67191ae09b8: Pushed
        b2fd8b4c3da7: Pushed
        0de2edf7bff4: Pushed
        0.2.0: digest: sha256:cf49498a0e1a59b0f862681956d0acb01d553d182428c9bef2e191064f2f6031 size: 1776
        ```

1. ros-masterのservice作成

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py ${PJ_ROOT}/ros/ros-master/yaml/ros-master-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

    - 実行結果（例）

        ```
        apply /home/fiware/example-turtlebot3/ros/ros-master/yaml/ros-master-service.yaml to https://api.example.com
        status_code=204, body=
        ```

1. サービスの起動確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get service -l app=ros-master
    ```

    - 実行結果（例）

        ```
        NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
        ros-master   ClusterIP   None         <none>        11311/TCP   3d
        ```

1. ros-masterのdeployment作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/ros-master/yaml/ros-master-deployment-acr.yaml > /tmp/ros-master-deployment-acr.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py /tmp/ros-master-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/ros-master-deployment-acr.yaml
    ```

    - 実行結果（例）

        ```
        apply /tmp/ros-master-deployment-acr.yaml to https://api.example.com
        status_code=204, body=
        ```

1. ros-masterのdeployments確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get deployments -l app=ros-master
    ```

    - 実行結果（例）

        ```
        NAME         READY   UP-TO-DATE   AVAILABLE   AGE
        ros-master   1/1     1            1           18s
        ```

1. ros-masterのpods確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=ros-master
    ```

    - 実行結果（例）

        ```
        NAME                          READY     STATUS    RESTARTS   AGE
        ros-master-75d4fff9c6-g6dvp   1/1       Running   0          4d
        ```

1. ログの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl logs -f $(kubectl get pods -l app=ros-master -o template --template "{{(index .items 0).metadata.name}}")
    ```

    - 実行結果（例）
        
        ```
        template --template "{{(index .items 0).metadata.name}}")
        Base path: /opt/ros_ws
        Source space: /opt/ros_ws/src
        Build space: /opt/ros_ws/build
        Devel space: /opt/ros_ws/devel
        Install space: /opt/ros_ws/install
        Creating symlink "/opt/ros_ws/src/CMakeLists.txt" pointing to "/opt/ros/kinetic/share/catkin/cmake/toplevel.cmake"
        ####
        #### Running command: "cmake /opt/ros_ws/src -DCATKIN_DEVEL_PREFIX=/opt/ros_ws/devel -DCMAKE_INSTALL_PREFIX=/opt/ros_ws/install -G Unix Makefiles" in "/opt/ros_ws/build"
        ####
        -- The C compiler identification is GNU 5.4.0
        -- The CXX compiler identification is GNU 5.4.0
        -- Check for working C compiler: /usr/bin/gcc
        -- Check for working C compiler: /usr/bin/gcc -- works
        -- Detecting C compiler ABI info
        -- Detecting C compiler ABI info - done
        -- Detecting C compile features
        -- Detecting C compile features - done
        -- Check for working CXX compiler: /usr/bin/g++
        -- Check for working CXX compiler: /usr/bin/g++ -- works
        -- Detecting CXX compiler ABI info
        -- Detecting CXX compiler ABI info - done
        -- Detecting CXX compile features
        -- Detecting CXX compile features - done
        -- Using CATKIN_DEVEL_PREFIX: /opt/ros_ws/devel
        -- Using CMAKE_PREFIX_PATH: /opt/ros/kinetic
        -- This workspace overlays: /opt/ros/kinetic
        -- Found PythonInterp: /usr/bin/python (found version "2.7.12")
        -- Using PYTHON_EXECUTABLE: /usr/bin/python
        -- Using Debian Python package layout
        -- Using empy: /usr/bin/empy
        -- Using CATKIN_ENABLE_TESTING: ON
        -- Call enable_testing()
        -- Using CATKIN_TEST_RESULTS_DIR: /opt/ros_ws/build/test_results
        -- Found gmock sources under '/usr/src/gmock': gmock will be built
        -- Looking for pthread.h
        -- Looking for pthread.h - found
        -- Looking for pthread_create
        -- Looking for pthread_create - not found
        -- Looking for pthread_create in pthreads
        -- Looking for pthread_create in pthreads - not found
        -- Looking for pthread_create in pthread
        -- Looking for pthread_create in pthread - found
        -- Found Threads: TRUE
        -- Found gtest sources under '/usr/src/gmock': gtests will be built
        -- Using Python nosetests: /usr/bin/nosetests-2.7
        -- catkin 0.7.14
        -- BUILD_SHARED_LIBS is on
        -- Configuring done
        -- Generating done
        -- Build files have been written to: /opt/ros_ws/build
        ####
        #### Running command: "make -j4 -l4" in "/opt/ros_ws/build"
        ####
        ... logging to /root/.ros/log/bc8b9f4e-3e5f-11e9-b689-0242ac110004/roslaunch-ros-master-75d4fff9c6-s79dj-295.log
        Checking log directory for disk usage. This may take awhile.
        Press Ctrl-C to interrupt
        Done checking log file disk usage. Usage is <1GB.

        started roslaunch server http://ros-master-75d4fff9c6-s79dj:36179/
        ros_comm version 1.12.14

        SUMMARY
        ========

        PARAMETERS
        * /rosdistro: kinetic
        * /rosversion: 1.12.14

        NODES

        auto-starting new master
        process[master]: started with pid [305]
        ROS_MASTER_URI=http://ros-master-75d4fff9c6-s79dj:11311/

        setting /run_id to bc8b9f4e-3e5f-11e9-b689-0242ac110004
        process[rosout-1]: started with pid [318]
        started core service [/rosout]
        ```


## fiware-ros-brigeの設定
1. tagを指定

    ```
    $ export BRIDGE_GIT_REV="0.3.0"
    ```

1. fiware-ros-brigeコンテナイメージの作成

    ```
    $ docker build -t ${REPOSITORY}/roboticbase/fiware-ros-bridge:${BRIDGE_GIT_REV} ros/fiware-ros-bridge
    ```

    - 実行結果（例）

        ```
        Sending build context to Docker daemon  13.82kB
        Step 1/12 : FROM ubuntu:16.04
         ---> b9e15a5d1e1a
        Step 2/12 : MAINTAINER Nobuyuki Matsui <nobuyuki.matsui@gmail.com>
         ---> Using cache
         ---> f9cf7efe23ef
        Step 3/12 : ENV PYTHONUNBUFFERED 1
         ---> Using cache
         ---> f4b707c2cf0a
        Step 4/12 : ARG MSGS_NAME="fiware_ros_msgs"
         ---> Running in acd1c35c6a0a
        Removing intermediate container acd1c35c6a0a
         ---> c70e98192d76
        Step 5/12 : ARG MSGS_GIT_REPO="https://github.com/RoboticBase/fiware_ros_msgs.git"
         ---> Running in 453b3774f1b1
        Removing intermediate container 453b3774f1b1
         ---> 2cca8cf0b1a3
        Step 6/12 : ARG MSGS_GIT_REV="master"
         ---> Running in 2536a7cc898f
        Removing intermediate container 2536a7cc898f
         ---> 33ce5bd3b955
        Step 7/12 : ARG BRIDGE_NAME="fiware_ros_bridge"
         ---> Running in 34fa81a0c390
        Removing intermediate container 34fa81a0c390
         ---> f2846511866f
        Step 8/12 : ARG BRIDGE_GIT_REPO="https://github.com/RoboticBase/fiware_ros_bridge.git"
         ---> Running in 754d917e9c86
        Removing intermediate container 754d917e9c86
         ---> 3f7c51b48192
        Step 9/12 : ARG BRIDGE_GIT_REV="0.3.0"
         ---> Running in 2c5fb146f640
        Removing intermediate container 2c5fb146f640
         ---> 70676edeee6e
        Step 10/12 : COPY ./kube_entrypoint.sh /opt/kube_entrypoint.sh
         ---> d714b6f52709
        Step 11/12 : WORKDIR /opt/ros_ws
         ---> Running in 76832dd0e15b
        Removing intermediate container 76832dd0e15b
         ---> 3066a7ec0c5a
        Step 12/12 : RUN apt update && apt upgrade -y && apt install -y git ca-certificates python-setuptools python-pip --no-install-recommends &&     mkdir -p /opt/ros_ws/src &&     git clone ${MSGS_GIT_REPO} src/${MSGS_NAME} && cd src/${MSGS_NAME} && git checkout ${MSGS_GIT_REV} && cd ../.. &&     git clone ${BRIDGE_GIT_REPO} src/${BRIDGE_NAME} && cd src/${BRIDGE_NAME} && git checkout ${BRIDGE_GIT_REV} && cd ../.. &&     pip install wheel --user &&     pip install -r /opt/ros_ws/src/${BRIDGE_NAME}/requirements/common.txt --user &&     rm -rf /var/lib/apt/lists/* &&     apt-get purge -y --auto-remove git
         ---> Running in bfc22ab1017c

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial InRelease [247 kB]
        Get:3 http://security.ubuntu.com/ubuntu xenial-security/universe Sources [130 kB]
        Get:4 http://security.ubuntu.com/ubuntu xenial-security/main amd64 Packages [833 kB]
        Get:5 http://security.ubuntu.com/ubuntu xenial-security/restricted amd64 Packages [12.7 kB]
        Get:6 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [554 kB]
        Get:7 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [109 kB]
        Get:8 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [6113 B]
        Get:9 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [107 kB]
        Get:10 http://archive.ubuntu.com/ubuntu xenial/universe Sources [9802 kB]
        Get:11 http://archive.ubuntu.com/ubuntu xenial/main amd64 Packages [1558 kB]
        Get:12 http://archive.ubuntu.com/ubuntu xenial/restricted amd64 Packages [14.1 kB]
        Get:13 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [9827 kB]
        Get:14 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [176 kB]
        Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/universe Sources [321 kB]
        Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 Packages [1237 kB]
        Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/restricted amd64 Packages [13.1 kB]
        Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [966 kB]
        Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [19.1 kB]
        Get:20 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [7942 B]
        Get:21 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [8532 B]
        Fetched 26.1 MB in 9s (2787 kB/s)
        Reading package lists...
        Building dependency tree...
        Reading state information...
        29 packages can be upgraded. Run 'apt list --upgradable' to see them.

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Reading package lists...
        Building dependency tree...
        Reading state information...
        Calculating upgrade...
        The following packages will be upgraded:
          apt base-files bash bsdutils debconf dpkg gcc-5-base libapparmor1
          libapt-pkg5.0 libblkid1 libc-bin libc6 libfdisk1 libkmod2 libmount1
          libseccomp2 libsmartcols1 libstdc++6 libsystemd0 libudev1 libuuid1 login
          mount multiarch-support passwd perl-base systemd systemd-sysv util-linux
        29 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
        Need to get 16.1 MB of archives.
        After this operation, 255 kB of additional disk space will be used.
        Get:1 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 base-files amd64 9.4ubuntu4.8 [69.4 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 bash amd64 4.3-14ubuntu1.3 [583 kB]
        Get:3 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 bsdutils amd64 1:2.27.1-6ubuntu3.7 [51.1 kB]
        Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 dpkg amd64 1.18.4ubuntu1.5 [2085 kB]
        Get:5 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 login amd64 1:4.2-3.1ubuntu5.4 [304 kB]
        Get:6 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 util-linux amd64 2.27.1-6ubuntu3.7 [849 kB]
        Get:7 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 mount amd64 2.27.1-6ubuntu3.7 [121 kB]
        Get:8 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 perl-base amd64 5.22.1-9ubuntu0.6 [1283 kB]
        Get:9 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libc6 amd64 2.23-0ubuntu11 [2577 kB]
        Get:10 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libc-bin amd64 2.23-0ubuntu11 [631 kB]
        Get:11 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 gcc-5-base amd64 5.4.0-6ubuntu1~16.04.11 [17.3 kB]
        Get:12 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libstdc++6 amd64 5.4.0-6ubuntu1~16.04.11 [393 kB]
        Get:13 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libapt-pkg5.0 amd64 1.2.31 [712 kB]
        Get:14 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 apt amd64 1.2.31 [1087 kB]
        Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 debconf all 1.5.58ubuntu2 [136 kB]
        Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libapparmor1 amd64 2.10.95-0ubuntu2.10 [29.7 kB]
        Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 passwd amd64 1:4.2-3.1ubuntu5.4 [780 kB]
        Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libuuid1 amd64 2.27.1-6ubuntu3.7 [14.9 kB]
        Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libblkid1 amd64 2.27.1-6ubuntu3.7 [107 kB]
        Get:20 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkmod2 amd64 22-1ubuntu5.2 [39.9 kB]
        Get:21 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libmount1 amd64 2.27.1-6ubuntu3.7 [115 kB]
        Get:22 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libseccomp2 amd64 2.4.1-0ubuntu0.16.04.2 [38.5 kB]
        Get:23 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsystemd0 amd64 229-4ubuntu21.21 [204 kB]
        Get:24 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 systemd amd64 229-4ubuntu21.21 [3629 kB]
        Get:25 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 systemd-sysv amd64 229-4ubuntu21.21 [11.1 kB]
        Get:26 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libfdisk1 amd64 2.27.1-6ubuntu3.7 [138 kB]
        Get:27 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsmartcols1 amd64 2.27.1-6ubuntu3.7 [62.5 kB]
        Get:28 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libudev1 amd64 229-4ubuntu21.21 [53.6 kB]
        Get:29 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 multiarch-support amd64 2.23-0ubuntu11 [6822 B]
        debconf: delaying package configuration, since apt-utils is not installed
        Fetched 16.1 MB in 6s (2373 kB/s)
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../base-files_9.4ubuntu4.8_amd64.deb ...
        Unpacking base-files (9.4ubuntu4.8) over (9.4ubuntu4.7) ...
        Setting up base-files (9.4ubuntu4.8) ...
        Installing new version of config file /etc/issue ...
        Installing new version of config file /etc/issue.net ...
        Installing new version of config file /etc/lsb-release ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../bash_4.3-14ubuntu1.3_amd64.deb ...
        Unpacking bash (4.3-14ubuntu1.3) over (4.3-14ubuntu1.2) ...
        Setting up bash (4.3-14ubuntu1.3) ...
        update-alternatives: using /usr/share/man/man7/bash-builtins.7.gz to provide /usr/share/man/man7/builtins.7.gz (builtins.7.gz) in auto mode
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../bsdutils_1%3a2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking bsdutils (1:2.27.1-6ubuntu3.7) over (1:2.27.1-6ubuntu3.6) ...
        Setting up bsdutils (1:2.27.1-6ubuntu3.7) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../dpkg_1.18.4ubuntu1.5_amd64.deb ...
        Unpacking dpkg (1.18.4ubuntu1.5) over (1.18.4ubuntu1.4) ...
        Setting up dpkg (1.18.4ubuntu1.5) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../login_1%3a4.2-3.1ubuntu5.4_amd64.deb ...
        Unpacking login (1:4.2-3.1ubuntu5.4) over (1:4.2-3.1ubuntu5.3) ...
        Setting up login (1:4.2-3.1ubuntu5.4) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../util-linux_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking util-linux (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Setting up util-linux (2.27.1-6ubuntu3.7) ...
        Processing triggers for systemd (229-4ubuntu21.4) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../mount_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking mount (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Setting up mount (2.27.1-6ubuntu3.7) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../perl-base_5.22.1-9ubuntu0.6_amd64.deb ...
        Unpacking perl-base (5.22.1-9ubuntu0.6) over (5.22.1-9ubuntu0.5) ...
        Setting up perl-base (5.22.1-9ubuntu0.6) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libc6_2.23-0ubuntu11_amd64.deb ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        Unpacking libc6:amd64 (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up libc6:amd64 (2.23-0ubuntu11) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        Processing triggers for libc-bin (2.23-0ubuntu10) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libc-bin_2.23-0ubuntu11_amd64.deb ...
        Unpacking libc-bin (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../gcc-5-base_5.4.0-6ubuntu1~16.04.11_amd64.deb ...
        Unpacking gcc-5-base:amd64 (5.4.0-6ubuntu1~16.04.11) over (5.4.0-6ubuntu1~16.04.10) ...
        Setting up gcc-5-base:amd64 (5.4.0-6ubuntu1~16.04.11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libstdc++6_5.4.0-6ubuntu1~16.04.11_amd64.deb ...
        Unpacking libstdc++6:amd64 (5.4.0-6ubuntu1~16.04.11) over (5.4.0-6ubuntu1~16.04.10) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libstdc++6:amd64 (5.4.0-6ubuntu1~16.04.11) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libapt-pkg5.0_1.2.31_amd64.deb ...
        Unpacking libapt-pkg5.0:amd64 (1.2.31) over (1.2.27) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libapt-pkg5.0:amd64 (1.2.31) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../archives/apt_1.2.31_amd64.deb ...
        Unpacking apt (1.2.31) over (1.2.27) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up apt (1.2.31) ...
        Installing new version of config file /etc/apt/apt.conf.d/01autoremove ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../debconf_1.5.58ubuntu2_all.deb ...
        Unpacking debconf (1.5.58ubuntu2) over (1.5.58ubuntu1) ...
        Setting up debconf (1.5.58ubuntu2) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libapparmor1_2.10.95-0ubuntu2.10_amd64.deb ...
        Unpacking libapparmor1:amd64 (2.10.95-0ubuntu2.10) over (2.10.95-0ubuntu2.9) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libapparmor1:amd64 (2.10.95-0ubuntu2.10) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../passwd_1%3a4.2-3.1ubuntu5.4_amd64.deb ...
        Unpacking passwd (1:4.2-3.1ubuntu5.4) over (1:4.2-3.1ubuntu5.3) ...
        Setting up passwd (1:4.2-3.1ubuntu5.4) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libuuid1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libuuid1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libuuid1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libblkid1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libblkid1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libblkid1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libkmod2_22-1ubuntu5.2_amd64.deb ...
        Unpacking libkmod2:amd64 (22-1ubuntu5.2) over (22-1ubuntu5) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libkmod2:amd64 (22-1ubuntu5.2) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libmount1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libmount1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libmount1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libseccomp2_2.4.1-0ubuntu0.16.04.2_amd64.deb ...
        Unpacking libseccomp2:amd64 (2.4.1-0ubuntu0.16.04.2) over (2.3.1-2.1ubuntu2~16.04.1) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libseccomp2:amd64 (2.4.1-0ubuntu0.16.04.2) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libsystemd0_229-4ubuntu21.21_amd64.deb ...
        Unpacking libsystemd0:amd64 (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libsystemd0:amd64 (229-4ubuntu21.21) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../systemd_229-4ubuntu21.21_amd64.deb ...
        Unpacking systemd (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Setting up systemd (229-4ubuntu21.21) ...
        Initializing machine ID from random generator.
        addgroup: The group `systemd-journal' already exists as a system group. Exiting.
        Operation failed: No such file or directory
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../systemd-sysv_229-4ubuntu21.21_amd64.deb ...
        Unpacking systemd-sysv (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Setting up systemd-sysv (229-4ubuntu21.21) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libfdisk1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libfdisk1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libfdisk1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libsmartcols1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libsmartcols1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libsmartcols1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libudev1_229-4ubuntu21.21_amd64.deb ...
        Unpacking libudev1:amd64 (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libudev1:amd64 (229-4ubuntu21.21) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../multiarch-support_2.23-0ubuntu11_amd64.deb ...
        Unpacking multiarch-support (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up multiarch-support (2.23-0ubuntu11) ...

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Reading package lists...
        Building dependency tree...
        Reading state information...
        The following additional packages will be installed:
          git-man libasn1-8-heimdal libcurl3-gnutls liberror-perl libexpat1 libffi6
          libgdbm3 libgmp10 libgnutls30 libgssapi-krb5-2 libgssapi3-heimdal
          libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhogweed4
          libhx509-5-heimdal libidn11 libk5crypto3 libkeyutils1 libkrb5-26-heimdal
          libkrb5-3 libkrb5support0 libldap-2.4-2 libnettle6 libp11-kit0 libperl5.22
          libpython-stdlib libpython2.7-minimal libpython2.7-stdlib libroken18-heimdal
          librtmp1 libsasl2-2 libsasl2-modules-db libsqlite3-0 libssl1.0.0 libtasn1-6
          libwind0-heimdal mime-support openssl perl perl-modules-5.22 python
          python-minimal python-pip-whl python-pkg-resources python2.7
          python2.7-minimal
        Suggested packages:
          gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-el git-email
          git-gui gitk gitweb git-arch git-cvs git-mediawiki git-svn gnutls-bin
          krb5-doc krb5-user perl-doc libterm-readline-gnu-perl
          | libterm-readline-perl-perl make python-doc python-tk python-setuptools-doc
          python2.7-doc binutils binfmt-support
        Recommended packages:
          patch less rsync ssh-client krb5-locales libsasl2-modules file netbase
          rename build-essential python-all-dev python-wheel
        The following NEW packages will be installed:
          ca-certificates git git-man libasn1-8-heimdal libcurl3-gnutls liberror-perl
          libexpat1 libffi6 libgdbm3 libgmp10 libgnutls30 libgssapi-krb5-2
          libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
          libheimntlm0-heimdal libhogweed4 libhx509-5-heimdal libidn11 libk5crypto3
          libkeyutils1 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2
          libnettle6 libp11-kit0 libperl5.22 libpython-stdlib libpython2.7-minimal
          libpython2.7-stdlib libroken18-heimdal librtmp1 libsasl2-2
          libsasl2-modules-db libsqlite3-0 libssl1.0.0 libtasn1-6 libwind0-heimdal
          mime-support openssl perl perl-modules-5.22 python python-minimal python-pip
          python-pip-whl python-pkg-resources python-setuptools python2.7
          python2.7-minimal
        0 upgraded, 51 newly installed, 0 to remove and 0 not upgraded.
        Need to get 20.9 MB of archives.
        After this operation, 100 MB of additional disk space will be used.
        Get:1 http://archive.ubuntu.com/ubuntu xenial/main amd64 libgdbm3 amd64 1.8.3-13.1 [16.9 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 perl-modules-5.22 all 5.22.1-9ubuntu0.6 [2629 kB]
        Get:3 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libperl5.22 amd64 5.22.1-9ubuntu0.6 [3405 kB]
        Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 perl amd64 5.22.1-9ubuntu0.6 [237 kB]
        Get:5 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libpython2.7-minimal amd64 2.7.12-1ubuntu0~16.04.4 [339 kB]
        Get:6 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 python2.7-minimal amd64 2.7.12-1ubuntu0~16.04.4 [1261 kB]
        Get:7 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 python-minimal amd64 2.7.12-1~16.04 [28.1 kB]
        Get:8 http://archive.ubuntu.com/ubuntu xenial/main amd64 mime-support all 3.59ubuntu1 [31.0 kB]
        Get:9 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libexpat1 amd64 2.1.0-7ubuntu0.16.04.3 [71.2 kB]
        Get:10 http://archive.ubuntu.com/ubuntu xenial/main amd64 libffi6 amd64 3.2.1-4 [17.8 kB]
        Get:11 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsqlite3-0 amd64 3.11.0-1ubuntu1.1 [396 kB]
        Get:12 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libssl1.0.0 amd64 1.0.2g-1ubuntu4.15 [1084 kB]
        Get:13 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libpython2.7-stdlib amd64 2.7.12-1ubuntu0~16.04.4 [1880 kB]
        Get:14 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 python2.7 amd64 2.7.12-1ubuntu0~16.04.4 [224 kB]
        Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libpython-stdlib amd64 2.7.12-1~16.04 [7768 B]
        Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 python amd64 2.7.12-1~16.04 [137 kB]
        Get:17 http://archive.ubuntu.com/ubuntu xenial/main amd64 libgmp10 amd64 2:6.1.0+dfsg-2 [240 kB]
        Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libnettle6 amd64 3.2-1ubuntu0.16.04.1 [93.5 kB]
        Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libhogweed4 amd64 3.2-1ubuntu0.16.04.1 [136 kB]
        Get:20 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libidn11 amd64 1.32-3ubuntu1.2 [46.5 kB]
        Get:21 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libp11-kit0 amd64 0.23.2-5~ubuntu16.04.1 [105 kB]
        Get:22 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libtasn1-6 amd64 4.7-3ubuntu0.16.04.3 [43.5 kB]
        Get:23 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libgnutls30 amd64 3.4.10-4ubuntu1.5 [548 kB]
        Get:24 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 openssl amd64 1.0.2g-1ubuntu4.15 [492 kB]
        Get:25 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 ca-certificates all 20170717~16.04.2 [167 kB]
        Get:26 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libroken18-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [41.4 kB]
        Get:27 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libasn1-8-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [174 kB]
        Get:28 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkrb5support0 amd64 1.13.2+dfsg-5ubuntu2.1 [31.2 kB]
        Get:29 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libk5crypto3 amd64 1.13.2+dfsg-5ubuntu2.1 [81.3 kB]
        Get:30 http://archive.ubuntu.com/ubuntu xenial/main amd64 libkeyutils1 amd64 1.5.9-8ubuntu1 [9904 B]
        Get:31 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkrb5-3 amd64 1.13.2+dfsg-5ubuntu2.1 [273 kB]
        Get:32 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libgssapi-krb5-2 amd64 1.13.2+dfsg-5ubuntu2.1 [120 kB]
        Get:33 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libhcrypto4-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [85.0 kB]
        Get:34 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libheimbase1-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [29.3 kB]
        Get:35 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libwind0-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [47.8 kB]
        Get:36 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libhx509-5-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [107 kB]
        Get:37 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkrb5-26-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [202 kB]
        Get:38 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libheimntlm0-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [15.1 kB]
        Get:39 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libgssapi3-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [96.1 kB]
        Get:40 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsasl2-modules-db amd64 2.1.26.dfsg1-14ubuntu0.1 [14.5 kB]
        Get:41 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsasl2-2 amd64 2.1.26.dfsg1-14ubuntu0.1 [48.6 kB]
        Get:42 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libldap-2.4-2 amd64 2.4.42+dfsg-2ubuntu3.5 [161 kB]
        Get:43 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 librtmp1 amd64 2.4+20151223.gitfa8646d-1ubuntu0.1 [54.4 kB]
        Get:44 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libcurl3-gnutls amd64 7.47.0-1ubuntu2.13 [184 kB]
        Get:45 http://archive.ubuntu.com/ubuntu xenial/main amd64 liberror-perl all 0.17-1.2 [19.6 kB]
        Get:46 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 git-man all 1:2.7.4-0ubuntu1.6 [736 kB]
        Get:47 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 git amd64 1:2.7.4-0ubuntu1.6 [3176 kB]
        Get:48 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 python-pip-whl all 8.1.1-2ubuntu0.4 [1110 kB]
        Get:49 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 python-pip all 8.1.1-2ubuntu0.4 [144 kB]
        Get:50 http://archive.ubuntu.com/ubuntu xenial/main amd64 python-pkg-resources all 20.7.0-1 [108 kB]
        Get:51 http://archive.ubuntu.com/ubuntu xenial/main amd64 python-setuptools all 20.7.0-1 [169 kB]
        debconf: delaying package configuration, since apt-utils is not installed
        Fetched 20.9 MB in 8s (2596 kB/s)
        Selecting previously unselected package libgdbm3:amd64.
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libgdbm3_1.8.3-13.1_amd64.deb ...
        Unpacking libgdbm3:amd64 (1.8.3-13.1) ...
        Selecting previously unselected package perl-modules-5.22.
        Preparing to unpack .../perl-modules-5.22_5.22.1-9ubuntu0.6_all.deb ...
        Unpacking perl-modules-5.22 (5.22.1-9ubuntu0.6) ...
        Selecting previously unselected package libperl5.22:amd64.
        Preparing to unpack .../libperl5.22_5.22.1-9ubuntu0.6_amd64.deb ...
        Unpacking libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Selecting previously unselected package perl.
        Preparing to unpack .../perl_5.22.1-9ubuntu0.6_amd64.deb ...
        Unpacking perl (5.22.1-9ubuntu0.6) ...
        Selecting previously unselected package libpython2.7-minimal:amd64.
        Preparing to unpack .../libpython2.7-minimal_2.7.12-1ubuntu0~16.04.4_amd64.deb ...
        Unpacking libpython2.7-minimal:amd64 (2.7.12-1ubuntu0~16.04.4) ...
        Selecting previously unselected package python2.7-minimal.
        Preparing to unpack .../python2.7-minimal_2.7.12-1ubuntu0~16.04.4_amd64.deb ...
        Unpacking python2.7-minimal (2.7.12-1ubuntu0~16.04.4) ...
        Selecting previously unselected package python-minimal.
        Preparing to unpack .../python-minimal_2.7.12-1~16.04_amd64.deb ...
        Unpacking python-minimal (2.7.12-1~16.04) ...
        Selecting previously unselected package mime-support.
        Preparing to unpack .../mime-support_3.59ubuntu1_all.deb ...
        Unpacking mime-support (3.59ubuntu1) ...
        Selecting previously unselected package libexpat1:amd64.
        Preparing to unpack .../libexpat1_2.1.0-7ubuntu0.16.04.3_amd64.deb ...
        Unpacking libexpat1:amd64 (2.1.0-7ubuntu0.16.04.3) ...
        Selecting previously unselected package libffi6:amd64.
        Preparing to unpack .../libffi6_3.2.1-4_amd64.deb ...
        Unpacking libffi6:amd64 (3.2.1-4) ...
        Selecting previously unselected package libsqlite3-0:amd64.
        Preparing to unpack .../libsqlite3-0_3.11.0-1ubuntu1.1_amd64.deb ...
        Unpacking libsqlite3-0:amd64 (3.11.0-1ubuntu1.1) ...
        Selecting previously unselected package libssl1.0.0:amd64.
        Preparing to unpack .../libssl1.0.0_1.0.2g-1ubuntu4.15_amd64.deb ...
        Unpacking libssl1.0.0:amd64 (1.0.2g-1ubuntu4.15) ...
        Selecting previously unselected package libpython2.7-stdlib:amd64.
        Preparing to unpack .../libpython2.7-stdlib_2.7.12-1ubuntu0~16.04.4_amd64.deb ...
        Unpacking libpython2.7-stdlib:amd64 (2.7.12-1ubuntu0~16.04.4) ...
        Selecting previously unselected package python2.7.
        Preparing to unpack .../python2.7_2.7.12-1ubuntu0~16.04.4_amd64.deb ...
        Unpacking python2.7 (2.7.12-1ubuntu0~16.04.4) ...
        Selecting previously unselected package libpython-stdlib:amd64.
        Preparing to unpack .../libpython-stdlib_2.7.12-1~16.04_amd64.deb ...
        Unpacking libpython-stdlib:amd64 (2.7.12-1~16.04) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libpython2.7-minimal:amd64 (2.7.12-1ubuntu0~16.04.4) ...
        Setting up python2.7-minimal (2.7.12-1ubuntu0~16.04.4) ...
        Linking and byte-compiling packages for runtime python2.7...
        Setting up python-minimal (2.7.12-1~16.04) ...
        Selecting previously unselected package python.
        (Reading database ... 7363 files and directories currently installed.)
        Preparing to unpack .../python_2.7.12-1~16.04_amd64.deb ...
        Unpacking python (2.7.12-1~16.04) ...
        Selecting previously unselected package libgmp10:amd64.
        Preparing to unpack .../libgmp10_2%3a6.1.0+dfsg-2_amd64.deb ...
        Unpacking libgmp10:amd64 (2:6.1.0+dfsg-2) ...
        Selecting previously unselected package libnettle6:amd64.
        Preparing to unpack .../libnettle6_3.2-1ubuntu0.16.04.1_amd64.deb ...
        Unpacking libnettle6:amd64 (3.2-1ubuntu0.16.04.1) ...
        Selecting previously unselected package libhogweed4:amd64.
        Preparing to unpack .../libhogweed4_3.2-1ubuntu0.16.04.1_amd64.deb ...
        Unpacking libhogweed4:amd64 (3.2-1ubuntu0.16.04.1) ...
        Selecting previously unselected package libidn11:amd64.
        Preparing to unpack .../libidn11_1.32-3ubuntu1.2_amd64.deb ...
        Unpacking libidn11:amd64 (1.32-3ubuntu1.2) ...
        Selecting previously unselected package libp11-kit0:amd64.
        Preparing to unpack .../libp11-kit0_0.23.2-5~ubuntu16.04.1_amd64.deb ...
        Unpacking libp11-kit0:amd64 (0.23.2-5~ubuntu16.04.1) ...
        Selecting previously unselected package libtasn1-6:amd64.
        Preparing to unpack .../libtasn1-6_4.7-3ubuntu0.16.04.3_amd64.deb ...
        Unpacking libtasn1-6:amd64 (4.7-3ubuntu0.16.04.3) ...
        Selecting previously unselected package libgnutls30:amd64.
        Preparing to unpack .../libgnutls30_3.4.10-4ubuntu1.5_amd64.deb ...
        Unpacking libgnutls30:amd64 (3.4.10-4ubuntu1.5) ...
        Selecting previously unselected package openssl.
        Preparing to unpack .../openssl_1.0.2g-1ubuntu4.15_amd64.deb ...
        Unpacking openssl (1.0.2g-1ubuntu4.15) ...
        Selecting previously unselected package ca-certificates.
        Preparing to unpack .../ca-certificates_20170717~16.04.2_all.deb ...
        Unpacking ca-certificates (20170717~16.04.2) ...
        Selecting previously unselected package libroken18-heimdal:amd64.
        Preparing to unpack .../libroken18-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libroken18-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libasn1-8-heimdal:amd64.
        Preparing to unpack .../libasn1-8-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libasn1-8-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libkrb5support0:amd64.
        Preparing to unpack .../libkrb5support0_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libkrb5support0:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libk5crypto3:amd64.
        Preparing to unpack .../libk5crypto3_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libk5crypto3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libkeyutils1:amd64.
        Preparing to unpack .../libkeyutils1_1.5.9-8ubuntu1_amd64.deb ...
        Unpacking libkeyutils1:amd64 (1.5.9-8ubuntu1) ...
        Selecting previously unselected package libkrb5-3:amd64.
        Preparing to unpack .../libkrb5-3_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libkrb5-3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libgssapi-krb5-2:amd64.
        Preparing to unpack .../libgssapi-krb5-2_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libhcrypto4-heimdal:amd64.
        Preparing to unpack .../libhcrypto4-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libhcrypto4-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libheimbase1-heimdal:amd64.
        Preparing to unpack .../libheimbase1-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libheimbase1-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libwind0-heimdal:amd64.
        Preparing to unpack .../libwind0-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libwind0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libhx509-5-heimdal:amd64.
        Preparing to unpack .../libhx509-5-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libhx509-5-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libkrb5-26-heimdal:amd64.
        Preparing to unpack .../libkrb5-26-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libkrb5-26-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libheimntlm0-heimdal:amd64.
        Preparing to unpack .../libheimntlm0-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libheimntlm0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libgssapi3-heimdal:amd64.
        Preparing to unpack .../libgssapi3-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libgssapi3-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libsasl2-modules-db:amd64.
        Preparing to unpack .../libsasl2-modules-db_2.1.26.dfsg1-14ubuntu0.1_amd64.deb ...
        Unpacking libsasl2-modules-db:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Selecting previously unselected package libsasl2-2:amd64.
        Preparing to unpack .../libsasl2-2_2.1.26.dfsg1-14ubuntu0.1_amd64.deb ...
        Unpacking libsasl2-2:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Selecting previously unselected package libldap-2.4-2:amd64.
        Preparing to unpack .../libldap-2.4-2_2.4.42+dfsg-2ubuntu3.5_amd64.deb ...
        Unpacking libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Selecting previously unselected package librtmp1:amd64.
        Preparing to unpack .../librtmp1_2.4+20151223.gitfa8646d-1ubuntu0.1_amd64.deb ...
        Unpacking librtmp1:amd64 (2.4+20151223.gitfa8646d-1ubuntu0.1) ...
        Selecting previously unselected package libcurl3-gnutls:amd64.
        Preparing to unpack .../libcurl3-gnutls_7.47.0-1ubuntu2.13_amd64.deb ...
        Unpacking libcurl3-gnutls:amd64 (7.47.0-1ubuntu2.13) ...
        Selecting previously unselected package liberror-perl.
        Preparing to unpack .../liberror-perl_0.17-1.2_all.deb ...
        Unpacking liberror-perl (0.17-1.2) ...
        Selecting previously unselected package git-man.
        Preparing to unpack .../git-man_1%3a2.7.4-0ubuntu1.6_all.deb ...
        Unpacking git-man (1:2.7.4-0ubuntu1.6) ...
        Selecting previously unselected package git.
        Preparing to unpack .../git_1%3a2.7.4-0ubuntu1.6_amd64.deb ...
        Unpacking git (1:2.7.4-0ubuntu1.6) ...
        Selecting previously unselected package python-pip-whl.
        Preparing to unpack .../python-pip-whl_8.1.1-2ubuntu0.4_all.deb ...
        Unpacking python-pip-whl (8.1.1-2ubuntu0.4) ...
        Selecting previously unselected package python-pip.
        Preparing to unpack .../python-pip_8.1.1-2ubuntu0.4_all.deb ...
        Unpacking python-pip (8.1.1-2ubuntu0.4) ...
        Selecting previously unselected package python-pkg-resources.
        Preparing to unpack .../python-pkg-resources_20.7.0-1_all.deb ...
        Unpacking python-pkg-resources (20.7.0-1) ...
        Selecting previously unselected package python-setuptools.
        Preparing to unpack .../python-setuptools_20.7.0-1_all.deb ...
        Unpacking python-setuptools (20.7.0-1) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libgdbm3:amd64 (1.8.3-13.1) ...
        Setting up perl-modules-5.22 (5.22.1-9ubuntu0.6) ...
        Setting up libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Setting up perl (5.22.1-9ubuntu0.6) ...
        update-alternatives: using /usr/bin/prename to provide /usr/bin/rename (rename) in auto mode
        Setting up mime-support (3.59ubuntu1) ...
        Setting up libexpat1:amd64 (2.1.0-7ubuntu0.16.04.3) ...
        Setting up libffi6:amd64 (3.2.1-4) ...
        Setting up libsqlite3-0:amd64 (3.11.0-1ubuntu1.1) ...
        Setting up libssl1.0.0:amd64 (1.0.2g-1ubuntu4.15) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        Setting up libpython2.7-stdlib:amd64 (2.7.12-1ubuntu0~16.04.4) ...
        Setting up python2.7 (2.7.12-1ubuntu0~16.04.4) ...
        Setting up libpython-stdlib:amd64 (2.7.12-1~16.04) ...
        Setting up python (2.7.12-1~16.04) ...
        Setting up libgmp10:amd64 (2:6.1.0+dfsg-2) ...
        Setting up libnettle6:amd64 (3.2-1ubuntu0.16.04.1) ...
        Setting up libhogweed4:amd64 (3.2-1ubuntu0.16.04.1) ...
        Setting up libidn11:amd64 (1.32-3ubuntu1.2) ...
        Setting up libp11-kit0:amd64 (0.23.2-5~ubuntu16.04.1) ...
        Setting up libtasn1-6:amd64 (4.7-3ubuntu0.16.04.3) ...
        Setting up libgnutls30:amd64 (3.4.10-4ubuntu1.5) ...
        Setting up openssl (1.0.2g-1ubuntu4.15) ...
        Setting up ca-certificates (20170717~16.04.2) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        Setting up libroken18-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libasn1-8-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libkrb5support0:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libk5crypto3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libkeyutils1:amd64 (1.5.9-8ubuntu1) ...
        Setting up libkrb5-3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libhcrypto4-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libheimbase1-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libwind0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libhx509-5-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libkrb5-26-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libheimntlm0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libgssapi3-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libsasl2-modules-db:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Setting up libsasl2-2:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Setting up libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Setting up librtmp1:amd64 (2.4+20151223.gitfa8646d-1ubuntu0.1) ...
        Setting up libcurl3-gnutls:amd64 (7.47.0-1ubuntu2.13) ...
        Setting up liberror-perl (0.17-1.2) ...
        Setting up git-man (1:2.7.4-0ubuntu1.6) ...
        Setting up git (1:2.7.4-0ubuntu1.6) ...
        Setting up python-pip-whl (8.1.1-2ubuntu0.4) ...
        Setting up python-pip (8.1.1-2ubuntu0.4) ...
        Setting up python-pkg-resources (20.7.0-1) ...
        Setting up python-setuptools (20.7.0-1) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Processing triggers for ca-certificates (20170717~16.04.2) ...
        Updating certificates in /etc/ssl/certs...
        148 added, 0 removed; done.
        Running hooks in /etc/ca-certificates/update.d...
        done.
        Cloning into 'src/fiware_ros_msgs'...
        Already on 'master'
        Your branch is up-to-date with 'origin/master'.
        Cloning into 'src/fiware_ros_bridge'...
        Note: checking out '0.3.0'.

        You are in 'detached HEAD' state. You can look around, make experimental
        changes and commit them, and you can discard any commits you make in this
        state without impacting any branches by performing another checkout.

        If you want to create a new branch to retain commits you create, you may
        do so (now or later) by using -b with the checkout command again. Example:

          git checkout -b <new-branch-name>

        HEAD is now at 2f2bb80... Merge branch 'develop'
        Collecting wheel
          Downloading https://files.pythonhosted.org/packages/bb/10/44230dd6bf3563b8f227dbf344c908d412ad2ff48066476672f3a72e174e/wheel-0.33.4-py2.py3-none-any.whl
        Installing collected packages: wheel
        Successfully installed wheel
        You are using pip version 8.1.1, however version 19.1.1 is available.
        You should consider upgrading via the 'pip install --upgrade pip' command.
        Collecting pytz==2018.5 (from -r /opt/ros_ws/src/fiware_ros_bridge/requirements/common.txt (line 1))
          Downloading https://files.pythonhosted.org/packages/30/4e/27c34b62430286c6d59177a0842ed90dc789ce5d1ed740887653b898779a/pytz-2018.5-py2.py3-none-any.whl (510kB)
        Collecting paho-mqtt>=1.3 (from -r /opt/ros_ws/src/fiware_ros_bridge/requirements/common.txt (line 2))
          Downloading https://files.pythonhosted.org/packages/25/63/db25e62979c2a716a74950c9ed658dce431b5cb01fde29eb6cba9489a904/paho-mqtt-1.4.0.tar.gz (88kB)
        Building wheels for collected packages: paho-mqtt
          Running setup.py bdist_wheel for paho-mqtt: started
          Running setup.py bdist_wheel for paho-mqtt: finished with status 'done'
          Stored in directory: /root/.cache/pip/wheels/82/e5/de/d90d0f397648a1b58ffeea1b5742ac8c77f71fd43b550fa5a5
        Successfully built paho-mqtt
        Installing collected packages: pytz, paho-mqtt
        Successfully installed paho-mqtt-1.4.0 pytz-2018.5
        You are using pip version 8.1.1, however version 19.1.1 is available.
        You should consider upgrading via the 'pip install --upgrade pip' command.
        Reading package lists...
        Building dependency tree...
        Reading state information...
        The following packages will be REMOVED:
          git* git-man* libasn1-8-heimdal* libcurl3-gnutls* liberror-perl* libgdbm3*
          libgmp10* libgnutls30* libgssapi-krb5-2* libgssapi3-heimdal*
          libhcrypto4-heimdal* libheimbase1-heimdal* libheimntlm0-heimdal*
          libhogweed4* libhx509-5-heimdal* libidn11* libk5crypto3* libkeyutils1*
          libkrb5-26-heimdal* libkrb5-3* libkrb5support0* libldap-2.4-2* libnettle6*
          libp11-kit0* libperl5.22* libroken18-heimdal* librtmp1* libsasl2-2*
          libsasl2-modules-db* libtasn1-6* libwind0-heimdal* perl* perl-modules-5.22*
        0 upgraded, 0 newly installed, 33 to remove and 0 not upgraded.
        After this operation, 74.7 MB disk space will be freed.
        (Reading database ... 8904 files and directories currently installed.)
        Removing git (1:2.7.4-0ubuntu1.6) ...
        Purging configuration files for git (1:2.7.4-0ubuntu1.6) ...
        Removing git-man (1:2.7.4-0ubuntu1.6) ...
        Removing libcurl3-gnutls:amd64 (7.47.0-1ubuntu2.13) ...
        Removing libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Purging configuration files for libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Removing libgssapi3-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libheimntlm0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libkrb5-26-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libhx509-5-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libhcrypto4-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libasn1-8-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing liberror-perl (0.17-1.2) ...
        Removing perl (5.22.1-9ubuntu0.6) ...
        Purging configuration files for perl (5.22.1-9ubuntu0.6) ...
        Removing libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Purging configuration files for libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Removing libgdbm3:amd64 (1.8.3-13.1) ...
        Purging configuration files for libgdbm3:amd64 (1.8.3-13.1) ...
        Removing librtmp1:amd64 (2.4+20151223.gitfa8646d-1ubuntu0.1) ...
        Removing libgnutls30:amd64 (3.4.10-4ubuntu1.5) ...
        Removing libhogweed4:amd64 (3.2-1ubuntu0.16.04.1) ...
        Removing libgmp10:amd64 (2:6.1.0+dfsg-2) ...
        Removing libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Purging configuration files for libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libheimbase1-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libidn11:amd64 (1.32-3ubuntu1.2) ...
        Removing libkrb5-3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libk5crypto3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libkeyutils1:amd64 (1.5.9-8ubuntu1) ...
        Removing libkrb5support0:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libnettle6:amd64 (3.2-1ubuntu0.16.04.1) ...
        Removing libp11-kit0:amd64 (0.23.2-5~ubuntu16.04.1) ...
        Removing libwind0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libroken18-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libsasl2-2:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Removing libsasl2-modules-db:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Removing libtasn1-6:amd64 (4.7-3ubuntu0.16.04.3) ...
        Removing perl-modules-5.22 (5.22.1-9ubuntu0.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Removing intermediate container bfc22ab1017c
         ---> f8401f4da2c3
        Successfully built f8401f4da2c3
        Successfully tagged rbcacr.azurecr.io/roboticbase/fiware-ros-bridge:0.3.0
        ```

1. ACRのログイン

    ```
    $ az acr login --name ${ACR_NAME}
    ```

    - 実行結果（例）

        ```
        Login Succeeded
        WARNING! Your password will be stored unencrypted in /home/fiware/.docker/config.json.
        Configure a credential helper to remove this warning. See
        https://docs.docker.com/engine/reference/commandline/login/#credentials-store
        ```

1. Azure ACRにfiware-ros-bridgeのイメージ登録

    ```
    $ docker push ${REPOSITORY}/roboticbase/fiware-ros-bridge:${BRIDGE_GIT_REV}
    ```

    - 実行結果（例）

        ```
        The push refers to repository [rbcacr.azurecr.io/roboticbase/fiware-ros-bridge]
        907bfd21b038: Pushed
        3ab1fe801172: Pushed
        dacf0636941f: Pushed
        c1bc9ba02df9: Pushed
        68dda0c9a8cd: Mounted from roboticbase/ros-master
        f67191ae09b8: Mounted from roboticbase/ros-master
        b2fd8b4c3da7: Mounted from roboticbase/ros-master
        0de2edf7bff4: Mounted from roboticbase/ros-master
        0.3.0: digest: sha256:e0505a22c46caf9e4db4ce5b0469d61227a11e89b7b5cbf22a08aa85ecbe9b83 size: 1983
        ```

1. RabbitMQのユーザ名とパスワードの設定

    ```
    $ export MQTT_YAML_BASE64=$(cat << __EOS__ | envsubst | b64
    mqtt:
      host: "mqtt.${DOMAIN}"
      port: 8883
      username: "ros"
      password: "${MQTT__ros}"
      use_ca: true
    __EOS__)
    ```

1. fiware-ros-bridge用のsecret作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-secret.yaml > /tmp/fiware-ros-bridge-secret.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py /tmp/fiware-ros-bridge-secret.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-bridge-secret.yaml
    ```

    - 実行結果（例）

        ```
        apply /tmp/fiware-ros-bridge-secret.yaml to https://api.example.com
        status_code=204, body=
        ```

1. fiware-ros-bridge用のsecrets確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get secrets -l app=ros-bridge
    ```

    - 実行結果（例）

        ```
        NAME                 TYPE      DATA      AGE
        ros-bridge-secrets   Opaque    1         7m
        ```

1. fiware-ros-bridge用のconfigmapの作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-configmap.yaml > /tmp/fiware-ros-bridge-configmap.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py /tmp/fiware-ros-bridge-configmap.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-bridge-configmap.yaml
    ```

    - 実行結果（例）

        ```
        apply /home/fiware/example-turtlebot3/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-configmap.yaml to https://api.example.com
        status_code=204, body=
        ```

1. fiware-ros-bridge用のconfigmaps確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get configmaps -l app=ros-bridge
    ```

    - 実行結果（例）

        ```
        NAME                    DATA      AGE
        ros-bridge-configmaps   2         20h
        ```

1. fiware-ros-bridgeのservice作成

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

    - 実行結果（例）

        ```
        apply /home/fiware/example-turtlebot3/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-service.yaml to https://api.example.com
        status_code=204, body=
        ```

1. fiware-ros-bridgeのservices確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get services -l app=ros-bridge
    ```

    - 実行結果（例）

        ```
        NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
        ros-bridge   ClusterIP   None         <none>        11311/TCP   20h
        ```

1. fiware-ros-bridgeのdeployment作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-bridge/yaml/fiware-ros-bridge-deployment-acr.yaml > /tmp/fiware-ros-bridge-deployment-acr.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py /tmp/fiware-ros-bridge-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-bridge-deployment-acr.yaml
    ```

    - 実行結果（例）

        ```
        apply /tmp/fiware-ros-turtlebot3-bridge-deployment-acr.yaml to https://api.example.com
        status_code=204, body=
        ```

1. fiware-ros-bridge-deployment-acrのdeployments確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get deployments -l app=ros-bridge
    ```

    - 実行結果（例）

        ```
        NAME         READY   UP-TO-DATE   AVAILABLE   AGE
        ros-bridge   1/1     1            1           18s
        ```

1. fiware-ros-bridge-deployment-acrのpods確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=ros-bridge
    ```

    - 実行結果（例）

        ```
        NAME                          READY     STATUS    RESTARTS   AGE
        ros-bridge-6788f68d4f-9ndvm   1/1       Running   0          40s
        ```

1. ログの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl logs -f $(kubectl get pods -l app=ros-bridge -o template --template "{{(index .items 0).metadata.name}}")
    ```

    - 実行結果（例）

        ```
        Base path: /opt/ros_ws
        Source space: /opt/ros_ws/src
        Build space: /opt/ros_ws/build
        Devel space: /opt/ros_ws/devel
        Install space: /opt/ros_ws/install
        Creating symlink "/opt/ros_ws/src/CMakeLists.txt" pointing to "/opt/ros/kinetic/share/catkin/cmake/toplevel.cmake"
        ####
        #### Running command: "cmake /opt/ros_ws/src -DCATKIN_DEVEL_PREFIX=/opt/ros_ws/devel -DCMAKE_INSTALL_PREFIX=/opt/ros_ws/install -G Unix Makefiles" in "/opt/ros_ws/build"
        ####
        -- The C compiler identification is GNU 5.4.0
        -- The CXX compiler identification is GNU 5.4.0
        -- Check for working C compiler: /usr/bin/gcc
        -- Check for working C compiler: /usr/bin/gcc -- works
        -- Detecting C compiler ABI info
        -- Detecting C compiler ABI info - done
        -- Detecting C compile features
        -- Detecting C compile features - done
        -- Check for working CXX compiler: /usr/bin/g++
        -- Check for working CXX compiler: /usr/bin/g++ -- works
        -- Detecting CXX compiler ABI info
        -- Detecting CXX compiler ABI info - done
        -- Detecting CXX compile features
        -- Detecting CXX compile features - done
        -- Using CATKIN_DEVEL_PREFIX: /opt/ros_ws/devel
        -- Using CMAKE_PREFIX_PATH: /opt/ros/kinetic
        -- This workspace overlays: /opt/ros/kinetic
        -- Found PythonInterp: /usr/bin/python (found version "2.7.12") 
        -- Using PYTHON_EXECUTABLE: /usr/bin/python
        -- Using Debian Python package layout
        -- Using empy: /usr/bin/empy
        -- Using CATKIN_ENABLE_TESTING: ON
        -- Call enable_testing()
        -- Using CATKIN_TEST_RESULTS_DIR: /opt/ros_ws/build/test_results
        -- Found gmock sources under '/usr/src/gmock': gmock will be built
        -- Looking for pthread.h
        -- Looking for pthread.h - found
        -- Looking for pthread_create
        -- Looking for pthread_create - not found
        -- Looking for pthread_create in pthreads
        -- Looking for pthread_create in pthreads - not found
        -- Looking for pthread_create in pthread
        -- Looking for pthread_create in pthread - found
        -- Found Threads: TRUE  
        -- Found gtest sources under '/usr/src/gmock': gtests will be built
        -- Using Python nosetests: /usr/bin/nosetests-2.7
        -- catkin 0.7.14
        -- BUILD_SHARED_LIBS is on
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- ~~  traversing 2 packages in topological order:
        -- ~~  - fiware_ros_msgs
        -- ~~  - fiware_ros_bridge
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- +++ processing catkin package: 'fiware_ros_msgs'
        -- ==> add_subdirectory(fiware_ros_msgs)
        -- Using these message generators: gencpp;geneus;genlisp;gennodejs;genpy
        -- fiware_ros_msgs: 1 messages, 0 services
        -- +++ processing catkin package: 'fiware_ros_bridge'
        -- ==> add_subdirectory(fiware_ros_bridge)
        -- Configuring done
        -- Generating done
        -- Build files have been written to: /opt/ros_ws/build
        ####
        #### Running command: "make -j2 -l2" in "/opt/ros_ws/build"
        ####
        Scanning dependencies of target _fiware_ros_msgs_generate_messages_check_deps_r_pos
        Scanning dependencies of target std_msgs_generate_messages_py
        [  0%] Built target std_msgs_generate_messages_py
        Scanning dependencies of target std_msgs_generate_messages_cpp
        [  0%] Built target std_msgs_generate_messages_cpp
        [  0%] Built target _fiware_ros_msgs_generate_messages_check_deps_r_pos
        Scanning dependencies of target std_msgs_generate_messages_lisp
        Scanning dependencies of target std_msgs_generate_messages_eus
        [  0%] Built target std_msgs_generate_messages_lisp
        [  0%] Built target std_msgs_generate_messages_eus
        Scanning dependencies of target std_msgs_generate_messages_nodejs
        Scanning dependencies of target fiware_ros_msgs_generate_messages_py
        [  0%] Built target std_msgs_generate_messages_nodejs
        [ 14%] Generating Python from MSG fiware_ros_msgs/r_pos
        Scanning dependencies of target fiware_ros_msgs_generate_messages_cpp
        [ 28%] Generating C++ code from fiware_ros_msgs/r_pos.msg
        [ 42%] Generating Python msg __init__.py for fiware_ros_msgs
        [ 42%] Built target fiware_ros_msgs_generate_messages_cpp
        Scanning dependencies of target fiware_ros_msgs_generate_messages_lisp
        [ 57%] Generating Lisp code from fiware_ros_msgs/r_pos.msg
        [ 57%] Built target fiware_ros_msgs_generate_messages_py
        Scanning dependencies of target fiware_ros_msgs_generate_messages_eus
        [ 57%] Built target fiware_ros_msgs_generate_messages_lisp
        [ 71%] Generating EusLisp code from fiware_ros_msgs/r_pos.msg
        Scanning dependencies of target fiware_ros_msgs_generate_messages_nodejs
        [ 85%] Generating Javascript code from fiware_ros_msgs/r_pos.msg
        [ 85%] Built target fiware_ros_msgs_generate_messages_nodejs
        [100%] Generating EusLisp manifest code for fiware_ros_msgs
        [100%] Built target fiware_ros_msgs_generate_messages_eus
        Scanning dependencies of target fiware_ros_msgs_generate_messages
        [100%] Built target fiware_ros_msgs_generate_messages
        ... logging to /root/.ros/log/8b92b622-85a2-11e9-af13-0242ac110004/roslaunch-ros-bridge-5fdd6f8654-vrbh9-459.log
        Checking log directory for disk usage. This may take awhile.
        Press Ctrl-C to interrupt
        Done checking log file disk usage. Usage is <1GB.

        started roslaunch server http://ros-bridge:37487/

        SUMMARY
        ========

        PARAMETERS
         * /robot_attrs/mqtt/cafile: /opt/ros_ws/src/f...
         * /robot_attrs/mqtt/host: mqtt.example.com
         * /robot_attrs/mqtt/password: password_of_ros
         * /robot_attrs/mqtt/port: 8883
         * /robot_attrs/mqtt/use_ca: True
         * /robot_attrs/mqtt/username: ros
         * /robot_attrs/thresholds/send_delta_millisec: 1000
         * /robot_attrs/timezone: Asia/Tokyo
         * /robot_attrs/topics/mqtt: /robot/turtlebot3...
         * /robot_attrs/topics/ros/battery_state: /battery_state
         * /robot_attrs/topics/ros/pos: /turtlebot3_bridg...
         * /robot_attrs/topics/ros/r_mode: /r_mode
         * /robot_cmd/mqtt/cafile: /opt/ros_ws/src/f...
         * /robot_cmd/mqtt/host: mqtt.example.com
         * /robot_cmd/mqtt/password: password_of_ros
         * /robot_cmd/mqtt/port: 8883
         * /robot_cmd/mqtt/use_ca: True
         * /robot_cmd/mqtt/username: ros
         * /robot_cmd/topics/mqtt/cmd: /robot/turtlebot3...
         * /robot_cmd/topics/mqtt/result: /robot/turtlebot3...
         * /robot_cmd/topics/ros: /turtlebot3_bridg...
         * /rosdistro: kinetic
         * /rosversion: 1.12.14

        NODES
          /
            robot_attrs (fiware_ros_bridge/robot_attrs.py)
            robot_cmd (fiware_ros_bridge/robot_cmd.py)

        ROS_MASTER_URI=http://ros-master:11311

        running rosparam delete /robot_cmd/
        running rosparam delete /robot_attrs/
        process[robot_cmd-1]: started with pid [476]
        [INFO] [1559529339.850576]: [fiware_ros_bridge.base:CmdBridge.connect] try to Connect mqtt broker, host=mqtt.example.com
        process[robot_attrs-2]: started with pid [477]
        [INFO] [1559529339.966050]: [fiware_ros_bridge.cmd_bridge:CmdBridge.start] CmdBridge start
        [INFO] [1559529339.979330]: [fiware_ros_bridge.base:CmdBridge._on_connect] connected to mqtt broker, status=0
        [INFO] [1559529340.199076]: [fiware_ros_bridge.base:AttrsBridge.connect] try to Connect mqtt broker, host=mqtt.example.com
        [INFO] [1559529340.338059]: [fiware_ros_bridge.attrs_bridge:AttrsBridge.start] AttrsBridge start
        [INFO] [1559529340.375505]: [fiware_ros_bridge.base:AttrsBridge._on_connect] connected to mqtt broker, status=0
        ```


## fiware-ros-turtlebot3-operatorの設定
1. tagを指定

    ```
    $ export OPERATOR_GIT_REV="0.3.0"
    ```

1. fiware-ros-turtlebot3-operatorコンテナイメージの作成

    ```
    $ docker build -t ${REPOSITORY}/roboticbase/fiware-ros-turtlebot3-operator:${OPERATOR_GIT_REV} ros/fiware-ros-turtlebot3-operator
    ```

    - 実行結果（例）
      
        ```
        Sending build context to Docker daemon  18.94kB
        Step 1/12 : FROM ubuntu:16.04
         ---> b9e15a5d1e1a
        Step 2/12 : MAINTAINER Nobuyuki Matsui <nobuyuki.matsui@gmail.com>
         ---> Using cache
         ---> f9cf7efe23ef
        Step 3/12 : ENV PYTHONUNBUFFERED 1
         ---> Using cache
         ---> f4b707c2cf0a
        Step 4/12 : ARG MSGS_NAME="fiware_ros_msgs"
         ---> Using cache
         ---> c70e98192d76
        Step 5/12 : ARG MSGS_GIT_REPO="https://github.com/RoboticBase/fiware_ros_msgs.git"
         ---> Using cache
         ---> 2cca8cf0b1a3
        Step 6/12 : ARG MSGS_GIT_REV="master"
         ---> Using cache
         ---> 33ce5bd3b955
        Step 7/12 : ARG OPERATOR_NAME="fiware_ros_turtlebot3_operator"
         ---> Running in cc8e288ee7c4
        Removing intermediate container cc8e288ee7c4
         ---> 68fc37d8009a
        Step 8/12 : ARG OPERATOR_GIT_REPO="https://github.com/RoboticBase/fiware_ros_turtlebot3_operator.git"
         ---> Running in 3d908b18316b
        Removing intermediate container 3d908b18316b
         ---> db0fba9b6a68
        Step 9/12 : ARG OPERATOR_GIT_REV="0.3.0"
         ---> Running in c19a1e4900e2
        Removing intermediate container c19a1e4900e2
         ---> c85ef86cc092
        Step 10/12 : COPY ./kube_entrypoint.sh /opt/kube_entrypoint.sh
         ---> b23a9370c9f4
        Step 11/12 : WORKDIR /opt/ros_ws
         ---> Running in 2d8cd2f237d8
        Removing intermediate container 2d8cd2f237d8
         ---> 1e99ce81cbea
        Step 12/12 : RUN apt update && apt upgrade -y && apt install -y git ca-certificates --no-install-recommends &&     mkdir -p /opt/ros_ws/src &&     git clone ${MSGS_GIT_REPO} src/${MSGS_NAME} && cd src/${MSGS_NAME} && git checkout ${MSGS_GIT_REV} && cd ../.. &&     git clone ${OPERATOR_GIT_REPO} src/${OPERATOR_NAME} && cd src/${OPERATOR_NAME} && git checkout ${OPERATOR_GIT_REV} && cd ../.. &&     rm -rf /var/lib/apt/lists/* &&     apt-get purge -y --auto-remove git
         ---> Running in 72e2c56365b5

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial InRelease [247 kB]
        Get:3 http://security.ubuntu.com/ubuntu xenial-security/universe Sources [130 kB]
        Get:4 http://security.ubuntu.com/ubuntu xenial-security/main amd64 Packages [833 kB]
        Get:5 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [109 kB]
        Get:6 http://security.ubuntu.com/ubuntu xenial-security/restricted amd64 Packages [12.7 kB]
        Get:7 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [554 kB]
        Get:8 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [107 kB]
        Get:9 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [6113 B]
        Get:10 http://archive.ubuntu.com/ubuntu xenial/universe Sources [9802 kB]
        Get:11 http://archive.ubuntu.com/ubuntu xenial/main amd64 Packages [1558 kB]
        Get:12 http://archive.ubuntu.com/ubuntu xenial/restricted amd64 Packages [14.1 kB]
        Get:13 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [9827 kB]
        Get:14 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [176 kB]
        Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/universe Sources [321 kB]
        Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 Packages [1237 kB]
        Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/restricted amd64 Packages [13.1 kB]
        Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [966 kB]
        Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [19.1 kB]
        Get:20 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [7942 B]
        Get:21 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [8532 B]
        Fetched 26.1 MB in 8s (2901 kB/s)
        Reading package lists...
        Building dependency tree...
        Reading state information...
        29 packages can be upgraded. Run 'apt list --upgradable' to see them.

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Reading package lists...
        Building dependency tree...
        Reading state information...
        Calculating upgrade...
        The following packages will be upgraded:
          apt base-files bash bsdutils debconf dpkg gcc-5-base libapparmor1
          libapt-pkg5.0 libblkid1 libc-bin libc6 libfdisk1 libkmod2 libmount1
          libseccomp2 libsmartcols1 libstdc++6 libsystemd0 libudev1 libuuid1 login
          mount multiarch-support passwd perl-base systemd systemd-sysv util-linux
        29 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
        Need to get 16.1 MB of archives.
        After this operation, 255 kB of additional disk space will be used.
        Get:1 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 base-files amd64 9.4ubuntu4.8 [69.4 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 bash amd64 4.3-14ubuntu1.3 [583 kB]
        Get:3 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 bsdutils amd64 1:2.27.1-6ubuntu3.7 [51.1 kB]
        Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 dpkg amd64 1.18.4ubuntu1.5 [2085 kB]
        Get:5 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 login amd64 1:4.2-3.1ubuntu5.4 [304 kB]
        Get:6 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 util-linux amd64 2.27.1-6ubuntu3.7 [849 kB]
        Get:7 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 mount amd64 2.27.1-6ubuntu3.7 [121 kB]
        Get:8 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 perl-base amd64 5.22.1-9ubuntu0.6 [1283 kB]
        Get:9 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libc6 amd64 2.23-0ubuntu11 [2577 kB]
        Get:10 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libc-bin amd64 2.23-0ubuntu11 [631 kB]
        Get:11 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 gcc-5-base amd64 5.4.0-6ubuntu1~16.04.11 [17.3 kB]
        Get:12 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libstdc++6 amd64 5.4.0-6ubuntu1~16.04.11 [393 kB]
        Get:13 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libapt-pkg5.0 amd64 1.2.31 [712 kB]
        Get:14 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 apt amd64 1.2.31 [1087 kB]
        Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 debconf all 1.5.58ubuntu2 [136 kB]
        Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libapparmor1 amd64 2.10.95-0ubuntu2.10 [29.7 kB]
        Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 passwd amd64 1:4.2-3.1ubuntu5.4 [780 kB]
        Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libuuid1 amd64 2.27.1-6ubuntu3.7 [14.9 kB]
        Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libblkid1 amd64 2.27.1-6ubuntu3.7 [107 kB]
        Get:20 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkmod2 amd64 22-1ubuntu5.2 [39.9 kB]
        Get:21 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libmount1 amd64 2.27.1-6ubuntu3.7 [115 kB]
        Get:22 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libseccomp2 amd64 2.4.1-0ubuntu0.16.04.2 [38.5 kB]
        Get:23 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsystemd0 amd64 229-4ubuntu21.21 [204 kB]
        Get:24 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 systemd amd64 229-4ubuntu21.21 [3629 kB]
        Get:25 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 systemd-sysv amd64 229-4ubuntu21.21 [11.1 kB]
        Get:26 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libfdisk1 amd64 2.27.1-6ubuntu3.7 [138 kB]
        Get:27 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsmartcols1 amd64 2.27.1-6ubuntu3.7 [62.5 kB]
        Get:28 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libudev1 amd64 229-4ubuntu21.21 [53.6 kB]
        Get:29 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 multiarch-support amd64 2.23-0ubuntu11 [6822 B]
        debconf: delaying package configuration, since apt-utils is not installed
        Fetched 16.1 MB in 6s (2459 kB/s)
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../base-files_9.4ubuntu4.8_amd64.deb ...
        Unpacking base-files (9.4ubuntu4.8) over (9.4ubuntu4.7) ...
        Setting up base-files (9.4ubuntu4.8) ...
        Installing new version of config file /etc/issue ...
        Installing new version of config file /etc/issue.net ...
        Installing new version of config file /etc/lsb-release ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../bash_4.3-14ubuntu1.3_amd64.deb ...
        Unpacking bash (4.3-14ubuntu1.3) over (4.3-14ubuntu1.2) ...
        Setting up bash (4.3-14ubuntu1.3) ...
        update-alternatives: using /usr/share/man/man7/bash-builtins.7.gz to provide /usr/share/man/man7/builtins.7.gz (builtins.7.gz) in auto mode
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../bsdutils_1%3a2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking bsdutils (1:2.27.1-6ubuntu3.7) over (1:2.27.1-6ubuntu3.6) ...
        Setting up bsdutils (1:2.27.1-6ubuntu3.7) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../dpkg_1.18.4ubuntu1.5_amd64.deb ...
        Unpacking dpkg (1.18.4ubuntu1.5) over (1.18.4ubuntu1.4) ...
        Setting up dpkg (1.18.4ubuntu1.5) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../login_1%3a4.2-3.1ubuntu5.4_amd64.deb ...
        Unpacking login (1:4.2-3.1ubuntu5.4) over (1:4.2-3.1ubuntu5.3) ...
        Setting up login (1:4.2-3.1ubuntu5.4) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../util-linux_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking util-linux (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Setting up util-linux (2.27.1-6ubuntu3.7) ...
        Processing triggers for systemd (229-4ubuntu21.4) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../mount_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking mount (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Setting up mount (2.27.1-6ubuntu3.7) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../perl-base_5.22.1-9ubuntu0.6_amd64.deb ...
        Unpacking perl-base (5.22.1-9ubuntu0.6) over (5.22.1-9ubuntu0.5) ...
        Setting up perl-base (5.22.1-9ubuntu0.6) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libc6_2.23-0ubuntu11_amd64.deb ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        Unpacking libc6:amd64 (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up libc6:amd64 (2.23-0ubuntu11) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        Processing triggers for libc-bin (2.23-0ubuntu10) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libc-bin_2.23-0ubuntu11_amd64.deb ...
        Unpacking libc-bin (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../gcc-5-base_5.4.0-6ubuntu1~16.04.11_amd64.deb ...
        Unpacking gcc-5-base:amd64 (5.4.0-6ubuntu1~16.04.11) over (5.4.0-6ubuntu1~16.04.10) ...
        Setting up gcc-5-base:amd64 (5.4.0-6ubuntu1~16.04.11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libstdc++6_5.4.0-6ubuntu1~16.04.11_amd64.deb ...
        Unpacking libstdc++6:amd64 (5.4.0-6ubuntu1~16.04.11) over (5.4.0-6ubuntu1~16.04.10) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libstdc++6:amd64 (5.4.0-6ubuntu1~16.04.11) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../libapt-pkg5.0_1.2.31_amd64.deb ...
        Unpacking libapt-pkg5.0:amd64 (1.2.31) over (1.2.27) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libapt-pkg5.0:amd64 (1.2.31) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4768 files and directories currently installed.)
        Preparing to unpack .../archives/apt_1.2.31_amd64.deb ...
        Unpacking apt (1.2.31) over (1.2.27) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up apt (1.2.31) ...
        Installing new version of config file /etc/apt/apt.conf.d/01autoremove ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../debconf_1.5.58ubuntu2_all.deb ...
        Unpacking debconf (1.5.58ubuntu2) over (1.5.58ubuntu1) ...
        Setting up debconf (1.5.58ubuntu2) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        debconf: unable to initialize frontend: Readline
        debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.22.1 /usr/local/share/perl/5.22.1 /usr/lib/x86_64-linux-gnu/perl5/5.22 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.22 /usr/share/perl/5.22 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
        debconf: falling back to frontend: Teletype
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libapparmor1_2.10.95-0ubuntu2.10_amd64.deb ...
        Unpacking libapparmor1:amd64 (2.10.95-0ubuntu2.10) over (2.10.95-0ubuntu2.9) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libapparmor1:amd64 (2.10.95-0ubuntu2.10) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../passwd_1%3a4.2-3.1ubuntu5.4_amd64.deb ...
        Unpacking passwd (1:4.2-3.1ubuntu5.4) over (1:4.2-3.1ubuntu5.3) ...
        Setting up passwd (1:4.2-3.1ubuntu5.4) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libuuid1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libuuid1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libuuid1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libblkid1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libblkid1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libblkid1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libkmod2_22-1ubuntu5.2_amd64.deb ...
        Unpacking libkmod2:amd64 (22-1ubuntu5.2) over (22-1ubuntu5) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libkmod2:amd64 (22-1ubuntu5.2) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libmount1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libmount1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libmount1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libseccomp2_2.4.1-0ubuntu0.16.04.2_amd64.deb ...
        Unpacking libseccomp2:amd64 (2.4.1-0ubuntu0.16.04.2) over (2.3.1-2.1ubuntu2~16.04.1) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libseccomp2:amd64 (2.4.1-0ubuntu0.16.04.2) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libsystemd0_229-4ubuntu21.21_amd64.deb ...
        Unpacking libsystemd0:amd64 (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libsystemd0:amd64 (229-4ubuntu21.21) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../systemd_229-4ubuntu21.21_amd64.deb ...
        Unpacking systemd (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Setting up systemd (229-4ubuntu21.21) ...
        Initializing machine ID from random generator.
        addgroup: The group `systemd-journal' already exists as a system group. Exiting.
        Operation failed: No such file or directory
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../systemd-sysv_229-4ubuntu21.21_amd64.deb ...
        Unpacking systemd-sysv (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Setting up systemd-sysv (229-4ubuntu21.21) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libfdisk1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libfdisk1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libfdisk1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libsmartcols1_2.27.1-6ubuntu3.7_amd64.deb ...
        Unpacking libsmartcols1:amd64 (2.27.1-6ubuntu3.7) over (2.27.1-6ubuntu3.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libsmartcols1:amd64 (2.27.1-6ubuntu3.7) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libudev1_229-4ubuntu21.21_amd64.deb ...
        Unpacking libudev1:amd64 (229-4ubuntu21.21) over (229-4ubuntu21.4) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libudev1:amd64 (229-4ubuntu21.21) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../multiarch-support_2.23-0ubuntu11_amd64.deb ...
        Unpacking multiarch-support (2.23-0ubuntu11) over (2.23-0ubuntu10) ...
        Setting up multiarch-support (2.23-0ubuntu11) ...

        WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

        Reading package lists...
        Building dependency tree...
        Reading state information...
        The following additional packages will be installed:
          git-man libasn1-8-heimdal libcurl3-gnutls liberror-perl libexpat1 libffi6
          libgdbm3 libgmp10 libgnutls30 libgssapi-krb5-2 libgssapi3-heimdal
          libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhogweed4
          libhx509-5-heimdal libidn11 libk5crypto3 libkeyutils1 libkrb5-26-heimdal
          libkrb5-3 libkrb5support0 libldap-2.4-2 libnettle6 libp11-kit0 libperl5.22
          libroken18-heimdal librtmp1 libsasl2-2 libsasl2-modules-db libsqlite3-0
          libssl1.0.0 libtasn1-6 libwind0-heimdal openssl perl perl-modules-5.22
        Suggested packages:
          gettext-base git-daemon-run | git-daemon-sysvinit git-doc git-el git-email
          git-gui gitk gitweb git-arch git-cvs git-mediawiki git-svn gnutls-bin
          krb5-doc krb5-user perl-doc libterm-readline-gnu-perl
          | libterm-readline-perl-perl make
        Recommended packages:
          patch less rsync ssh-client krb5-locales libsasl2-modules netbase rename
        The following NEW packages will be installed:
          ca-certificates git git-man libasn1-8-heimdal libcurl3-gnutls liberror-perl
          libexpat1 libffi6 libgdbm3 libgmp10 libgnutls30 libgssapi-krb5-2
          libgssapi3-heimdal libhcrypto4-heimdal libheimbase1-heimdal
          libheimntlm0-heimdal libhogweed4 libhx509-5-heimdal libidn11 libk5crypto3
          libkeyutils1 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libldap-2.4-2
          libnettle6 libp11-kit0 libperl5.22 libroken18-heimdal librtmp1 libsasl2-2
          libsasl2-modules-db libsqlite3-0 libssl1.0.0 libtasn1-6 libwind0-heimdal
          openssl perl perl-modules-5.22
        0 upgraded, 39 newly installed, 0 to remove and 0 not upgraded.
        Need to get 15.4 MB of archives.
        After this operation, 80.9 MB of additional disk space will be used.
        Get:1 http://archive.ubuntu.com/ubuntu xenial/main amd64 libgdbm3 amd64 1.8.3-13.1 [16.9 kB]
        Get:2 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 perl-modules-5.22 all 5.22.1-9ubuntu0.6 [2629 kB]
        Get:3 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libperl5.22 amd64 5.22.1-9ubuntu0.6 [3405 kB]
        Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 perl amd64 5.22.1-9ubuntu0.6 [237 kB]
        Get:5 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libexpat1 amd64 2.1.0-7ubuntu0.16.04.3 [71.2 kB]
        Get:6 http://archive.ubuntu.com/ubuntu xenial/main amd64 libffi6 amd64 3.2.1-4 [17.8 kB]
        Get:7 http://archive.ubuntu.com/ubuntu xenial/main amd64 libgmp10 amd64 2:6.1.0+dfsg-2 [240 kB]
        Get:8 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libnettle6 amd64 3.2-1ubuntu0.16.04.1 [93.5 kB]
        Get:9 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libhogweed4 amd64 3.2-1ubuntu0.16.04.1 [136 kB]
        Get:10 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libidn11 amd64 1.32-3ubuntu1.2 [46.5 kB]
        Get:11 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libp11-kit0 amd64 0.23.2-5~ubuntu16.04.1 [105 kB]
        Get:12 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libtasn1-6 amd64 4.7-3ubuntu0.16.04.3 [43.5 kB]
        Get:13 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libgnutls30 amd64 3.4.10-4ubuntu1.5 [548 kB]
        Get:14 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsqlite3-0 amd64 3.11.0-1ubuntu1.1 [396 kB]
        Get:15 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libssl1.0.0 amd64 1.0.2g-1ubuntu4.15 [1084 kB]
        Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 openssl amd64 1.0.2g-1ubuntu4.15 [492 kB]
        Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 ca-certificates all 20170717~16.04.2 [167 kB]
        Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libroken18-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [41.4 kB]
        Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libasn1-8-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [174 kB]
        Get:20 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkrb5support0 amd64 1.13.2+dfsg-5ubuntu2.1 [31.2 kB]
        Get:21 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libk5crypto3 amd64 1.13.2+dfsg-5ubuntu2.1 [81.3 kB]
        Get:22 http://archive.ubuntu.com/ubuntu xenial/main amd64 libkeyutils1 amd64 1.5.9-8ubuntu1 [9904 B]
        Get:23 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkrb5-3 amd64 1.13.2+dfsg-5ubuntu2.1 [273 kB]
        Get:24 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libgssapi-krb5-2 amd64 1.13.2+dfsg-5ubuntu2.1 [120 kB]
        Get:25 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libhcrypto4-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [85.0 kB]
        Get:26 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libheimbase1-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [29.3 kB]
        Get:27 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libwind0-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [47.8 kB]
        Get:28 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libhx509-5-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [107 kB]
        Get:29 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libkrb5-26-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [202 kB]
        Get:30 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libheimntlm0-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [15.1 kB]
        Get:31 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libgssapi3-heimdal amd64 1.7~git20150920+dfsg-4ubuntu1.16.04.1 [96.1 kB]
        Get:32 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsasl2-modules-db amd64 2.1.26.dfsg1-14ubuntu0.1 [14.5 kB]
        Get:33 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libsasl2-2 amd64 2.1.26.dfsg1-14ubuntu0.1 [48.6 kB]
        Get:34 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libldap-2.4-2 amd64 2.4.42+dfsg-2ubuntu3.5 [161 kB]
        Get:35 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 librtmp1 amd64 2.4+20151223.gitfa8646d-1ubuntu0.1 [54.4 kB]
        Get:36 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 libcurl3-gnutls amd64 7.47.0-1ubuntu2.13 [184 kB]
        Get:37 http://archive.ubuntu.com/ubuntu xenial/main amd64 liberror-perl all 0.17-1.2 [19.6 kB]
        Get:38 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 git-man all 1:2.7.4-0ubuntu1.6 [736 kB]
        Get:39 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 git amd64 1:2.7.4-0ubuntu1.6 [3176 kB]
        debconf: delaying package configuration, since apt-utils is not installed
        Fetched 15.4 MB in 6s (2393 kB/s)
        Selecting previously unselected package libgdbm3:amd64.
        (Reading database ... 4777 files and directories currently installed.)
        Preparing to unpack .../libgdbm3_1.8.3-13.1_amd64.deb ...
        Unpacking libgdbm3:amd64 (1.8.3-13.1) ...
        Selecting previously unselected package perl-modules-5.22.
        Preparing to unpack .../perl-modules-5.22_5.22.1-9ubuntu0.6_all.deb ...
        Unpacking perl-modules-5.22 (5.22.1-9ubuntu0.6) ...
        Selecting previously unselected package libperl5.22:amd64.
        Preparing to unpack .../libperl5.22_5.22.1-9ubuntu0.6_amd64.deb ...
        Unpacking libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Selecting previously unselected package perl.
        Preparing to unpack .../perl_5.22.1-9ubuntu0.6_amd64.deb ...
        Unpacking perl (5.22.1-9ubuntu0.6) ...
        Selecting previously unselected package libexpat1:amd64.
        Preparing to unpack .../libexpat1_2.1.0-7ubuntu0.16.04.3_amd64.deb ...
        Unpacking libexpat1:amd64 (2.1.0-7ubuntu0.16.04.3) ...
        Selecting previously unselected package libffi6:amd64.
        Preparing to unpack .../libffi6_3.2.1-4_amd64.deb ...
        Unpacking libffi6:amd64 (3.2.1-4) ...
        Selecting previously unselected package libgmp10:amd64.
        Preparing to unpack .../libgmp10_2%3a6.1.0+dfsg-2_amd64.deb ...
        Unpacking libgmp10:amd64 (2:6.1.0+dfsg-2) ...
        Selecting previously unselected package libnettle6:amd64.
        Preparing to unpack .../libnettle6_3.2-1ubuntu0.16.04.1_amd64.deb ...
        Unpacking libnettle6:amd64 (3.2-1ubuntu0.16.04.1) ...
        Selecting previously unselected package libhogweed4:amd64.
        Preparing to unpack .../libhogweed4_3.2-1ubuntu0.16.04.1_amd64.deb ...
        Unpacking libhogweed4:amd64 (3.2-1ubuntu0.16.04.1) ...
        Selecting previously unselected package libidn11:amd64.
        Preparing to unpack .../libidn11_1.32-3ubuntu1.2_amd64.deb ...
        Unpacking libidn11:amd64 (1.32-3ubuntu1.2) ...
        Selecting previously unselected package libp11-kit0:amd64.
        Preparing to unpack .../libp11-kit0_0.23.2-5~ubuntu16.04.1_amd64.deb ...
        Unpacking libp11-kit0:amd64 (0.23.2-5~ubuntu16.04.1) ...
        Selecting previously unselected package libtasn1-6:amd64.
        Preparing to unpack .../libtasn1-6_4.7-3ubuntu0.16.04.3_amd64.deb ...
        Unpacking libtasn1-6:amd64 (4.7-3ubuntu0.16.04.3) ...
        Selecting previously unselected package libgnutls30:amd64.
        Preparing to unpack .../libgnutls30_3.4.10-4ubuntu1.5_amd64.deb ...
        Unpacking libgnutls30:amd64 (3.4.10-4ubuntu1.5) ...
        Selecting previously unselected package libsqlite3-0:amd64.
        Preparing to unpack .../libsqlite3-0_3.11.0-1ubuntu1.1_amd64.deb ...
        Unpacking libsqlite3-0:amd64 (3.11.0-1ubuntu1.1) ...
        Selecting previously unselected package libssl1.0.0:amd64.
        Preparing to unpack .../libssl1.0.0_1.0.2g-1ubuntu4.15_amd64.deb ...
        Unpacking libssl1.0.0:amd64 (1.0.2g-1ubuntu4.15) ...
        Selecting previously unselected package openssl.
        Preparing to unpack .../openssl_1.0.2g-1ubuntu4.15_amd64.deb ...
        Unpacking openssl (1.0.2g-1ubuntu4.15) ...
        Selecting previously unselected package ca-certificates.
        Preparing to unpack .../ca-certificates_20170717~16.04.2_all.deb ...
        Unpacking ca-certificates (20170717~16.04.2) ...
        Selecting previously unselected package libroken18-heimdal:amd64.
        Preparing to unpack .../libroken18-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libroken18-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libasn1-8-heimdal:amd64.
        Preparing to unpack .../libasn1-8-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libasn1-8-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libkrb5support0:amd64.
        Preparing to unpack .../libkrb5support0_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libkrb5support0:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libk5crypto3:amd64.
        Preparing to unpack .../libk5crypto3_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libk5crypto3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libkeyutils1:amd64.
        Preparing to unpack .../libkeyutils1_1.5.9-8ubuntu1_amd64.deb ...
        Unpacking libkeyutils1:amd64 (1.5.9-8ubuntu1) ...
        Selecting previously unselected package libkrb5-3:amd64.
        Preparing to unpack .../libkrb5-3_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libkrb5-3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libgssapi-krb5-2:amd64.
        Preparing to unpack .../libgssapi-krb5-2_1.13.2+dfsg-5ubuntu2.1_amd64.deb ...
        Unpacking libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Selecting previously unselected package libhcrypto4-heimdal:amd64.
        Preparing to unpack .../libhcrypto4-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libhcrypto4-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libheimbase1-heimdal:amd64.
        Preparing to unpack .../libheimbase1-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libheimbase1-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libwind0-heimdal:amd64.
        Preparing to unpack .../libwind0-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libwind0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libhx509-5-heimdal:amd64.
        Preparing to unpack .../libhx509-5-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libhx509-5-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libkrb5-26-heimdal:amd64.
        Preparing to unpack .../libkrb5-26-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libkrb5-26-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libheimntlm0-heimdal:amd64.
        Preparing to unpack .../libheimntlm0-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libheimntlm0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libgssapi3-heimdal:amd64.
        Preparing to unpack .../libgssapi3-heimdal_1.7~git20150920+dfsg-4ubuntu1.16.04.1_amd64.deb ...
        Unpacking libgssapi3-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Selecting previously unselected package libsasl2-modules-db:amd64.
        Preparing to unpack .../libsasl2-modules-db_2.1.26.dfsg1-14ubuntu0.1_amd64.deb ...
        Unpacking libsasl2-modules-db:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Selecting previously unselected package libsasl2-2:amd64.
        Preparing to unpack .../libsasl2-2_2.1.26.dfsg1-14ubuntu0.1_amd64.deb ...
        Unpacking libsasl2-2:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Selecting previously unselected package libldap-2.4-2:amd64.
        Preparing to unpack .../libldap-2.4-2_2.4.42+dfsg-2ubuntu3.5_amd64.deb ...
        Unpacking libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Selecting previously unselected package librtmp1:amd64.
        Preparing to unpack .../librtmp1_2.4+20151223.gitfa8646d-1ubuntu0.1_amd64.deb ...
        Unpacking librtmp1:amd64 (2.4+20151223.gitfa8646d-1ubuntu0.1) ...
        Selecting previously unselected package libcurl3-gnutls:amd64.
        Preparing to unpack .../libcurl3-gnutls_7.47.0-1ubuntu2.13_amd64.deb ...
        Unpacking libcurl3-gnutls:amd64 (7.47.0-1ubuntu2.13) ...
        Selecting previously unselected package liberror-perl.
        Preparing to unpack .../liberror-perl_0.17-1.2_all.deb ...
        Unpacking liberror-perl (0.17-1.2) ...
        Selecting previously unselected package git-man.
        Preparing to unpack .../git-man_1%3a2.7.4-0ubuntu1.6_all.deb ...
        Unpacking git-man (1:2.7.4-0ubuntu1.6) ...
        Selecting previously unselected package git.
        Preparing to unpack .../git_1%3a2.7.4-0ubuntu1.6_amd64.deb ...
        Unpacking git (1:2.7.4-0ubuntu1.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Setting up libgdbm3:amd64 (1.8.3-13.1) ...
        Setting up perl-modules-5.22 (5.22.1-9ubuntu0.6) ...
        Setting up libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Setting up perl (5.22.1-9ubuntu0.6) ...
        update-alternatives: using /usr/bin/prename to provide /usr/bin/rename (rename) in auto mode
        Setting up libexpat1:amd64 (2.1.0-7ubuntu0.16.04.3) ...
        Setting up libffi6:amd64 (3.2.1-4) ...
        Setting up libgmp10:amd64 (2:6.1.0+dfsg-2) ...
        Setting up libnettle6:amd64 (3.2-1ubuntu0.16.04.1) ...
        Setting up libhogweed4:amd64 (3.2-1ubuntu0.16.04.1) ...
        Setting up libidn11:amd64 (1.32-3ubuntu1.2) ...
        Setting up libp11-kit0:amd64 (0.23.2-5~ubuntu16.04.1) ...
        Setting up libtasn1-6:amd64 (4.7-3ubuntu0.16.04.3) ...
        Setting up libgnutls30:amd64 (3.4.10-4ubuntu1.5) ...
        Setting up libsqlite3-0:amd64 (3.11.0-1ubuntu1.1) ...
        Setting up libssl1.0.0:amd64 (1.0.2g-1ubuntu4.15) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        Setting up openssl (1.0.2g-1ubuntu4.15) ...
        Setting up ca-certificates (20170717~16.04.2) ...
        debconf: unable to initialize frontend: Dialog
        debconf: (TERM is not set, so the dialog frontend is not usable.)
        debconf: falling back to frontend: Readline
        Setting up libroken18-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libasn1-8-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libkrb5support0:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libk5crypto3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libkeyutils1:amd64 (1.5.9-8ubuntu1) ...
        Setting up libkrb5-3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Setting up libhcrypto4-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libheimbase1-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libwind0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libhx509-5-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libkrb5-26-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libheimntlm0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libgssapi3-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Setting up libsasl2-modules-db:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Setting up libsasl2-2:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Setting up libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Setting up librtmp1:amd64 (2.4+20151223.gitfa8646d-1ubuntu0.1) ...
        Setting up libcurl3-gnutls:amd64 (7.47.0-1ubuntu2.13) ...
        Setting up liberror-perl (0.17-1.2) ...
        Setting up git-man (1:2.7.4-0ubuntu1.6) ...
        Setting up git (1:2.7.4-0ubuntu1.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Processing triggers for ca-certificates (20170717~16.04.2) ...
        Updating certificates in /etc/ssl/certs...
        148 added, 0 removed; done.
        Running hooks in /etc/ca-certificates/update.d...
        done.
        Cloning into 'src/fiware_ros_msgs'...
        Already on 'master'
        Your branch is up-to-date with 'origin/master'.
        Cloning into 'src/fiware_ros_turtlebot3_operator'...
        Note: checking out '0.3.0'.

        You are in 'detached HEAD' state. You can look around, make experimental
        changes and commit them, and you can discard any commits you make in this
        state without impacting any branches by performing another checkout.

        If you want to create a new branch to retain commits you create, you may
        do so (now or later) by using -b with the checkout command again. Example:

          git checkout -b <new-branch-name>

        HEAD is now at 6055467... Merge pull request #1 from RoboticBase/feature/commonalize
        Reading package lists...
        Building dependency tree...
        Reading state information...
        The following packages will be REMOVED:
          git* git-man* libasn1-8-heimdal* libcurl3-gnutls* liberror-perl* libexpat1*
          libffi6* libgdbm3* libgmp10* libgnutls30* libgssapi-krb5-2*
          libgssapi3-heimdal* libhcrypto4-heimdal* libheimbase1-heimdal*
          libheimntlm0-heimdal* libhogweed4* libhx509-5-heimdal* libidn11*
          libk5crypto3* libkeyutils1* libkrb5-26-heimdal* libkrb5-3* libkrb5support0*
          libldap-2.4-2* libnettle6* libp11-kit0* libperl5.22* libroken18-heimdal*
          librtmp1* libsasl2-2* libsasl2-modules-db* libsqlite3-0* libtasn1-6*
          libwind0-heimdal* perl* perl-modules-5.22*
        0 upgraded, 0 newly installed, 36 to remove and 0 not upgraded.
        After this operation, 76.1 MB disk space will be freed.
        (Reading database ... 7853 files and directories currently installed.)
        Removing git (1:2.7.4-0ubuntu1.6) ...
        Purging configuration files for git (1:2.7.4-0ubuntu1.6) ...
        Removing git-man (1:2.7.4-0ubuntu1.6) ...
        Removing libcurl3-gnutls:amd64 (7.47.0-1ubuntu2.13) ...
        Removing libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Purging configuration files for libldap-2.4-2:amd64 (2.4.42+dfsg-2ubuntu3.5) ...
        Removing libgssapi3-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libheimntlm0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libkrb5-26-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libhx509-5-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libhcrypto4-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libasn1-8-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing liberror-perl (0.17-1.2) ...
        Removing libexpat1:amd64 (2.1.0-7ubuntu0.16.04.3) ...
        Removing librtmp1:amd64 (2.4+20151223.gitfa8646d-1ubuntu0.1) ...
        Removing libgnutls30:amd64 (3.4.10-4ubuntu1.5) ...
        Removing libp11-kit0:amd64 (0.23.2-5~ubuntu16.04.1) ...
        Removing libffi6:amd64 (3.2.1-4) ...
        Removing perl (5.22.1-9ubuntu0.6) ...
        Purging configuration files for perl (5.22.1-9ubuntu0.6) ...
        Removing libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Purging configuration files for libperl5.22:amd64 (5.22.1-9ubuntu0.6) ...
        Removing libgdbm3:amd64 (1.8.3-13.1) ...
        Purging configuration files for libgdbm3:amd64 (1.8.3-13.1) ...
        Removing libhogweed4:amd64 (3.2-1ubuntu0.16.04.1) ...
        Removing libgmp10:amd64 (2:6.1.0+dfsg-2) ...
        Removing libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Purging configuration files for libgssapi-krb5-2:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libheimbase1-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libidn11:amd64 (1.32-3ubuntu1.2) ...
        Removing libkrb5-3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libk5crypto3:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libkeyutils1:amd64 (1.5.9-8ubuntu1) ...
        Removing libkrb5support0:amd64 (1.13.2+dfsg-5ubuntu2.1) ...
        Removing libnettle6:amd64 (3.2-1ubuntu0.16.04.1) ...
        Removing libwind0-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libroken18-heimdal:amd64 (1.7~git20150920+dfsg-4ubuntu1.16.04.1) ...
        Removing libsasl2-2:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Removing libsasl2-modules-db:amd64 (2.1.26.dfsg1-14ubuntu0.1) ...
        Removing libsqlite3-0:amd64 (3.11.0-1ubuntu1.1) ...
        Removing libtasn1-6:amd64 (4.7-3ubuntu0.16.04.3) ...
        Removing perl-modules-5.22 (5.22.1-9ubuntu0.6) ...
        Processing triggers for libc-bin (2.23-0ubuntu11) ...
        Removing intermediate container 72e2c56365b5
         ---> 2e85b296316a
        Successfully built 2e85b296316a
        Successfully tagged rbcacr.azurecr.io/roboticbase/fiware-ros-turtlebot3-operator:0.3.0
        ```

1. Azure ACRにログイン

    ```
    $ az acr login --name ${ACR_NAME}
    ```

    - 実行結果（例）
      
        ```
        Login Succeeded
        WARNING! Your password will be stored unencrypted in /home/fiware/.docker/config.json.
        Configure a credential helper to remove this warning. See
        https://docs.docker.com/engine/reference/commandline/login/#credentials-store
        ```

1. fiware-ros-turtlebot3-operatorのイメージ登録

    ```
    $ docker push ${REPOSITORY}/roboticbase/fiware-ros-turtlebot3-operator:${OPERATOR_GIT_REV}
    ```

    - 実行結果（例）

        ```
        The push refers to repository [rbcacr.azurecr.io/roboticbase/fiware-ros-turtlebot3-operator]
        460097d4a495: Pushed
        d18d38ec7365: Pushed
        82c40192d00f: Pushed
        68dda0c9a8cd: Mounted from roboticbase/fiware-ros-turtlebot3-bridge
        f67191ae09b8: Mounted from roboticbase/fiware-ros-turtlebot3-bridge
        b2fd8b4c3da7: Mounted from roboticbase/fiware-ros-turtlebot3-bridge
        0de2edf7bff4: Mounted from roboticbase/fiware-ros-turtlebot3-bridge
        0.3.0: digest: sha256:9a041f2292ee3826427050217909fd7e70c7e9a44b120186a5cbd635848994b0 size: 1983
        ```

1. fiware-ros-turtlebot3-operator用のconfigmap作成

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-configmap.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

    - 実行結果（例）

        ```
        apply /home/fiware/example-turtlebot3/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-configmap.yaml to https://api.example.com
        status_code=204, body=
        ```

1. fiware-ros-turtlebot3-operator-configmapのconfigmap確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get configmaps -l app=turtlebot3-operator
    ```

    - 実行結果（例）

        ```
        NAME                             DATA      AGE
        turtlebot3-operator-configmaps   1         1m
        ```

1. fiware-ros-turtlebot3-operatorのservice作成

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

    - 実行結果（例）

        ```
        apply /home/fiware/example-turtlebot3/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-service.yaml to https://api.example.com
        status_code=204, body=
        ```

1. fiware-ros-turtlebot3-operator-serviceのservices確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get services -l app=turtlebot3-operator
    ```

    - 実行結果（例）

        ```
        NAME                  TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
        turtlebot3-operator   ClusterIP   None         <none>        11311/TCP   17d
        ```

1. fiware-ros-turtlebot3-operatorのdeployment (wide) の作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/fiware-ros-turtlebot3-operator/yaml/fiware-ros-turtlebot3-operator-deployment-acr-wide.yaml > /tmp/fiware-ros-turtlebot3-operator-deployment-acr-wide.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py /tmp/fiware-ros-turtlebot3-operator-deployment-acr-wide.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/fiware-ros-turtlebot3-operator-deployment-acr-wide.yaml
    ```

    - 実行結果（例）

        ```
        apply /tmp/fiware-ros-turtlebot3-operator-deployment-acr-wide.yaml to https://api.example.com
        status_code=204, body=
        ```

1. fiware-ros-turtlebot3-operator-deployment-acr-wideのdeployments確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get deployments -l app=turtlebot3-operator
    ```

    - 実行結果（例）

        ```
        NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
        turtlebot3-operator   1/1     1            1           14s
        ```

1. fiware-ros-turtlebot3-operator-deployment-acr-wideのpods確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=turtlebot3-operator
    ```

    - 実行結果（例）

        ```
        NAME                                   READY     STATUS    RESTARTS   AGE
        turtlebot3-operator-85b8bbbb88-kwstt   1/1       Running   0          32s
        ```

1. ログの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl logs -f $(kubectl get pods -l app=turtlebot3-operator -o template --template "{{(index .items 0).metadata.name}}")
    ```

    - 実行結果（例）

        ```
        Base path: /opt/ros_ws
        Source space: /opt/ros_ws/src
        Build space: /opt/ros_ws/build
        Devel space: /opt/ros_ws/devel
        Install space: /opt/ros_ws/install
        Creating symlink "/opt/ros_ws/src/CMakeLists.txt" pointing to "/opt/ros/kinetic/share/catkin/cmake/toplevel.cmake"
        ####
        #### Running command: "cmake /opt/ros_ws/src -DCATKIN_DEVEL_PREFIX=/opt/ros_ws/devel -DCMAKE_INSTALL_PREFIX=/opt/ros_ws/install -G Unix Makefiles" in "/opt/ros_ws/build"
        ####
        -- The C compiler identification is GNU 5.4.0
        -- The CXX compiler identification is GNU 5.4.0
        -- Check for working C compiler: /usr/bin/cc
        -- Check for working C compiler: /usr/bin/cc -- works
        -- Detecting C compiler ABI info
        -- Detecting C compiler ABI info - done
        -- Detecting C compile features
        -- Detecting C compile features - done
        -- Check for working CXX compiler: /usr/bin/c++
        -- Check for working CXX compiler: /usr/bin/c++ -- works
        -- Detecting CXX compiler ABI info
        -- Detecting CXX compiler ABI info - done
        -- Detecting CXX compile features
        -- Detecting CXX compile features - done
        -- Using CATKIN_DEVEL_PREFIX: /opt/ros_ws/devel
        -- Using CMAKE_PREFIX_PATH: /opt/ros/kinetic
        -- This workspace overlays: /opt/ros/kinetic
        -- Found PythonInterp: /usr/bin/python (found version "2.7.12")
        -- Using PYTHON_EXECUTABLE: /usr/bin/python
        -- Using Debian Python package layout
        -- Using empy: /usr/bin/empy
        -- Using CATKIN_ENABLE_TESTING: ON
        -- Call enable_testing()
        -- Using CATKIN_TEST_RESULTS_DIR: /opt/ros_ws/build/test_results
        -- Found gmock sources under '/usr/src/gmock': gmock will be built
        -- Looking for pthread.h
        -- Looking for pthread.h - found
        -- Looking for pthread_create
        -- Looking for pthread_create - not found
        -- Looking for pthread_create in pthreads
        -- Looking for pthread_create in pthreads - not found
        -- Looking for pthread_create in pthread
        -- Looking for pthread_create in pthread - found
        -- Found Threads: TRUE
        -- Found gtest sources under '/usr/src/gmock': gtests will be built
        -- Using Python nosetests: /usr/bin/nosetests-2.7
        -- catkin 0.7.14
        -- BUILD_SHARED_LIBS is on
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- ~~  traversing 2 packages in topological order:
        -- ~~  - fiware_ros_turtlebot3_msgs
        -- ~~  - fiware_ros_turtlebot3_operator
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- +++ processing catkin package: 'fiware_ros_turtlebot3_msgs'
        -- ==> add_subdirectory(fiware_ros_turtlebot3_msgs)
        -- Using these message generators: gencpp;geneus;genlisp;gennodejs;genpy
        -- fiware_ros_turtlebot3_msgs: 1 messages, 0 services
        -- +++ processing catkin package: 'fiware_ros_turtlebot3_operator'
        -- ==> add_subdirectory(fiware_ros_turtlebot3_operator)
        -- Using these message generators: gencpp;geneus;genlisp;gennodejs;genpy
        -- Configuring done
        -- Generating done
        -- Build files have been written to: /opt/ros_ws/build
        ####
        #### Running command: "make -j4 -l4" in "/opt/ros_ws/build"
        ####
        Scanning dependencies of target std_msgs_generate_messages_eus
        Scanning dependencies of target std_msgs_generate_messages_cpp
        Scanning dependencies of target _fiware_ros_turtlebot3_msgs_generate_messages_check_deps_r_pos
        Scanning dependencies of target std_msgs_generate_messages_nodejs
        [  0%] Built target std_msgs_generate_messages_eus
        [  0%] Built target std_msgs_generate_messages_cpp
        [  0%] Built target std_msgs_generate_messages_nodejs
        Scanning dependencies of target std_msgs_generate_messages_lisp
        Scanning dependencies of target std_msgs_generate_messages_py
        [  0%] Built target std_msgs_generate_messages_lisp
        [  0%] Built target std_msgs_generate_messages_py
        [  0%] Built target _fiware_ros_turtlebot3_msgs_generate_messages_check_deps_r_pos
        Scanning dependencies of target fiware_ros_turtlebot3_msgs_generate_messages_cpp
        Scanning dependencies of target fiware_ros_turtlebot3_msgs_generate_messages_nodejs
        Scanning dependencies of target fiware_ros_turtlebot3_msgs_generate_messages_lisp
        Scanning dependencies of target fiware_ros_turtlebot3_msgs_generate_messages_eus
        [ 14%] Generating Javascript code from fiware_ros_turtlebot3_msgs/r_pos.msg
        [ 28%] Generating C++ code from fiware_ros_turtlebot3_msgs/r_pos.msg
        [ 42%] Generating Lisp code from fiware_ros_turtlebot3_msgs/r_pos.msg
        [ 57%] Generating EusLisp code from fiware_ros_turtlebot3_msgs/r_pos.msg
        [ 57%] Built target fiware_ros_turtlebot3_msgs_generate_messages_nodejs
        [ 57%] Built target fiware_ros_turtlebot3_msgs_generate_messages_lisp
        Scanning dependencies of target fiware_ros_turtlebot3_msgs_generate_messages_py
        [ 71%] Generating EusLisp manifest code for fiware_ros_turtlebot3_msgs
        [ 85%] Generating Python from MSG fiware_ros_turtlebot3_msgs/r_pos
        [ 85%] Built target fiware_ros_turtlebot3_msgs_generate_messages_cpp
        [100%] Generating Python msg __init__.py for fiware_ros_turtlebot3_msgs
        [100%] Built target fiware_ros_turtlebot3_msgs_generate_messages_py
        [100%] Built target fiware_ros_turtlebot3_msgs_generate_messages_eus
        Scanning dependencies of target fiware_ros_turtlebot3_msgs_generate_messages
        [100%] Built target fiware_ros_turtlebot3_msgs_generate_messages
        ... logging to /root/.ros/log/bc8b9f4e-3e5f-11e9-b689-0242ac110004/roslaunch-turtlebot3-operator-7d75dff7f-xt8lc-471.log
        Checking log directory for disk usage. This may take awhile.
        Press Ctrl-C to interrupt
        Done checking log file disk usage. Usage is <1GB.

        started roslaunch server http://turtlebot3-operator:36098/

        SUMMARY
        ========

        PARAMETERS
        * /attributes_sender/bridge/thresholds/send_delta_millisec: 200
        * /attributes_sender/bridge/topics/attrs_pub: /turtlebot3_bridg...
        * /attributes_sender/bridge/topics/cmd_sub: /turtlebot3_bridg...
        * /attributes_sender/turtlebot3/circle/thresholds/angular_rad: 0.02
        * /attributes_sender/turtlebot3/circle/thresholds/dist_meter: 0.1
        * /attributes_sender/turtlebot3/circle/velocities/x: 0.1
        * /attributes_sender/turtlebot3/circle/velocities/z: 0.4
        * /attributes_sender/turtlebot3/polygon/edge/length_meter: 0.4
        * /attributes_sender/turtlebot3/polygon/thresholds/angular_rad: 0.02
        * /attributes_sender/turtlebot3/polygon/thresholds/dist_meter: 0.01
        * /attributes_sender/turtlebot3/polygon/velocities/x: 0.2
        * /attributes_sender/turtlebot3/polygon/velocities/z: 0.2
        * /attributes_sender/turtlebot3/rate_hz: 10
        * /attributes_sender/turtlebot3/topics/cmd_pub: /cmd_vel
        * /attributes_sender/turtlebot3/topics/odom_sub: /odom
        * /attributes_sender/turtlebot3/unit/length_meter: 0.1
        * /attributes_sender/turtlebot3/unit/theta_rad: 0.17453292519
        * /command_receiver/bridge/thresholds/send_delta_millisec: 200
        * /command_receiver/bridge/topics/attrs_pub: /turtlebot3_bridg...
        * /command_receiver/bridge/topics/cmd_sub: /turtlebot3_bridg...
        * /command_receiver/turtlebot3/circle/thresholds/angular_rad: 0.02
        * /command_receiver/turtlebot3/circle/thresholds/dist_meter: 0.1
        * /command_receiver/turtlebot3/circle/velocities/x: 0.1
        * /command_receiver/turtlebot3/circle/velocities/z: 0.4
        * /command_receiver/turtlebot3/polygon/edge/length_meter: 0.4
        * /command_receiver/turtlebot3/polygon/thresholds/angular_rad: 0.02
        * /command_receiver/turtlebot3/polygon/thresholds/dist_meter: 0.01
        * /command_receiver/turtlebot3/polygon/velocities/x: 0.2
        * /command_receiver/turtlebot3/polygon/velocities/z: 0.2
        * /command_receiver/turtlebot3/rate_hz: 10
        * /command_receiver/turtlebot3/topics/cmd_pub: /cmd_vel
        * /command_receiver/turtlebot3/topics/odom_sub: /odom
        * /command_receiver/turtlebot3/unit/length_meter: 0.1
        * /command_receiver/turtlebot3/unit/theta_rad: 0.17453292519
        * /rosdistro: kinetic
        * /rosversion: 1.12.14

        NODES
            /
            attributes_sender (fiware_ros_turtlebot3_operator/attributes_sender.py)
            command_receiver (fiware_ros_turtlebot3_operator/command_receiver.py)

        ROS_MASTER_URI=http://ros-master:11311

        running rosparam delete /command_receiver/
        ERROR: parameter [/command_receiver] is not set
        running rosparam delete /attributes_sender/
        ERROR: parameter [/attributes_sender] is not set
        process[command_receiver-1]: started with pid [488]
        process[attributes_sender-2]: started with pid [489]
        the rosdep view is empty: call 'sudo rosdep init' and 'rosdep update'
        [INFO] [1551760354.329952]: [fiware_ros_turtlebot3_operator.command_receiver:CommandReceiver._override_params] override params['turtlebot3']['circle']['velocities']['x'] = 0.1
        [INFO] [1551760354.330414]: [fiware_ros_turtlebot3_operator.command_receiver:CommandReceiver._override_params] override params['turtlebot3']['circle']['velocities']['z'] = 0.4
        [INFO] [1551760354.330885]: [fiware_ros_turtlebot3_operator.command_receiver:CommandReceiver._override_params] override params['turtlebot3']['polygon']['velocities']['x'] = 0.2
        [INFO] [1551760354.331271]: [fiware_ros_turtlebot3_operator.command_receiver:CommandReceiver._override_params] override params['turtlebot3']['polygon']['velocities']['z'] = 0.3
        [INFO] [1551760354.331617]: [fiware_ros_turtlebot3_operator.command_receiver:CommandReceiver._override_params] override params['turtlebot3']['polygon']['edge']['length_meter'] = 0.4
        the rosdep view is empty: call 'sudo rosdep init' and 'rosdep update'
        [INFO] [1551760354.341339]: [fiware_ros_turtlebot3_operator.command_receiver:CommandReceiver.start] CommandReceiver start
        [INFO] [1551760354.533086]: [fiware_ros_turtlebot3_operator.attributes_sender:AttributesSender.start] AttributesSender start
        ```

## A.turtlebot3シミュレータの設定

1. turtlebot3シミュレータ側のUIDの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ echo ${UID}
    ```

    - 実行結果（例）

        ```
        1000
        ```

1. 環境変数の設定

    ```
    $ export TURTLEBOT3_USER=turtlebot3
    $ export TURTLEBOT3_UID=1000
    ```

1. turtlebot3-fakeのビルド

    ```
    $ docker build -t ${REPOSITORY}/roboticbase/turtlebot3-fake:0.2.0 --build-arg TURTLEBOT3_USER=${TURTLEBOT3_USER} --build-arg TURTLEBOT3_UID=${TURTLEBOT3_UID} ros/turtlebot3-fake
    ```

1. Azure ACRのログイン

    ```
    $ az acr login --name ${ACR_NAME}
    ```

1. turtlebot3-fakeのイメージ登録

    ```
    $ docker push ${REPOSITORY}/roboticbase/turtlebot3-fake:0.2.0
    ```

1. turtlebot3-fake-serviceの作成
   
    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py ${PJ_ROOT}/ros/turtlebot3-fake/yaml/turtlebot3-fake-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. サービスの起動確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get services -l app=turtlebot3-fake
    ```
    - 実行結果（例）

        ```
        NAME              TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
        turtlebot3-fake   ClusterIP   None         <none>        11311/TCP   11s
        ```

1. turtlebot3-fake-deployment-minikubeの作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/turtlebot3-fake/yaml/turtlebot3-fake-deployment-acr.yaml > /tmp/turtlebot3-fake-deployment-acr.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py /tmp/turtlebot3-fake-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/turtlebot3-fake-deployment-acr.yaml
    ```

1. turtlebot3-fakeのdeployments状態確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get deployments -l app=turtlebot3-fake
    ```

    - 実行結果（例）

        ```
        NAME              READY   UP-TO-DATE   AVAILABLE   AGE
        turtlebot3-fake   1/1     1            1           77s
        ```

1. turtlebot3-fakeのpods状態確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=turtlebot3-fake

    ```

    - 実行結果（例）

        ```
        NAME                              READY     STATUS    RESTARTS   AGE
        turtlebot3-fake-df8bbc6f5-cpftd   1/1       Running   0          38s
        ```

1. ログの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl logs -f $(kubectl get pods -l app=turtlebot3-fake -o template --template "{{(index .items 0).metadata.name}}")
    ```

## A.(alterntive) turtlebot3シミュレータの設定

OpenGLのトラブルが原因でturtlebot3-fakeのポッドが起動しない場合は、以下を実行してください。

## telepresenceの設定【turtlebot3-pc】

1. telepresenceのリポジトリ登録【turtlebot3-pc】

    ```
    turtlebot3-pc$ curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | sudo bash
    ```

    - 実行結果（例）

        ```
        Detected operating system as Ubuntu/xenial.
        Checking for curl...
        Detected curl...
        Checking for gpg...
        Detected gpg...
        Running apt-get update... *** Error in `appstreamcli': double free or corruption (fasttop): 0x00000000020737a0 ***
        ======= Backtrace: =========
        /lib/x86_64-linux-gnu/libc.so.6(+0x777e5)[0x7ff0abef77e5]
        /lib/x86_64-linux-gnu/libc.so.6(+0x8037a)[0x7ff0abf0037a]
        /lib/x86_64-linux-gnu/libc.so.6(cfree+0x4c)[0x7ff0abf0453c]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_component_complete+0x439)[0x7ff0ac27cd19]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_data_pool_update+0x44a)[0x7ff0ac27df0a]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_cache_builder_refresh+0x1c2)[0x7ff0ac273272]
        appstreamcli(ascli_refresh_cache+0x12e)[0x4049de]
        appstreamcli(as_client_run+0x6fb)[0x403ceb]
        /lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0xf0)[0x7ff0abea0830]
        appstreamcli(_start+0x29)[0x403519]
        ======= Memory map: ========
        00400000-00408000 r-xp 00000000 08:02 5767218                            /usr/bin/appstreamcli
        00607000-00608000 r--p 00007000 08:02 5767218                            /usr/bin/appstreamcli
        00608000-00609000 rw-p 00008000 08:02 5767218                            /usr/bin/appstreamcli
        0153e000-0318f000 rw-p 00000000 00:00 0                                  [heap]
        7ff0a0000000-7ff0a0021000 rw-p 00000000 00:00 0
        7ff0a0021000-7ff0a4000000 ---p 00000000 00:00 0
        7ff0a73dd000-7ff0a7672000 r--p 00000000 08:02 5774055                    /usr/lib/locale/locale-archive
        7ff0a7672000-7ff0a8f28000 r-xp 00000000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7ff0a8f28000-7ff0a9127000 ---p 018b6000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7ff0a9127000-7ff0a9128000 r--p 018b5000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7ff0a9128000-7ff0a9129000 rw-p 018b6000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7ff0a9129000-7ff0a912d000 r-xp 00000000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7ff0a912d000-7ff0a932c000 ---p 00004000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7ff0a932c000-7ff0a932d000 r--p 00003000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7ff0a932d000-7ff0a932e000 rw-p 00004000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7ff0a932e000-7ff0a9436000 r-xp 00000000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7ff0a9436000-7ff0a9635000 ---p 00108000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7ff0a9635000-7ff0a9636000 r--p 00107000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7ff0a9636000-7ff0a9637000 rw-p 00108000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7ff0a9637000-7ff0a9658000 r-xp 00000000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7ff0a9658000-7ff0a9857000 ---p 00021000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7ff0a9857000-7ff0a9858000 r--p 00020000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7ff0a9858000-7ff0a9859000 rw-p 00021000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7ff0a9859000-7ff0a99d8000 r-xp 00000000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7ff0a99d8000-7ff0a9bd8000 ---p 0017f000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7ff0a9bd8000-7ff0a9be8000 r--p 0017f000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7ff0a9be8000-7ff0a9be9000 rw-p 0018f000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7ff0a9be9000-7ff0a9bed000 rw-p 00000000 00:00 0
        7ff0a9bed000-7ff0a9bf0000 r-xp 00000000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7ff0a9bf0000-7ff0a9def000 ---p 00003000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7ff0a9def000-7ff0a9df0000 r--p 00002000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7ff0a9df0000-7ff0a9df1000 rw-p 00003000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7ff0a9df1000-7ff0a9e07000 r-xp 00000000 08:02 135631                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7ff0a9e07000-7ff0aa006000 ---p 00016000 08:02 135631                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7ff0aa006000-7ff0aa007000 rw-p 00015000 08:02 135631                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7ff0aa007000-7ff0aa179000 r-xp 00000000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7ff0aa179000-7ff0aa379000 ---p 00172000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7ff0aa379000-7ff0aa383000 r--p 00172000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7ff0aa383000-7ff0aa385000 rw-p 0017c000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7ff0aa385000-7ff0aa389000 rw-p 00000000 00:00 0
        7ff0aa389000-7ff0aa3b9000 r-xp 00000000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7ff0aa3b9000-7ff0aa5b8000 ---p 00030000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7ff0aa5b8000-7ff0aa5b9000 r--p 0002f000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7ff0aa5b9000-7ff0aa5ba000 rw-p 00030000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7ff0aa5ba000-7ff0aa7ae000 r-xp 00000000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7ff0aa7ae000-7ff0aa9ae000 ---p 001f4000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7ff0aa9ae000-7ff0aa9b5000 r--p 001f4000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7ff0aa9b5000-7ff0aa9b6000 rw-p 001fb000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7ff0aa9b6000-7ff0aa9d3000 r-xp 00000000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7ff0aa9d3000-7ff0aabd3000 ---p 0001d000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7ff0aabd3000-7ff0aabd4000 r--p 0001d000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7ff0aabd4000-7ff0aabd5000 rw-p 0001e000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7ff0aabd5000-7ff0aad86000 r-xp 00000000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7ff0aad86000-7ff0aaf85000 ---p 001b1000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7ff0aaf85000-7ff0aaf8d000 r--p 001b0000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7ff0aaf8d000-7ff0aaf8f000 rw-p 001b8000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7ff0aaf8f000-7ff0aaf90000 rw-p 00000000 00:00 0
        7ff0aaf90000-7ff0aaf97000 r-xp 00000000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7ff0aaf97000-7ff0ab196000 ---p 00007000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7ff0ab196000-7ff0ab197000 r--p 00006000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7ff0ab197000-7ff0ab198000 rw-p 00007000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7ff0ab198000-7ff0ab1af000 r-xp 00000000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7ff0ab1af000-7ff0ab3af000 ---p 00017000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7ff0ab3af000-7ff0ab3b0000 r--p 00017000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7ff0ab3b0000-7ff0ab3b1000 rw-p 00018000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7ff0ab3b1000-7ff0ab3b3000 rw-p 00000000 00:00 0
        7ff0ab3b3000-7ff0ab3d2000 r-xp 00000000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7ff0ab3d2000-7ff0ab5d1000 ---p 0001f000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7ff0ab5d1000-7ff0ab5d2000 r--p 0001e000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7ff0ab5d2000-7ff0ab5d3000 rw-p 0001f000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7ff0ab5d3000-7ff0ab5d5000 rw-p 00000000 00:00 0
        7ff0ab5d5000-7ff0ab5ee000 r-xp 00000000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7ff0ab5ee000-7ff0ab7ed000 ---p 00019000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7ff0ab7ed000-7ff0ab7ee000 r--p 00018000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7ff0ab7ee000-7ff0ab7ef000 rw-p 00019000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7ff0ab7ef000-7ff0ab7f2000 r-xp 00000000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7ff0ab7f2000-7ff0ab9f1000 ---p 00003000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7ff0ab9f1000-7ff0ab9f2000 r--p 00002000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7ff0ab9f2000-7ff0ab9f3000 rw-p 00003000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7ff0ab9f3000-7ff0aba0b000 r-xp 00000000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7ff0aba0b000-7ff0abc0a000 ---p 00018000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7ff0abc0a000-7ff0abc0b000 r--p 00017000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7ff0abc0b000-7ff0abc0c000 rw-p 00018000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7ff0abc0c000-7ff0abc10000 rw-p 00000000 00:00 0
        7ff0abc10000-7ff0abc7e000 r-xp 00000000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7ff0abc7e000-7ff0abe7e000 ---p 0006e000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7ff0abe7e000-7ff0abe7f000 r--p 0006e000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7ff0abe7f000-7ff0abe80000 rw-p 0006f000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7ff0abe80000-7ff0ac040000 r-xp 00000000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7ff0ac040000-7ff0ac240000 ---p 001c0000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7ff0ac240000-7ff0ac244000 r--p 001c0000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7ff0ac244000-7ff0ac246000 rw-p 001c4000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7ff0ac246000-7ff0ac24a000 rw-p 00000000 00:00 0
        7ff0ac24a000-7ff0ac295000 r-xp 00000000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7ff0ac295000-7ff0ac495000 ---p 0004b000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7ff0ac495000-7ff0ac496000 r--p 0004b000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7ff0ac496000-7ff0ac497000 rw-p 0004c000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7ff0ac497000-7ff0ac4e9000 r-xp 00000000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7ff0ac4e9000-7ff0ac6e8000 ---p 00052000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7ff0ac6e8000-7ff0ac6e9000 r--p 00051000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7ff0ac6e9000-7ff0ac6ea000 rw-p 00052000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7ff0ac6ea000-7ff0ac86a000 r-xp 00000000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7ff0ac86a000-7ff0aca6a000 ---p 00180000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7ff0aca6a000-7ff0aca6e000 r--p 00180000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7ff0aca6e000-7ff0aca70000 rw-p 00184000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7ff0aca70000-7ff0aca72000 rw-p 00000000 00:00 0
        7ff0aca72000-7ff0acb81000 r-xp 00000000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7ff0acb81000-7ff0acd80000 ---p 0010f000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7ff0acd80000-7ff0acd81000 r--p 0010e000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7ff0acd81000-7ff0acd82000 rw-p 0010f000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7ff0acd82000-7ff0acd83000 rw-p 00000000 00:00 0
        7ff0acd83000-7ff0acda9000 r-xp 00000000 08:02 131089                     /lib/x86_64-linux-gnu/ld-2.23.so
        7ff0acf3d000-7ff0acf5c000 r--s 00000000 08:02 6298054                    /usr/share/mime/mime.cache
        7ff0acf5c000-7ff0acf6b000 rw-p 00000000 00:00 0
        7ff0acf7b000-7ff0acf7c000 rw-p 00000000 00:00 0
        7ff0acf7c000-7ff0acf83000 r--s 00000000 08:02 6033190                    /usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache
        7ff0acf83000-7ff0acfa8000 r--p 00000000 08:02 6301552                    /usr/share/locale-langpack/ja/LC_MESSAGES/libc.mo
        7ff0acfa8000-7ff0acfa9000 r--p 00025000 08:02 131089                     /lib/x86_64-linux-gnu/ld-2.23.so
        7ff0acfa9000-7ff0acfaa000 rw-p 00026000 08:02 131089                     /lib/x86_64-linux-gnu/ld-2.23.so
        7ff0acfaa000-7ff0acfab000 rw-p 00000000 00:00 0
        7ffe2caf1000-7ffe2cb12000 rw-p 00000000 00:00 0                          [stack]
        7ffe2cb1b000-7ffe2cb1d000 r--p 00000000 00:00 0                          [vvar]
        7ffe2cb1d000-7ffe2cb1f000 r-xp 00000000 00:00 0                          [vdso]
        ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
        done.
        Installing apt-transport-https... done.
        Installing /etc/apt/sources.list.d/datawireio_telepresence.list...done.
        Importing packagecloud gpg key... done.
        Running apt-get update... *** Error in `appstreamcli': double free or corruption (fasttop): 0x0000000001dc9190 ***
        ======= Backtrace: =========
        /lib/x86_64-linux-gnu/libc.so.6(+0x777e5)[0x7f91224037e5]
        /lib/x86_64-linux-gnu/libc.so.6(+0x8037a)[0x7f912240c37a]
        /lib/x86_64-linux-gnu/libc.so.6(cfree+0x4c)[0x7f912241053c]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_component_complete+0x439)[0x7f9122788d19]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_data_pool_update+0x44a)[0x7f9122789f0a]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_cache_builder_refresh+0x1c2)[0x7f912277f272]
        appstreamcli(ascli_refresh_cache+0x12e)[0x4049de]
        appstreamcli(as_client_run+0x6fb)[0x403ceb]
        /lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0xf0)[0x7f91223ac830]
        appstreamcli(_start+0x29)[0x403519]
        ======= Memory map: ========
        00400000-00408000 r-xp 00000000 08:02 5767218                            /usr/bin/appstreamcli
        00607000-00608000 r--p 00007000 08:02 5767218                            /usr/bin/appstreamcli
        00608000-00609000 rw-p 00008000 08:02 5767218                            /usr/bin/appstreamcli
        01293000-02ee4000 rw-p 00000000 00:00 0                                  [heap]
        7f9118000000-7f9118021000 rw-p 00000000 00:00 0
        7f9118021000-7f911c000000 ---p 00000000 00:00 0
        7f911d8e9000-7f911db7e000 r--p 00000000 08:02 5774055                    /usr/lib/locale/locale-archive
        7f911db7e000-7f911f434000 r-xp 00000000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f911f434000-7f911f633000 ---p 018b6000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f911f633000-7f911f634000 r--p 018b5000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f911f634000-7f911f635000 rw-p 018b6000 08:02 5767692                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f911f635000-7f911f639000 r-xp 00000000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f911f639000-7f911f838000 ---p 00004000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f911f838000-7f911f839000 r--p 00003000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f911f839000-7f911f83a000 rw-p 00004000 08:02 131289                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f911f83a000-7f911f942000 r-xp 00000000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f911f942000-7f911fb41000 ---p 00108000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f911fb41000-7f911fb42000 r--p 00107000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f911fb42000-7f911fb43000 rw-p 00108000 08:02 131077                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f911fb43000-7f911fb64000 r-xp 00000000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f911fb64000-7f911fd63000 ---p 00021000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f911fd63000-7f911fd64000 r--p 00020000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f911fd64000-7f911fd65000 rw-p 00021000 08:02 135660                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f911fd65000-7f911fee4000 r-xp 00000000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f911fee4000-7f91200e4000 ---p 0017f000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f91200e4000-7f91200f4000 r--p 0017f000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f91200f4000-7f91200f5000 rw-p 0018f000 08:02 5768178                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f91200f5000-7f91200f9000 rw-p 00000000 00:00 0
        7f91200f9000-7f91200fc000 r-xp 00000000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f91200fc000-7f91202fb000 ---p 00003000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f91202fb000-7f91202fc000 r--p 00002000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f91202fc000-7f91202fd000 rw-p 00003000 08:02 131157                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f91202fd000-7f9120313000 r-xp 00000000 08:02 135631                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7f9120313000-7f9120512000 ---p 00016000 08:02 135631                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7f9120512000-7f9120513000 rw-p 00015000 08:02 135631                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7f9120513000-7f9120685000 r-xp 00000000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f9120685000-7f9120885000 ---p 00172000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f9120885000-7f912088f000 r--p 00172000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f912088f000-7f9120891000 rw-p 0017c000 08:02 5767567                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f9120891000-7f9120895000 rw-p 00000000 00:00 0
        7f9120895000-7f91208c5000 r-xp 00000000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f91208c5000-7f9120ac4000 ---p 00030000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f9120ac4000-7f9120ac5000 r--p 0002f000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f9120ac5000-7f9120ac6000 rw-p 00030000 08:02 5776586                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f9120ac6000-7f9120cba000 r-xp 00000000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f9120cba000-7f9120eba000 ---p 001f4000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f9120eba000-7f9120ec1000 r--p 001f4000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f9120ec1000-7f9120ec2000 rw-p 001fb000 08:02 5776946                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f9120ec2000-7f9120edf000 r-xp 00000000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f9120edf000-7f91210df000 ---p 0001d000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f91210df000-7f91210e0000 r--p 0001d000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f91210e0000-7f91210e1000 rw-p 0001e000 08:02 5777000                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f91210e1000-7f9121292000 r-xp 00000000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f9121292000-7f9121491000 ---p 001b1000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f9121491000-7f9121499000 r--p 001b0000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f9121499000-7f912149b000 rw-p 001b8000 08:02 5768370                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f912149b000-7f912149c000 rw-p 00000000 00:00 0
        7f912149c000-7f91214a3000 r-xp 00000000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f91214a3000-7f91216a2000 ---p 00007000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f91216a2000-7f91216a3000 r--p 00006000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f91216a3000-7f91216a4000 rw-p 00007000 08:02 5775986                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f91216a4000-7f91216bb000 r-xp 00000000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f91216bb000-7f91218bb000 ---p 00017000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f91218bb000-7f91218bc000 r--p 00017000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f91218bc000-7f91218bd000 rw-p 00018000 08:02 131159                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f91218bd000-7f91218bf000 rw-p 00000000 00:00 0
        7f91218bf000-7f91218de000 r-xp 00000000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f91218de000-7f9121add000 ---p 0001f000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f9121add000-7f9121ade000 r--p 0001e000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f9121ade000-7f9121adf000 rw-p 0001f000 08:02 135751                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f9121adf000-7f9121ae1000 rw-p 00000000 00:00 0
        7f9121ae1000-7f9121afa000 r-xp 00000000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f9121afa000-7f9121cf9000 ---p 00019000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f9121cf9000-7f9121cfa000 r--p 00018000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f9121cfa000-7f9121cfb000 rw-p 00019000 08:02 131285                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f9121cfb000-7f9121cfe000 r-xp 00000000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f9121cfe000-7f9121efd000 ---p 00003000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f9121efd000-7f9121efe000 r--p 00002000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f9121efe000-7f9121eff000 rw-p 00003000 08:02 5767563                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f9121eff000-7f9121f17000 r-xp 00000000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f9121f17000-7f9122116000 ---p 00018000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f9122116000-7f9122117000 r--p 00017000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f9122117000-7f9122118000 rw-p 00018000 08:02 131097                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f9122118000-7f912211c000 rw-p 00000000 00:00 0
        7f912211c000-7f912218a000 r-xp 00000000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f912218a000-7f912238a000 ---p 0006e000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f912238a000-7f912238b000 r--p 0006e000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f912238b000-7f912238c000 rw-p 0006f000 08:02 135722                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f912238c000-7f912254c000 r-xp 00000000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f912254c000-7f912274c000 ---p 001c0000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f912274c000-7f9122750000 r--p 001c0000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f9122750000-7f9122752000 rw-p 001c4000 08:02 131155                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f9122752000-7f9122756000 rw-p 00000000 00:00 0
        7f9122756000-7f91227a1000 r-xp 00000000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f91227a1000-7f91229a1000 ---p 0004b000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f91229a1000-7f91229a2000 r--p 0004b000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f91229a2000-7f91229a3000 rw-p 0004c000 08:02 5775677                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f91229a3000-7f91229f5000 r-xp 00000000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f91229f5000-7f9122bf4000 ---p 00052000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f9122bf4000-7f9122bf5000 r--p 00051000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f9122bf5000-7f9122bf6000 rw-p 00052000 08:02 5767587                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f9122bf6000-7f9122d76000 r-xp 00000000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f9122d76000-7f9122f76000 ---p 00180000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f9122f76000-7f9122f7a000 r--p 00180000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f9122f7a000-7f9122f7c000 rw-p 00184000 08:02 5767608                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f9122f7c000-7f9122f7e000 rw-p 00000000 00:00 0
        7f9122f7e000-7f912308d000 r-xp 00000000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f912308d000-7f912328c000 ---p 0010f000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f912328c000-7f912328d000 r--p 0010e000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f912328d000-7f912328e000 rw-p 0010f000 08:02 135513                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f912328e000-7f912328f000 rw-p 00000000 00:00 0
        7f912328f000-7f91232b5000 r-xp 00000000 08:02 131089                     /lib/x86_64-linux-gnu/ld-2.23.so
        7f9123449000-7f9123468000 r--s 00000000 08:02 6298054                    /usr/share/mime/mime.cache
        7f9123468000-7f9123477000 rw-p 00000000 00:00 0
        7f9123487000-7f9123488000 rw-p 00000000 00:00 0
        7f9123488000-7f912348f000 r--s 00000000 08:02 6033190                    /usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache
        7f912348f000-7f91234b4000 r--p 00000000 08:02 6301552                    /usr/share/locale-langpack/ja/LC_MESSAGES/libc.mo
        7f91234b4000-7f91234b5000 r--p 00025000 08:02 131089                     /lib/x86_64-linux-gnu/ld-2.23.so
        7f91234b5000-7f91234b6000 rw-p 00026000 08:02 131089                     /lib/x86_64-linux-gnu/ld-2.23.so
        7f91234b6000-7f91234b7000 rw-p 00000000 00:00 0
        7ffdf9821000-7ffdf9842000 rw-p 00000000 00:00 0                          [stack]
        7ffdf98ee000-7ffdf98f0000 r--p 00000000 00:00 0                          [vvar]
        7ffdf98f0000-7ffdf98f2000 r-xp 00000000 00:00 0                          [vdso]
        ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
        done.

        The repository is setup! You can now install packages.
        ```

1. telepresenceのインストール【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo apt install --no-install-recommends telepresence
    ```

    - 実行結果（例）

        ```
        パッケージリストを読み込んでいます... 完了
        依存関係ツリーを作成しています
        状態情報を読み取っています... 完了
        以下のパッケージが自動でインストールされましたが、もう必要とされていません:
            cri-tools
        これを削除するには 'sudo apt autoremove' を利用してください。
        以下の追加パッケージがインストールされます:
            sshfs torsocks
        推奨パッケージ:
            tor
        以下のパッケージが新たにインストールされます:
            sshfs telepresence torsocks
        アップグレード: 0 個、新規インストール: 3 個、削除: 0 個、保留: 333 個。
        10.7 MB のアーカイブを取得する必要があります。
        この操作後に追加で 38.1 MB のディスク容量が消費されます。
        取得:1 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 sshfs amd64 2.5-1ubuntu1 [41.7 kB]
        取得:2 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 torsocks amd64 2.1.0-2 [56.2 kB]
        取得:3 https://packagecloud.io/datawireio/telepresence/ubuntu xenial/main amd64 telepresence amd64 0.95 [10.6 MB]
        10.7 MB を 2秒 で取得しました (3,767 kB/s)
        以前に未選択のパッケージ sshfs を選択しています。
        (データベースを読み込んでいます ... 現在 303452 個のファイルとディレクトリがインストールさ れています。)
        .../sshfs_2.5-1ubuntu1_amd64.deb を展開する準備をしています ...
        sshfs (2.5-1ubuntu1) を展開しています...
        以前に未選択のパッケージ torsocks を選択しています。
        .../torsocks_2.1.0-2_amd64.deb を展開する準備をしています ...
        torsocks (2.1.0-2) を展開しています...
        以前に未選択のパッケージ telepresence を選択しています。
        .../telepresence_0.95_amd64.deb を展開する準備をしています ...
        telepresence (0.95) を展開しています...
        man-db (2.7.5-1) のトリガを処理しています ...
        sshfs (2.5-1ubuntu1) を設定しています ...
        torsocks (2.1.0-2) を設定しています ...
        telepresence (0.95) を設定しています ...
        ```

1. ros-masterポートのforward設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl port-forward $(kubectl get pods -l app=ros-master -o template --template "{{(index .items 0).metadata.name}}") 11311:11311
    ```

    - 実行結果（例）

        ```
        Forwarding from 127.0.0.1:11311 -> 11311
        Forwarding from [::1]:11311 -> 11311
        ```

1. 別ターミナルをでtelepresence shellを実行【turtlebot3-pc】

1. ROSワークスペースに移動【turtlebot3-pc】

    ```
    turtlebot3-pc$ cd ~/catkin_ws
    ```

1. telepresenceシェルの起動【turtlebot3-pc】

    ```
    turtlebot3-pc$ telepresence --run-shell
    ```

    - 実行結果（例）

        ```
        T: Starting proxy with method 'vpn-tcp', which has the following limitations:
        T: All processes are affected, only one telepresence can run per machine, and
        T: you can't use other VPNs. You may need to add cloud hosts and headless
        T: services with --also-proxy. For a full list of method limitations see
        T: https://telepresence.io/reference/methods.html
        T: Volumes are rooted at $TELEPRESENCE_ROOT. See
        T: https://telepresence.io/howto/volumes.html for details.

        T: No traffic is being forwarded from the remote Deployment to your local
        T: machine. You can use the --expose option to specify which ports you want to
        T: forward.

        T: Guessing that Services IP range is 10.96.0.0/12. Services started after this
        T:  point will be inaccessible if are outside this range; restart telepresence
        T: if you can't access a new Service.
        ```

1. ROSワークスペースに移動【turtlebot3-pc】

    ```
    @minikube|bash-4.3$ cd ~/catkin_ws
    ```

1. keneticの環境設定【turtlebot3-pc】

    ```
    @minikube|bash-4.3$ source /opt/ros/kinetic/setup.bash 
    @minikube|bash-4.3$ source ./devel/setup.bash 
    ```

1. ROSの環境設定【turtlebot3-pc】

    ```
    @minikube|bash-4.3$ export ROS_MASTER_URI=http://localhost:11311
    @minikube|bash-4.3$ export ROS_HOSTNAME=172.17.0.1
    ```

1. turtlebot3パッケージをビルド【turtlebot3-pc】

    ```
    @minikube|bash-4.3$ catkin_make
    ```

    - 実行結果（例）

        ```
        Base path: /home/fiware/catkin_ws
        Source space: /home/fiware/catkin_ws/src
        Build space: /home/fiware/catkin_ws/build
        Devel space: /home/fiware/catkin_ws/devel
        Install space: /home/fiware/catkin_ws/install
        ####
        #### Running command: "make cmake_check_build_system" in "/home/fiware/catkin_ws/build"
        ####
        ####
        #### Running command: "make -j4 -l4" in "/home/fiware/catkin_ws/build"
        ####
        ```

1. Rviz上でturtlebot3のシミュレータを起動【turtlebot3-pc】

    ```
    @minikube|bash-4.3$ roslaunch turtlebot3_fake turtlebot3_fake.launch
    ```

    - 実行結果（例）

        ```
        ... logging to /home/fiware/.ros/log/053b87ca-4cf4-11e9-893a-b86b23c71f8e/roslaunch-turtlebot3-pc-30774.log
        Checking log directory for disk usage. This may take awhile.
        Press Ctrl-C to interrupt
        Done checking log file disk usage. Usage is <1GB.

        started roslaunch server http://172.17.0.1:41152/

        SUMMARY
        ========

        PARAMETERS
        * /robot_description: <?xml version="1....
        * /robot_state_publisher/publish_frequency: 50.0
        * /rosdistro: kinetic
        * /rosversion: 1.12.14
        * /tb3_model: waffle

        NODES
        /
            robot_state_publisher (robot_state_publisher/robot_state_publisher)
            rviz (rviz/rviz)
            turtlebot3_fake_node (turtlebot3_fake/turtlebot3_fake_node)

        ROS_MASTER_URI=http://localhost:11311

        process[turtlebot3_fake_node-1]: started with pid [30794]
        process[robot_state_publisher-2]: started with pid [30795]
        process[rviz-3]: started with pid [30808]
        [rviz-3] process has finished cleanly
        log file: /home/fiware/.ros/log/053b87ca-4cf4-11e9-893a-b86b23c71f8e/rviz-3*.log
        ^C[robot_state_publisher-2] killing on exit
        [turtlebot3_fake_node-1] killing on exit
        shutting down processing monitor...
        ... shutting down processing monitor complete
        done
        ```

## B.turtlebot3ロボットの設定

1. 環境変数の設定

    ```
    $ export TURTLEBOT3_WORKSPACE=/home/turtlebot3/catkin_ws
    ```

1. turtlebot3-bringupのビルド

    ```
    $ docker build -t ${REPOSITORY}/roboticbase/turtlebot3-bringup:0.2.0 ros/turtlebot3-bringup
    ```

1. Azure ACRのログイン

    ```
    $ az acr login --name ${ACR_NAME}
    ```

    - 実行結果（例）

        ```
        Login Succeeded
        WARNING! Your password will be stored unencrypted in /home/fiware/.docker/config.json.
        Configure a credential helper to remove this warning. See
        https://docs.docker.com/engine/reference/commandline/login/#credentials-store
        ```

1. turtlebot3-bringupのイメージ登録

    ```
    $ docker push ${REPOSITORY}/roboticbase/turtlebot3-bringup:0.2.0
    ```

1. turtlebot3-bringup-serviceの作成
   
    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py ${PJ_ROOT}/ros/turtlebot3-bringup/yaml/turtlebot3-bringup-service.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    ```

1. サービスの起動確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get services -l app=turtlebot3-bringup
    ```
    - 実行結果（例）

        ```
        NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
        turtlebot3-bringup   ClusterIP   None         <none>        11311/TCP   13s
        ```

1. turtlebot3-bringup-deployment-minikubeの作成

    ```
    $ envsubst < ${PJ_ROOT}/ros/turtlebot3-bringup/yaml/turtlebot3-bringup-deployment-acr.yaml > /tmp/turtlebot3-bringup-deployment-acr.yaml
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ docker run -it --rm -v ${PJ_ROOT}:${PJ_ROOT} -v /tmp:/tmp -w ${PJ_ROOT} example_turtlebot3:0.0.1 \
      ${PJ_ROOT}/tools/deploy_yaml.py /tmp/turtlebot3-bringup-deployment-acr.yaml https://api.${DOMAIN} ${TOKEN} ${FIWARE_SERVICE} ${DEPLOYER_SERVICEPATH} ${DEPLOYER_TYPE} ${DEPLOYER_ID}
    $ rm /tmp/turtlebot3-bringup-deployment-acr.yaml
    ```

1. turtlebot3-bringupのdeployments状態確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get deployments -l app=turtlebot3-bringup
    ```

    - 実行結果（例）

        ```
        NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
        turtlebot3-bringup   1/1     1            1           45s
        ```

1. turtlebot3-bringupのpods状態確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -l app=turtlebot3-bringup

    ```

    - 実行結果（例）

        ```
        NAME                                  READY     STATUS    RESTARTS   AGE
        turtlebot3-bringup-5c7b59c9b4-c56kj   1/1       Running   0          1m
        ```

1. ログの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl logs -f $(kubectl get pods -l app=turtlebot3-bringup -o template --template "{{(index .items 0).metadata.name}}")
    ```

## grafanaの確認
1. Turtlebot3のROS Nodeデプロイ状況のグラフ画面をリロードすると、ROS Node（turtlebot3-operator）のデプロイ状況が表示される

    ![grafana012](images/grafana/grafana012.png)

1. ブラウザを終了
