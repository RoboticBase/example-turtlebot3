# Turtlebot3 試験環境 インストールマニュアル #4


## 構築環境(2019年4月26日現在)
* turtlebot3-pc
    - Ubuntu 16.04.6 LTS
    - docker-ce  18.09.5
    - minikube v1.0.0
    - kubectl 1.14.1

# リモート環境の準備


## turtlebot3の準備 

turtlebot3シミュレータを利用する場合はAの手順、実機のturtlebot3ロボットを利用する場合はBの手順を実施します

### A.turtlebot3シミュレータ用PCの準備

1. Ubuntu 16.04を用意

    ※今後、turtlebot3シミュレータ用PCで実行する場合には【turtlebot3-pc】と記載します。
    また【turtlebot3-pc】が記載されていない場合にはcore構築環境で実施します。

    VirtualBoxを利用する場合は下記を設定

    + 3D表示設定を無効化

    virtaulboxの設定画面で設定したい仮想マシンを選択し「ディスプレイ」「3Dアクセラレーションを無効化」のチェックを外す

    ![virtaulbox001](images/virtaulbox/virtualbox001.png)

    + .bashrcに環境変数の設定(VirtualBox側)

        ```
        $ vi .bashrc
        set export LIBGL_ALWAYS_SOFTWARE=1

        $ source .bashrc
        ```
  
1. .bashrcに下記を設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ vi .bashrc
    ```

    ```bash
    export TURTLEBOT3_MODEL=waffle
    ```

    ```
    turtlebot3-pc$ source .bashrc
    ```

1. ros-kinetic-desktop-fullとros-kinetic-rqt-*のインストール【turtlebot3-pc】

    以下のリンク先の1.1～1.8まで実施 (1.4実施時、下記のros-kinetic-rqt-*をインストール)

    [Ubuntu install of ROS Kinetic]  
    http://wiki.ros.org/kinetic/Installation/Ubuntu

    ```
    turtlebot3-pc$ sudo apt-get -y install "ros-kinetic-rqt-*"
    ```

1. ROSワークスペースの作成【turtlebot3-pc】

    1. 下記のリンク先をすべて実施  
        [Installing and Configuring Your ROS Environment]  
        http://wiki.ros.org/ROS/Tutorials/InstallingandConfiguringROSEnvironment

    1. srcディレクトリを作成【turtlebot3-pc】

        ```
        turtlebot3-pc$ mkdir ~/catkin_ws
        turtlebot3-pc$ mkdir ~/catkin_ws/src
        ```

1. turtlebot3 simulatorのリポジトリを取得【turtlebot3-pc】

    1. gitのインストール【turtlebot3-pc】

        ```
        turtlebot3-pc$ sudo apt-get install -y git
        ```

    1. gitのインストール確認【turtlebot3-pc】

        ```
        turtlebot3-pc$ dpkg -l | grep git
        ```

        - 実行結果（例）

            ```
            ii  git                                        1:2.7.4-0ubuntu1.6                                  amd64        fast, scalable, distributed revision control system
            ```

    1. turtlebot3の取得【turtlebot3-pc】

        ```
        turtlebot3-pc$ cd catkin_ws/src
        turtlebot3-pc$ git clone https://github.com/ROBOTIS-GIT/turtlebot3.git
        turtlebot3-pc$ git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
        turtlebot3-pc$ git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
        ```

1. catkin_makeを利用してリポジトリを作成【turtlebot3-pc】

    ```
    turtlebot3-pc$ cd ~/catkin_ws/src
    turtlebot3-pc$ catkin_make
    ```

### B.turtlebot3ロボットの準備

1. turtlebot3を準備

    ※今後、turtlebot3ロボットに搭載されているPCで実行する場合には【turtlebot3-pc】と記載します。
    また【turtlebot3-pc】が記載されていない場合にはcore構築環境で実施します。

1. catkin_makeを利用してリポジトリを作成【turtlebot3-pc】

    ```
    turtlebot3-pc$ catkin_make
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

1. 環境ファイルの実行

    ```
    $ source $CORE_ROOT/docs/environments/minikube/env
    $ source $PJ_ROOT/docs/environments/minikube/env
    ```

## minikubeが動作しているPCのLAN向けIP addressの取得
1. minikubeが動作しているPCがLANに接続しているInterfaceの名前を確認

    ```
    $ export LANG=C
    $ ifconfig 
    ```

1. 確認したInterface名を環境変数 `IFNAME` に設定

    ※ Interface名が `en0` だった場合

    ```
    $ export IFNAME="en0"
    ```

1. minikubeのLAN向けipを設定
    * macOS

        ```
        $ export EXTERNAL_HOST_IPADDR=$(ifconfig ${IFNAME} | awk '/inet / {print $2}');echo ${EXTERNAL_HOST_IPADDR}
        ```
    * Ubuntu
        ```
        $ export EXTERNAL_HOST_IPADDR=$(ifconfig ${IFNAME} | awk '/inet / {print $2}' | cut -d: -f2);echo ${EXTERNAL_HOST_IPADDR}
        ```

    - 実行結果（例）

        ```
        172.16.10.25
        ```

## turtlebot3-pcの設定【turtlebot3-pc】

### dockerの設定【turtlebot3-pc】

1. dockerに必要なパッケージをインストール

    ```
    turtlebot3-pc$ sudo apt update
    turtlebot3-pc$ sudo apt upgrade -y
    turtlebot3-pc$ sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    ```

1. docker-ceリポジトリの公開鍵を登録【turtlebot3-pc】

    ```
    turtlebot3-pc$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    ```

1. docker-ceリポジトリを登録【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    ```

1. dockerのインストール【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo apt update
    turtlebot3-pc$ sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    ```

1. インストール確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo docker run hello-world
    ```

    - 実行結果（例）

        ```
        Unable to find image 'hello-world:latest' locally
        latest: Pulling from library/hello-world
        1b930d010525: Pull complete 
        Digest: sha256:2557e3c07ed1e38f26e389462d03ed943586f744621577a99efb77324b0fe535
        Status: Downloaded newer image for hello-world:latest

        Hello from Docker!
        This message shows that your installation appears to be working correctly.

        To generate this message, Docker took the following steps:
        1. The Docker client contacted the Docker daemon.
        2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            (amd64)
        3. The Docker daemon created a new container from that image which runs the
            executable that produces the output you are currently reading.
        4. The Docker daemon streamed that output to the Docker client, which sent it
            to your terminal.

        To try something more ambitious, you can run an Ubuntu container with:
        $ docker run -it ubuntu bash

        Share images, automate workflows, and more with a free Docker ID:
        https://hub.docker.com/

        For more examples and ideas, visit:
        https://docs.docker.com/get-started/
        ```

1. insecureレジストリの追加コマンド作成

    ```
    $ echo "sudo mkdir -p /etc/systemd/system/docker.service.d/; cat << __EOS__ | sudo tee /etc/systemd/system/docker.service.d/override.conf
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd -H fd:// --insecure-registry=${EXTERNAL_HOST_IPADDR}:5000
    __EOS__"
    ```

    - 実行結果（例）

        ```
        sudo mkdir -p /etc/systemd/system/docker.service.d/; cat << __EOS__ | sudo tee /etc/systemd/system/docker.service.d/override.conf
        [Service]
        ExecStart=
        ExecStart=/usr/bin/dockerd -H fd:// --insecure-registry=172.16.10.25:5000
        __EOS__
        ```

1. incecureレジストリの追加【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo mkdir -p /etc/systemd/system/docker.service.d/; cat << __EOS__ | sudo tee /etc/systemd/system/docker.service.d/override.conf
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd -H fd:// --insecure-registry=172.16.10.25:5000
    __EOS__
    ```

    - 実行結果(例）

        ```
        [Service]
        ExecStart=
        ExecStart=/usr/bin/dockerd -H fd:// --insecure-registry=172.16.10.25:5000
        ```

1. docker daemonを再起動【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo systemctl daemon-reload
    ```

1. dockerサービスの再起動【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo systemctl restart docker.service
    ```

1. dockerサービスの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo systemctl status docker.service

    ```

    - 実行結果(例）

        ```
        * docker.service - Docker Application Container Engine
        Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
        Drop-In: /etc/systemd/system/docker.service.d
                `-override.conf
        Active: active (running) since Thu 2019-03-14 11:53:00 JST; 10s ago
            Docs: https://docs.docker.com
        Main PID: 20660 (dockerd)
            Tasks: 21
        Memory: 47.8M
            CPU: 368ms
        CGroup: /system.slice/docker.service
                |-20660 /usr/bin/dockerd -H fd:// --insecure-registry=172.16.10.25:5000
                `-20669 docker-containerd --config /var/run/docker/containerd/containerd.toml

        Mar 14 11:52:59 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:52:59.694038130+09:00" level=i
        Mar 14 11:52:59 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:52:59.694617844+09:00" level=i
        Mar 14 11:52:59 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:52:59.694655449+09:00" level=i
        Mar 14 11:53:00 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:53:00.439039288+09:00" level=i
        Mar 14 11:53:00 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:53:00.719403379+09:00" level=i
        Mar 14 11:53:00 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:53:00.745598826+09:00" level=w
        Mar 14 11:53:00 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:53:00.756618957+09:00" level=i
        Mar 14 11:53:00 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:53:00.756716942+09:00" level=i
        Mar 14 11:53:00 turtlebot3-pc systemd[1]: Started Docker Application Container Engine.
        Mar 14 11:53:00 turtlebot3-pc dockerd[20660]: time="2019-03-14T11:53:00.813853015+09:00" level=i
        ```

## minikubeの設定【turtlebot3-pc】

1. minikubeのインストール【turtlebot3-pc】

    ```
    turtlebot3-pc$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.0.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
    ```

    - 実行結果(例）

        ```
            % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        100 38.2M  100 38.2M    0     0  9358k      0  0:00:04  0:00:04 --:--:-- 9361k
        ```


1. minikubeのバージョン確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ minikube version
    ```

    - 実行結果(例）

        ```
        minikube version: v1.0.0
        ```


## kubectlの設定【turtlebot3-pc】

1. kubectlのインストール【turtlebot3-pc】

    ```
    turtlebot3-pc$ curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.1/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl
    ```

    - 実行結果（例）

        ```
            % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        100 37.4M  100 37.4M    0     0  9949k      0  0:00:03  0:00:03 --:--:-- 9948k
        ```

1. kubectlのバージョン確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl version --client
    ```

    - 実行結果（例）

        ```
        Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.1", GitCommit:"b7394102d6ef778017f2ca4046abbaa23b88c290", GitTreeState:"clean", BuildDate:"2019-04-08T17:11:31Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"linux/amd64"}
        ```


# 仮想化なしでminikubeを起動【turtlebot3-pc】

## リポジトリ登録コマンドの作成【turtlebot3-pc】

1. リポジトリ登録コマンドの作成【turtlebot3-pc】
    * macOS

        ```
        turtlebot3-pc$ NWNAME=$(VBoxManage showvminfo ${MINIKUBE_NAME} | grep "Host-only Interface" | awk 'match($0, /vboxnet[0-9]+/){print substr($0,RSTART,RLENGTH)}')
        turtlebot3-pc$ HOST_IPADDR=$(ifconfig ${NWNAME} | awk '/inet / {print $2}')
        turtlebot3-pc$ NETMASK_HEX=$(ifconfig ${NWNAME} | awk '/netmask / {print $4}')
        turtlebot3-pc$ NETMASK=$(echo "${NETMASK_HEX:2}" | perl -pe '$_ = unpack("B32", pack("H*", $_)); s/0+$//g; $_ = length')
        turtlebot3-pc$ echo 'cat ${HOME}/.minikube/machines/minikube/config.json | perl -pse '"'"'s/"InsecureRegistry": \[/"InsecureRegistry": [\n                "$h\/$m",/g;'"' -- -h=${EXTERNAL_HOST_IPADDR} -m=${NETMASK}"' > /tmp/config.json;mv /tmp/config.json ${HOME}/.minikube/machines/minikube/config.json'
        ```
    * Ubuntu

        ```
        turtlebot3-pc$ NWNAME=$(VBoxManage showvminfo ${MINIKUBE_NAME} | grep "Host-only Interface" | awk 'match($0, /vboxnet[0-9]+/){print substr($0,RSTART,RLENGTH)}')
        turtlebot3-pc$ HOST_IPADDR=$(ifconfig ${NWNAME}  | awk '/inet / {print $2}' | cut -d: -f2)
        turtlebot3-pc$ NETMASK_IP=$(ifconfig ${NWNAME} | awk '/Mask/ {print $4}' | cut -d: -f2)
        turtlebot3-pc$ NETMASK=$(ipcalc ${HOST_IPADDR} ${NETMASK_IP} | awk '/Netmask: / {print $4}')
        echo 'cat ${HOME}/.minikube/machines/minikube/config.json | perl -pse '"'"'s/"InsecureRegistry": \[/"InsecureRegistry": [\n                "$h\/$m",/g;'"' -- -h=${EXTERNAL_HOST_IPADDR} -m=${NETMASK}"' > /tmp/config.json;mv /tmp/config.json ${HOME}/.minikube/machines/minikube/config.json'
        ```

    - 実行結果(例）

        ```
        cat ${HOME}/.minikube/machines/minikube/config.json | perl -pse 's/"InsecureRegistry": \[/"InsecureRegistry": [\n                "$h\/$m",/g;' -- -h=172.16.10.25 -m=24 > /tmp/config.json;mv /tmp/config.json ${HOME}/.minikube/machines/minikube/config.json
        ```


## minikubeの起動【turtlebot3-pc】

### minikubeが既に起動している場合、minikubeの環境ファイルを削除
### minikubeが起動していない場合は、3..kube/configの作成から実施

1. minikubeの停止【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo minikube stop
    ```

    - 実行結果(例）

        ```
        :   Stopping "minikube" in none ...
        :   Stopping "minikube" in none ...
        -   "minikube" stopped.
        ```

1. minikubeの環境の削除【turtlebot3-pc】
    　
   ```
   turtlebot3-pc$ sudo minikube delete
   ```

    - 実行結果(例）

        ```
        #   Uninstalling Kubernetes v1.13.5 using kubeadm ...
        x   Deleting "minikube" from none ...
        -   The "minikube" cluster has been deleted.
        ```

   ```
   turtlebot3-pc$ sudo rm -rf /etc/kubernetes/
   turtlebot3-pc$ sudo rm -rf $HOME/.minikube/
   turtlebot3-pc$ rm -rf $HOME/.kube/
   ```

1. 環境変数の設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ export MINIKUBE_WANTUPDATENOTIFICATION=false
    turtlebot3-pc$ export MINIKUBE_WANTREPORTERRORPROMPT=false
    turtlebot3-pc$ export MINIKUBE_HOME=$HOME
    turtlebot3-pc$ export CHANGE_MINIKUBE_NONE_USER=true
    turtlebot3-pc$ export KUBECONFIG=$HOME/.kube/config
    ```

    ```
    turtlebot3-pc$ export CPU_CORE_NUM="1"
    turtlebot3-pc$ export MEMORY_MB=2048
    turtlebot3-pc$ export K8S_VERSION="v1.13.5"
    ```

1. .kube/configの作成【turtlebot3-pc】

    ```
    turtlebot3-pc$ mkdir -p $HOME/.kube $HOME/.minikube
    turtlebot3-pc$ touch $KUBECONFIG
    ```

1. minikubeの起動【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo -E minikube start --cpus ${CPU_CORE_NUM} --memory ${MEMORY_MB} --vm-driver=none --kubernetes-version ${K8S_VERSION} --feature-gates=CoreDNS=false
    ```

    - 実行結果（例）

        ```
        o   minikube v1.0.0 on linux (amd64)
        $   Downloading Kubernetes v1.13.5 images in the background ...
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        >   Creating none VM (CPUs=1, Memory=2048MB, Disk=20000MB) ...
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        2019/04/25 21:40:30 No matching credentials were found, falling back on anonymous
        -   "minikube" IP address is 192.168.0.8
        -   Configuring Docker as the container runtime ...
        -   Version of container runtime is 18.09.5
        :   Waiting for image downloads to complete ...
        E0425 21:41:04.778588   18711 start.go:209] Error caching images:  Caching images for kubeadm: caching images: caching image /home/turtlebot3/.minikube/cache/images/k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64_1.14.8: Get https://storage.googleapis.com/asia.artifacts.google-containers.appspot.com/containers/images/sha256:c2ce1ffb51ed60c54057f53b8756231f5b4b792ce04113c6755339a1beb25943: dial tcp: lookup storage.googleapis.com on 127.0.1.1:53: read udp 127.0.0.1:39465->127.0.1.1:53: i/o timeout
        -   Preparing Kubernetes environment ...
        X   Unable to load cached images: loading cached images: loading image /home/turtlebot3/.minikube/cache/images/k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64_1.14.8: stat /home/turtlebot3/.minikube/cache/images/k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64_1.14.8: no such file or directory
        @   Downloading kubeadm v1.13.5
        @   Downloading kubelet v1.13.5
        -   Pulling images required by Kubernetes v1.13.5 ...
        -   Launching Kubernetes v1.13.5 using kubeadm ... 
        :   Waiting for pods: apiserver proxy etcd scheduler controller dns
        -   Configuring cluster permissions ...
        -   Verifying component health .....
        >   Configuring local host environment ...

        !   The 'none' driver provides limited isolation and may reduce system security and reliability.
        !   For more information, see:
        -   https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md

        +   kubectl is now configured to use "minikube"
        =   Done! Thank you for using minikube!
        ```

1. リポジトリ登録コマンド作成で作成したコマンドを実行【turtlebot3-pc】

    ```
    turtlebot3-pc$ cat ${HOME}/.minikube/machines/minikube/config.json | perl -pse 's/"InsecureRegistry": \[/"InsecureRegistry": [\n                "$h\/$m",/g;' -- -h=172.16.10.25 -m=24 > /tmp/config.json;mv /tmp/config.json ${HOME}/.minikube/machines/minikube/config.json
    ```

1. minikubeの停止【turtlebot3-pc】

    ```
    turtlebot3-pc$ minikube stop
    ```

    - 実行結果(例）

        ```
        :   Stopping "minikube" in none ...
        :   Stopping "minikube" in none ...
        -   "minikube" stopped.
        ```

1. minikubeの起動【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo -E minikube start --cpus ${CPU_CORE_NUM} --memory ${MEMORY_MB} --vm-driver=none --kubernetes-version ${K8S_VERSION} --feature-gates=CoreDNS=false
    ```

    - 実行結果(例）

        ```
        o   minikube v1.0.0 on linux (amd64)
        $   Downloading Kubernetes v1.13.5 images in the background ...
        i   Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
        2019/04/27 15:25:38 No matching credentials were found, falling back on anonymous
        :   Restarting existing none VM for "minikube" ...
        :   Waiting for SSH access ...
        -   "minikube" IP address is 192.168.0.8
        -   Configuring Docker as the container runtime ...
        -   Version of container runtime is 18.09.5
        :   Waiting for image downloads to complete ...
        -   Preparing Kubernetes environment ...
        -   Pulling images required by Kubernetes v1.13.5 ...
        :   Relaunching Kubernetes v1.13.5 using kubeadm ... 
        :   Waiting for pods: apiserver proxy etcd scheduler controller dns
        :   Updating kube-proxy configuration ...
        -   Verifying component health .....
        >   Configuring local host environment ...

        !   The 'none' driver provides limited isolation and may reduce system security and reliability.
        !   For more information, see:
        -   https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md

        +   kubectl is now configured to use "minikube"
        =   Done! Thank you for using minikube!
        ```

1. kubernetesのバージョン確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl version
    ```

    - 実行結果(例）

        ```
        Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.1", GitCommit:"b7394102d6ef778017f2ca4046abbaa23b88c290", GitTreeState:"clean", BuildDate:"2019-04-08T17:11:31Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"linux/amd64"}
        Server Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.5", GitCommit:"2166946f41b36dea2c4626f90a77706f426cdea2", GitTreeState:"clean", BuildDate:"2019-03-25T15:19:22Z", GoVersion:"go1.11.5", Compiler:"gc", Platform:"linux/amd64"}
        ```

1. minikubeのnode確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get nodes
    ```

    - 実行結果(例）

        ```
        NAME       STATUS   ROLES    AGE     VERSION
        minikube   Ready    master   6m24s   v1.13.5
        ```

1. 全podが起動していることを確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods --all-namespaces
    ```

    - 実行結果(例）

        ```
        NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
        kube-system   etcd-minikube                      1/1     Running   1          5m36s
        kube-system   kube-addon-manager-minikube        1/1     Running   1          5m41s
        kube-system   kube-apiserver-minikube            1/1     Running   1          5m39s
        kube-system   kube-controller-manager-minikube   1/1     Running   1          5m53s
        kube-system   kube-dns-86b8794d97-4z6n5          3/3     Running   3          6m34s
        kube-system   kube-proxy-dd6hv                   1/1     Running   0          2m37s
        kube-system   kube-scheduler-minikube            1/1     Running   1          5m34s
        kube-system   storage-provisioner                1/1     Running   1          6m32s
        ```


## minikubeのDNS設定確認【turtlebot3-pc】

1. 名前解決ができるかの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl run -it --rm --restart=Never dig --image tutum/dnsutils -- dig www.google.com
    ```

    - 実行結果(例）

        ```
        If you don't see a command prompt, try pressing enter.
        
        ; <<>> DiG 9.9.5-3ubuntu0.2-Ubuntu <<>> www.google.com
        ;; global options: +cmd
        ;; connection timed out; no servers could be reached
        pod "dig" deleted
        pod default/dig terminated (Error)
        ```

    上記の様なエラーが出力された場合は「ネームサーバをkube-dnsに設定」を実施


## ネームサーバをkube-dnsに設定【turtlebot3-pc】

1. `/tmp/kube-dns-configmap.yaml` を作成

    ```
    $ cat << __EOF__ > /tmp/kube-dns-configmap.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: kube-dns
      namespace: kube-system
      labels:
        addonmanager.kubernetes.io/mode: EnsureExists
    data:
      upstreamNameservers: |-
        ["8.8.8.8", "8.8.4.4"]
    __EOF__
    ```

1. kube-dns-confimapの作成【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl apply -f /tmp/kube-dns-configmap.yaml
    ```

    - 実行結果(例）

    ```
    configmap/kube-dns created
    ```

1. kube-dnsのpod削除(自動的にkube-dns再起動)【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl delete pod -n kube-system $(kubectl get pods -n kube-system -l k8s-app=kube-dns -o template --template "{{(index .items 0).metadata.name}}")
    ```

    - 実行結果(例）

        ```
        pod "kube-dns-86f4d74b45-82gcl" deleted
        ```

1. kube-dnsの起動確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods -n kube-system -l k8s-app=kube-dns
    ```

    - 実行結果(例）

        ```
        NAME                        READY   STATUS    RESTARTS   AGE
        kube-dns-86f4d74b45-wpk5r   3/3     Running   0          1m
        ```

1. 名前解決ができることを確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl run -it --rm --restart=Never dig --image tutum/dnsutils -- dig www.google.com
    ```

    - 実行結果(例）

        ```
        ; <<>> DiG 9.9.5-3ubuntu0.2-Ubuntu <<>> www.google.com
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18811
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 6, AUTHORITY: 0, ADDITIONAL: 1

        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 512
        ;; QUESTION SECTION:
        ;www.google.com.			IN	A

        ;; ANSWER SECTION:
        www.google.com.		166	IN	A	64.233.177.106
        www.google.com.		166	IN	A	64.233.177.105
        www.google.com.		166	IN	A	64.233.177.99
        www.google.com.		166	IN	A	64.233.177.104
        www.google.com.		166	IN	A	64.233.177.147
        www.google.com.		166	IN	A	64.233.177.103

        ;; Query time: 7 msec
        ;; SERVER: 10.96.0.10#53(10.96.0.10)
        ;; WHEN: Thu Mar 18 02:54:48 UTC 2019
        ;; MSG SIZE  rcvd: 139

        pod "dig" deleted
        ```


## deployer serviceの登録

1. deployer serviceの登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${DEPLOYER_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/services/ -X POST -d @- <<__EOS__
    {
      "services": [
        {
          "apikey": "${DEPLOYER_TYPE}",
          "cbroker": "http://orion:1026",
          "resource": "/iot/d",
          "entity_type": "${DEPLOYER_TYPE}"
        }
      ]
    }
    __EOS__
   ```

    - 実行結果(例）

        ```json
        {}
        ```

## 登録されているservice確認

1. deployer serviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/services/ | jq .
    ```

    - 実行結果(例）

        ```json
        {
          "count": 1,
          "services": [
            {
              "commands": [],
              "lazy": [],
              "attributes": [],
              "_id": "5cc1ad34b3d72f000f4f4c8f",
              "resource": "/iot/d",
              "apikey": "deployer",
              "service": "fiwaredemo",
              "subservice": "/deployer",
              "__v": 0,
              "static_attributes": [],
              "internal_attributes": [],
              "entity_type": "deployer"
            }
          ]
        }
        ```

## deployer deviceの登録

1. idas側でdeployer deviceの登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${DEPLOYER_SERVICEPATH}" -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/devices/ -X POST -d @- <<__EOS__
    {
      "devices": [
        {
          "device_id": "${DEPLOYER_ID}",
          "entity_name": "${DEPLOYER_ID}",
          "entity_type": "${DEPLOYER_TYPE}",
          "timezone": "Asia/Tokyo",
          "protocol": "UL20",
          "attributes": [
            {
              "name": "deployment",
              "type": "string"
            },
            {
              "name": "label",
              "type": "string"
            },
            {
              "name": "desired",
              "type": "integer"
            },
            {
              "name": "current",
              "type": "integer"
            },
            {
              "name": "updated",
              "type": "integer"
            },
            {
              "name": "ready",
              "type": "integer"
            },
            {
              "name": "unavailable",
              "type": "integer"
            },
            {
              "name": "available",
              "type": "integer"
            }
          ],
          "commands": [
            {
              "name": "apply",
              "type": "string"
            }, {
              "name": "delete",
              "type": "string"
            }
          ],
          "transport": "AMQP"
        }
      ]
    }
    __EOS__
    ```

    - 実行結果(例）

        ```json
        {}
        ```

1. idas側でdeployer deviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/devices/${DEPLOYER_ID}/ | jq .
    ```

    - 実行結果(例）

        ```json
        {
          "device_id": "deployer_01",
          "service": "fiwaredemo",
          "service_path": "/deployer",
          "entity_name": "deployer_01",
          "entity_type": "deployer",
          "transport": "AMQP",
          "attributes": [
            {
              "object_id": "deployment",
              "name": "deployment",
              "type": "string"
            },
            {
              "object_id": "label",
              "name": "label",
              "type": "string"
            },
            {
              "object_id": "desired",
              "name": "desired",
              "type": "integer"
            },
            {
              "object_id": "current",
              "name": "current",
              "type": "integer"
            },
            {
              "object_id": "updated",
              "name": "updated",
              "type": "integer"
            },
            {
              "object_id": "ready",
              "name": "ready",
              "type": "integer"
            },
            {
              "object_id": "unavailable",
              "name": "unavailable",
              "type": "integer"
            },
            {
              "object_id": "available",
              "name": "available",
              "type": "integer"
            }
          ],
          "lazy": [],
          "commands": [
            {
              "object_id": "apply",
              "name": "apply",
              "type": "string"
            },
            {
              "object_id": "delete",
              "name": "delete",
              "type": "string"
            }
          ],
          "static_attributes": [],
          "protocol": "UL20"
        }
        ```

1. orion側でdeployer deviceの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${DEPLOYER_ID}/ | jq .
    ```

    - 実行結果(例）

        ```json
        {
          "id": "deployer_01",
          "type": "deployer",
          "TimeInstant": {
            "type": "ISO8601",
            "value": " ",
            "metadata": {}
          },
          "apply_info": {
            "type": "commandResult",
            "value": " ",
            "metadata": {}
          },
          "apply_status": {
            "type": "commandStatus",
            "value": "UNKNOWN",
            "metadata": {}
          },
          "available": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "current": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "delete_info": {
            "type": "commandResult",
            "value": " ",
            "metadata": {}
          },
          "delete_status": {
            "type": "commandStatus",
            "value": "UNKNOWN",
            "metadata": {}
          },
          "deployment": {
            "type": "string",
            "value": " ",
            "metadata": {}
          },
          "desired": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "label": {
            "type": "string",
            "value": " ",
            "metadata": {}
          },
          "ready": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "unavailable": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "updated": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "apply": {
            "type": "string",
            "value": "",
            "metadata": {}
          },
          "delete": {
            "type": "string",
            "value": "",
            "metadata": {}
          }
        }
        ```


## deployerをTurtlebot3に設定

1. ユーザ名とパスワードを登録するコマンドを生成

    ```
    $ echo "kubectl create secret generic mqtt-username-password --from-literal=mqtt_username=ros --from-literal=mqtt_password=${MQTT__ros}"
    ```

    - 実行結果(例）

        ```
        kubectl create secret generic mqtt-username-password --from-literal=mqtt_username=ros --from-literal=mqtt_password=password_of_ros
        ```

1. ユーザ名とパスワードの設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl create secret generic mqtt-username-password --from-literal=mqtt_username=ros --from-literal=mqtt_password=password_of_ros
    ```

    - 実行結果(例）

        ```
        secret/mqtt-username-password created
        ```

1. MQTTエンドポイントのConfigmapを登録するコマンドを生成

    ```
    $ echo "kubectl create configmap mqtt-config --from-literal=mqtt_use_tls=false --from-literal=mqtt_host=${EXTERNAL_HOST_IPADDR} --from-literal=mqtt_port=1883 --from-literal=device_type=${DEPLOYER_TYPE} --from-literal=device_id=${DEPLOYER_ID}"
    ```

    - 実行結果(例）

        ```
        kubectl create configmap mqtt-config --from-literal=mqtt_use_tls=false --from-literal=mqtt_host=192.168.0.3 --from-literal=mqtt_port=1883 --from-literal=device_type=deployer --from-literal=device_id=deployer_01
        ```

1. MQTTエンドポイントのConfigmapの設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl create configmap mqtt-config --from-literal=mqtt_use_tls=false --from-literal=mqtt_host=192.168.0.3 --from-literal=mqtt_port=1883 --from-literal=device_type=deployer --from-literal=device_id=deployer_01
    ```

    - 実行結果(例）

        ```
        configmap/mqtt-config created
        ```


## MQTT通信でリソースを操作するdeployerの起動【turtlebot3-pc】

1. `/tmp/mqtt-kube-operator.yaml` を作成

    ```
    $ cat << __EOF__ > /tmp/mqtt-kube-operator.yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: mqtt-kube-operator
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: mqtt-kube-operator
      namespace: default
    rules:
    - apiGroups: [""]
      resources: ["services", "configmaps", "secrets"]
      verbs: ["get", "list", "create", "update", "delete"]
    - apiGroups: ["apps"]
      resources: ["deployments"]
      verbs: ["get", "list", "create", "update", "delete"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: mqtt-kube-operator
      namespace: default
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: mqtt-kube-operator
    subjects:
    - kind: ServiceAccount
      name: mqtt-kube-operator
      namespace: default
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: mqtt-kube-operator
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: mqtt-kube-operator
      template:
        metadata:
          labels:
            app: mqtt-kube-operator
        spec:
          serviceAccountName: mqtt-kube-operator
          containers:
          - name: mqtt-kube-operator
            image: roboticbase/mqtt-kube-operator:0.2.0
            imagePullPolicy: Always
            env:
            - name: LOG_LEVEL
              value: "info"
            - name: MQTT_USERNAME
              valueFrom:
                secretKeyRef:
                  name: mqtt-username-password
                  key: mqtt_username
            - name: MQTT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mqtt-username-password
                  key: mqtt_password
            - name: MQTT_USE_TLS
              valueFrom:
                configMapKeyRef:
                  name: mqtt-config
                  key: mqtt_use_tls
            - name: MQTT_HOST
              valueFrom:
                configMapKeyRef:
                  name: mqtt-config
                  key: mqtt_host
            - name: MQTT_PORT
              valueFrom:
                configMapKeyRef:
                  name: mqtt-config
                  key: mqtt_port
            - name: DEVICE_TYPE
              valueFrom:
                configMapKeyRef:
                  name: mqtt-config
                  key: device_type
            - name: DEVICE_ID
              valueFrom:
                configMapKeyRef:
                  name: mqtt-config
                  key: device_id
            - name: REPORT_INTERVAL_SEC
              value: "1"
            - name: USE_DEPLOYMENT_STATE_REPORTER
              value: "true"
            - name: REPORT_TARGET_LABEL_KEY
              value: "report"
    __EOF__
    ```

1. mqtt-kube-operatorの作成【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl apply -f /tmp/mqtt-kube-operator.yaml
    ```

    - 実行結果(例）

        ```
        serviceaccount/mqtt-kube-operator created
        role.rbac.authorization.k8s.io/mqtt-kube-operator created
        rolebinding.rbac.authorization.k8s.io/mqtt-kube-operator created
        deployment.apps/mqtt-kube-operator created    
        ```

1. mqtt-kube-operatorの接続確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl logs -f $(kubectl get pods -l app=mqtt-kube-operator -o template --template "{{(index .items 0).metadata.name}}")
    ```

    - 実行結果(例）

        ```
        2019-04-25T13:39:02.908Z	INFO	mqtt-kube-operator/main.go:183	start main
        2019-04-25T13:39:03.066Z	INFO	mqtt-kube-operator/main.go:163	Connected to MQTT Broker(tcp://172.16.10.25:1883), start loop
        ```


## applyコマンドでdeployerの確認

1. applyを指示するコマンドの作成

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ echo -e "curl -i -H \"Authorization: bearer ${TOKEN}\" -H \"Fiware-Service: ${FIWARE_SERVICE}\" -H \"Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}\" -H \"Content-Type: application/json\" http://${HOST_IPADDR}:8080/orion/v2/entities/${DEPLOYER_ID}/attrs?type=${DEPLOYER_TYPE} -X PATCH -d @-<<__EOS__
    {
      \"apply\": {
        \"value\": \"{}\"
      }
    }
    __EOS__"
    ```

    - 実行結果(例）

        ```
        curl -i -H "Authorization: bearer nPxrJvT287w8SxQxG8fbZbYOT7JyMveU" -H "Fiware-Service: fiwaredemo" -H "Fiware-Servicepath: /deployer" -H "Content-Type: application/json" http://192.168.99.1:8080/orion/v2/entities/deployer_01/attrs?type=deployer -X PATCH -d @-<<__EOS__
        {
            "apply": {
                "value": "{}"
            }
        }
        __EOS__ 
        ```

1. コマンドの受信待機

    ```
    $ mosquitto_sub -h ${HOST_IPADDR} -p 1883 -d -u iotagent -P ${MQTT__iotagent} -t /#
    ```

    - 実行結果（例）

        ```
        Client mosqsub/21225-roboticba sending CONNECT
        Client mosqsub/21225-roboticba received CONNACK
        Client mosqsub/21225-roboticba sending SUBSCRIBE (Mid: 1, Topic: /#, QoS: 0)
        Client mosqsub/21225-roboticba received SUBACK
        Subscribed (mid: 1): 0
        ```

1. 別ターミナルで作成したコマンドの実行

    ```
    $ curl -i -H "Authorization: bearer 5Z9KpEAE5z3XR7ZsV5cGGeefZUOJFLv0" -H "Fiware-Service: fiwaredemo" -H "Fiware-Servicepath: /deployer" -H "Content-Type: application/json" http://192.168.99.1:8080/orion/v2/entities/deployer_01/attrs?type=deployer -X PATCH -d @-<<__EOS__
    {
      "apply": {
        "value": "{}"
      }
    }
    __EOS__
    ```

    - 実行結果（例）

        ```
        HTTP/1.1 204 No Content
        content-length: 0
        fiware-correlator: 9e00714c-4938-11e9-99d5-0242ac110012
        date: Mon, 18 Mar 2019 04:45:12 GMT
        x-envoy-upstream-service-time: 78
        server: envoy
        ```

1. 受信待機側の端末で下記が表示されていることを確認

    - 実行結果（例）

        ```
        Client mosqsub/22846-roboticba received PUBLISH (d0, q0, r0, m0, '/deployer/deployer_01/cmd', ... (20 bytes))
        deployer_01@apply|{}
        Client mosqsub/22846-roboticba received PUBLISH (d0, q0, r0, m0, '/deployer/deployer_01/cmdexe', ... (51 bytes))
        deployer_01@apply|invalid format, skip this message
        ```

1. deployerログの確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ turtlebot3-pc$ kubectl logs mqtt-kube-operator-56c4c6f7f4-fb4h6
    ```

    - 実行結果（例）

        ```
        2019-04-25T13:39:02.908Z	INFO	mqtt-kube-operator/main.go:183	start main
        2019-04-25T13:39:03.066Z	INFO	mqtt-kube-operator/main.go:163	Connected to MQTT Broker(tcp://172.16.10.25:1883), start loop
        2019-04-25T13:44:21.215Z	INFO	handlers/messageHandler.go:110	received message: deployer_01@apply|{}
        2019-04-25T13:44:21.215Z	INFO	handlers/messageHandler.go:138	data: {}
        2019-04-25T13:44:21.215Z	INFO	handlers/messageHandler.go:169	invalid format, skip this message: Object 'Kind' is missing in '{}'
        2019-04-25T13:44:21.716Z	INFO	handlers/messageHandler.go:105	send message: deployer_01@apply|invalid format, skip this message
        ```

1. orion側でdeployer entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${DEPLOYER_ID}/ | jq .
    ```

    - 実行結果（例）

        ```json
        {
          "id": "deployer_01",
          "type": "deployer",
          "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-04-25T13:44:21.00Z",
            "metadata": {}
          },
          "apply_info": {
            "type": "commandResult",
            "value": "invalid format, skip this message",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T13:44:21.743Z"
              }
            }
          },
          "apply_status": {
            "type": "commandStatus",
            "value": "OK",
            "metadata": {
              "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-04-25T13:44:21.743Z"
              }
            }
          },
          "available": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "current": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "delete_info": {
            "type": "commandResult",
            "value": " ",
            "metadata": {}
          },
          "delete_status": {
            "type": "commandStatus",
            "value": "UNKNOWN",
            "metadata": {}
          },
          "deployment": {
            "type": "string",
            "value": " ",
            "metadata": {}
          },
          "desired": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "label": {
            "type": "string",
            "value": " ",
            "metadata": {}
          },
          "ready": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "unavailable": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "updated": {
            "type": "integer",
            "value": " ",
            "metadata": {}
          },
          "apply": {
            "type": "string",
            "value": "",
            "metadata": {}
          },
          "delete": {
            "type": "string",
            "value": "",
            "metadata": {}
          }
        }
        ```

1. deployerデバイスのcygnus-elasticsearchを登録

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -i -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}"  -H "Content-Type: application/json" http://${HOST_IPADDR}:8080/orion/v2/subscriptions/ -X POST -d @- <<__EOS__
    {
      "subject": {
        "entities": [{
          "idPattern": "${DEPLOYER_ID}.*",
          "type": "${DEPLOYER_TYPE}"
        }],
        "condition": {
          "attrs": ["deployment", "label", "desired", "current", "updated", "ready", "unavailable", "available"]
        }
      },
      "notification": {
        "http": {
          "url": "http://cygnus-elasticsearch:5050/notify"
        },
        "attrs": ["deployment", "label", "desired", "current", "updated", "ready", "unavailable", "available"],
        "attrsFormat": "legacy"
      }
    }
    __EOS__
    ```

    - 実行結果（例）

        ```
        HTTP/1.1 201 Created
        content-length: 0
        location: /v2/subscriptions/5c8f259ec45d56465adfacce
        fiware-correlator: 90f1e4c0-493a-11e9-9497-0242ac110011
        date: Mon, 18 Mar 2019 04:59:09 GMT
        x-envoy-upstream-service-time: 11
        server: envoy
        ```

1. orion側のcygnus-elasticsearch登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-ServicePath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/subscriptions/ | jq .
    ```

    - 実行結果（例）

        ```json
        [
          {
            "id": "5cc1ba4aec7807f34fd73eff",
            "status": "active",
            "subject": {
              "entities": [
                {
                  "idPattern": "deployer_01.*",
                  "type": "deployer"
                }
              ],
              "condition": {
                "attrs": [
                  "deployment",
                  "label",
                  "desired",
                  "current",
                  "updated",
                  "ready",
                  "unavailable",
                  "available"
                ]
              }
            },
            "notification": {
              "timesSent": 1,
              "lastNotification": "2019-04-25T13:46:50.00Z",
              "attrs": [
                "deployment",
                "label",
                "desired",
                "current",
                "updated",
                "ready",
                "unavailable",
                "available"
              ],
              "attrsFormat": "legacy",
              "http": {
                "url": "http://cygnus-elasticsearch:5050/notify"
              }
            }
          }
        ]
        ```

## kibanaの設定

1. 別ターミナルでKibanaのポートフォワーディングを開始

    ```
    $ kubectl --namespace monitoring port-forward $(kubectl get pod -l k8s-app=kibana-logging --namespace monitoring -o template --template "{{(index .items 0).metadata.name}}") 5601:5601
    ```

    - 実行結果（例）

        ```
        Forwarding from 127.0.0.1:5601 -> 5601
        Forwarding from [::1]:5601 -> 5601
        ```

1. ブラウザでkibanaにアクセス
  * macOS
    ```
    $ open http://localhost:5601/
    ```

  * Ubuntu
    ```
    $ xdg-open http://localhost:5601/
    ```

1. 「Management」をクリック

    ![kibana001](images/kibana/kibana001.png)

1. 「Index Patterns」をクリック

    ![kibana002](images/kibana/kibana002.png)

1. 「+Create Index Pattern」をクリック

    ![kibana003](images/kibana/kibana003.png)

1. 「Index pattern」に「cygnus-fiwaredemo-deployer-*」を入力し「Next step」をクリック

    ![kibana004](images/kibana/kibana004.png)

1. 「Time Filter field name」で「revTime」を選択し「Create Index pattern」をクリック

    ![kibana005](images/kibana/kibana005.png)

1. cygnus-fiwaredemo-deployer-* の画面が表示されていることを確認

    ![kibana006](images/kibana/kibana006.png)

1. 「Discover」をクリックした後、「logstash-*」のプルダウンリストをクリック

    ![kibana007](images/kibana/kibana007.png)

1. 「cygnus-fiwaredemo-deployer-*」を選択すると、デプロイログが表示される

    ![kibana008](images/kibana/kibana008.png)

1. ブラウザを終了

1. Ctrl-Cでport-forwardingを終了し、別ターミナル閉じる

## grafanaの設定

1. 別ターミナルでgrafanaのポートフォワーディングを開始

    ```
    $ kubectl --namespace monitoring port-forward $(kubectl get pod --namespace monitoring -l app=kp-grafana -o template --template "{{(index .items 0).metadata.name}}") 3000:3000
    ```

    - 実行結果（例）

        ```
        Forwarding from 127.0.0.1:3000 -> 3000
        Forwarding from [::1]:3000 -> 3000
        ```

1. ブラウザでgrafanaにアクセス
  * macOS

    ```
    $ open http://localhost:3000
    ```
  * Ubuntu

    ```
    $ xdg-open http://localhost:3000
    ```

1. grafanaのWEB管理画面が表示されたことを確認

    ![grafana001](images/grafana/grafana001.png)

1. 「歯車」「Data Sources」をクリック

    ![grafana002](images/grafana/grafana002.png)

1. 「Add Data source」をクリック

    ![grafana003](images/grafana/grafana003.png)

1. 「Elasticsearch」をクリック

    ![grafana004](images/grafana/grafana004.png)

1. 下記の設定値を入力し「Save & Test」をクリック

    Name : cygnus-fiwaredemo-deployer  
    URL : http://elasticsearch-logging:9200  
    Access : Server(Default)  
    Index name : cygnus-fiwaredemo-deployer-*  
    Time field name : recvTime  
    Version : 6.0+

    ![grafana005](images/grafana/grafana005.png)

1. 「Datasource Updated」が表示されたことを確認

    ![grafana006](images/grafana/grafana006.png)

1. 「＋」「import」をクリック

    ![grafana007](images/grafana/grafana007.png)

1. 「Upload .json File」をクリック

    ![grafana008](images/grafana/grafana008.png)

1. 「example-turtlebot3/monitoring/dashboard_turtlebot3.json」を選択し「開く」をクリック

    ![grafana009](images/grafana/grafana009.png)

1. 下記の設定値を選択し「Import」をクリック
 
    cygnus-fiwaredemo-deployer : cygnus-fiwaredemo-deployer  
    cygnus-fiwaredemo-robot : cygnus-fiwaredemo-deployer  

    ![grafana010](images/grafana/grafana010.png)

1. Turtlebot3のROS Nodeデプロイ状況のグラフ画面が表示されることを確認（現時点ではまだROS Nodeがデプロイされていないので何も表示されない）

    ![grafana011](images/grafana/grafana011.png)
