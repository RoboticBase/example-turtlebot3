# Turtlebot3 試験環境 インストールマニュアル #4


## 構築環境(2019年3月15日現在)
- Ubuntu 16.04.5 LTS
- git 2.7.4
- apt-transport-https 1.2.29ubuntu0.1
- ca-certificates 7.47.0-1ubuntu2.12
- curl 7.47.0-1ubuntu2.12
- software-properties-common 0.96.20.8
- docker-ce  18.06.1
- minikube v0.35.0
- virtualbox 5.1.38
- kubectl 1.13.4
- kubeadm 1.10.12
- kubelet 1.10.12


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
  
1. .bashrcに環境変数の設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ vi .bashrc
    export TURTLEBOT3_MODEL=waffle

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

## turtlebot3-pcの設定【turtlebot3-pc】

### dockerの設定【turtlebot3-pc】

1. 必要なパッケージのインストール【turtlebot3-pc】

    ```
    export LANG=C
    cd ~
    turtlebot3-pc$ sudo apt update -y
    turtlebot3-pc$ sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    ```

    - 実行結果（例）

        ```
        Reading package lists... Done
        Building dependency tree       
        Reading state information... Done
        apt-transport-https is already the newest version (1.2.29ubuntu0.1).
        curl is already the newest version (7.47.0-1ubuntu2.12).
        The following additional packages will be installed:
        libcairo-perl libglib-perl libgtk2-perl libpango-perl python3-software-properties
        software-properties-gtk
        Suggested packages:
        libfont-freetype-perl libgtk2-perl-doc
        The following NEW packages will be installed:
        libcairo-perl libglib-perl libgtk2-perl libpango-perl
        The following packages will be upgraded:
        ca-certificates python3-software-properties software-properties-common
        software-properties-gtk
        4 upgraded, 4 newly installed, 0 to remove and 319 not upgraded.
        Need to get 1346 kB of archives.
        After this operation, 4809 kB of additional disk space will be used.
        Get:1 http://jp.archive.ubuntu.com/ubuntu xenial-updates/main amd64 ca-certificates all 20170717~16.04.2 [167 kB]
        Get:2 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 libcairo-perl amd64 1.106-1build1 [88.2 kB]
        Get:3 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 libglib-perl amd64 3:1.320-2 [326 kB]
        Get:4 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 libpango-perl amd64 1.227-1 [154 kB]
        Get:5 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 libgtk2-perl amd64 2:1.2498-1 [534 kB]
        Get:6 http://jp.archive.ubuntu.com/ubuntu xenial-updates/main amd64 software-properties-common all 0.96.20.8 [9440 B]
        Get:7 http://jp.archive.ubuntu.com/ubuntu xenial-updates/main amd64 software-properties-gtk all 0.96.20.8 [47.1 kB]
        Get:8 http://jp.archive.ubuntu.com/ubuntu xenial-updates/main amd64 python3-software-properties all 0.96.20.8 [20.2 kB]
        Fetched 1346 kB in 0s (4107 kB/s)                 
        Preconfiguring packages ...
        (Reading database ... 254844 files and directories currently installed.)
        Preparing to unpack .../ca-certificates_20170717~16.04.2_all.deb ...
        Unpacking ca-certificates (20170717~16.04.2) over (20170717~16.04.1) ...
        Selecting previously unselected package libcairo-perl.
        Preparing to unpack .../libcairo-perl_1.106-1build1_amd64.deb ...
        Unpacking libcairo-perl (1.106-1build1) ...
        Selecting previously unselected package libglib-perl.
        Preparing to unpack .../libglib-perl_3%3a1.320-2_amd64.deb ...
        Unpacking libglib-perl (3:1.320-2) ...
        Selecting previously unselected package libpango-perl.
        Preparing to unpack .../libpango-perl_1.227-1_amd64.deb ...
        Unpacking libpango-perl (1.227-1) ...
        Selecting previously unselected package libgtk2-perl.
        Preparing to unpack .../libgtk2-perl_2%3a1.2498-1_amd64.deb ...
        Unpacking libgtk2-perl (2:1.2498-1) ...
        Preparing to unpack .../software-properties-common_0.96.20.8_all.deb ...
        Unpacking software-properties-common (0.96.20.8) over (0.96.20) ...
        Preparing to unpack .../software-properties-gtk_0.96.20.8_all.deb ...
        Unpacking software-properties-gtk (0.96.20.8) over (0.96.20) ...
        Preparing to unpack .../python3-software-properties_0.96.20.8_all.deb ...
        Unpacking python3-software-properties (0.96.20.8) over (0.96.20) ...
        Processing triggers for man-db (2.7.5-1) ...
        Processing triggers for dbus (1.10.6-1ubuntu3.1) ...
        Processing triggers for hicolor-icon-theme (0.15-0ubuntu1) ...
        Processing triggers for shared-mime-info (1.5-2) ...
        Processing triggers for gnome-menus (3.13.3-6ubuntu3) ...
        Processing triggers for desktop-file-utils (0.22-1ubuntu5) ...
        Processing triggers for bamfdaemon (0.5.3~bzr0+16.04.20160415-0ubuntu1) ...
        Rebuilding /usr/share/applications/bamf-2.index...
        Processing triggers for mime-support (3.59ubuntu1) ...
        Setting up ca-certificates (20170717~16.04.2) ...
        Setting up libcairo-perl (1.106-1build1) ...
        Setting up libglib-perl (3:1.320-2) ...
        Setting up libpango-perl (1.227-1) ...
        Setting up libgtk2-perl (2:1.2498-1) ...
        Setting up python3-software-properties (0.96.20.8) ...
        Setting up software-properties-common (0.96.20.8) ...
        Setting up software-properties-gtk (0.96.20.8) ...
        Processing triggers for ca-certificates (20170717~16.04.2) ...
        Updating certificates in /etc/ssl/certs...
        0 added, 0 removed; done.
        Running hooks in /etc/ca-certificates/update.d...
        done.
        ```

1. docker-ceリポジトリの公開鍵を登録【turtlebot3-pc】

    ```
    turtlebot3-pc$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    ```

    - 実行結果（例）

        ```
        OK
        ```

1. docker-ceリポジトリを登録【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    ```

1. dockerのインストール【turtlebot3-pc】

   ```
   turtlebot3-pc$ sudo apt update
   ```

    - 実行結果（例）

        ```
        Hit:1 http://archive.ubuntulinux.jp/ubuntu xenial InRelease
        Ign:2 http://archive.ubuntulinux.jp/ubuntu-ja-non-free xenial InRelease                        
        Hit:3 http://archive.ubuntulinux.jp/ubuntu-ja-non-free xenial Release                          
        Hit:4 http://jp.archive.ubuntu.com/ubuntu xenial InRelease                                     
        Get:5 https://download.docker.com/linux/ubuntu xenial InRelease [66.2 kB]                      
        Hit:6 http://jp.archive.ubuntu.com/ubuntu xenial-updates InRelease                             
        Hit:7 http://jp.archive.ubuntu.com/ubuntu xenial-backports InRelease                           
        Hit:9 http://security.ubuntu.com/ubuntu xenial-security InRelease                              
        Hit:10 http://packages.ros.org/ros/ubuntu xenial InRelease
        Get:11 https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages [7361 B]
        Fetched 73.6 kB in 1s (58.7 kB/s)                   
        *** Error in `appstreamcli': double free or corruption (fasttop): 0x000000000145ecb0 ***
        ======= Backtrace: =========
        /lib/x86_64-linux-gnu/libc.so.6(+0x777e5)[0x7f80bba547e5]
        /lib/x86_64-linux-gnu/libc.so.6(+0x8037a)[0x7f80bba5d37a]
        /lib/x86_64-linux-gnu/libc.so.6(cfree+0x4c)[0x7f80bba6153c]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_component_complete+0x439)[0x7f80bbdd9d19]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_data_pool_update+0x44a)[0x7f80bbddaf0a]
        /usr/lib/x86_64-linux-gnu/libappstream.so.3(as_cache_builder_refresh+0x1c2)[0x7f80bbdd0272]
        appstreamcli(ascli_refresh_cache+0x12e)[0x4049de]
        appstreamcli(as_client_run+0x6fb)[0x403ceb]
        /lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0xf0)[0x7f80bb9fd830]
        appstreamcli(_start+0x29)[0x403519]
        ======= Memory map: ========
        00400000-00408000 r-xp 00000000 08:01 1962313                            /usr/bin/appstreamcli
        00607000-00608000 r--p 00007000 08:01 1962313                            /usr/bin/appstreamcli
        00608000-00609000 rw-p 00008000 08:01 1962313                            /usr/bin/appstreamcli
        01287000-02ed4000 rw-p 00000000 00:00 0                                  [heap]
        7f80b0000000-7f80b0021000 rw-p 00000000 00:00 0 
        7f80b0021000-7f80b4000000 ---p 00000000 00:00 0 
        7f80b71cf000-7f80b8a85000 r-xp 00000000 08:01 1964532                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f80b8a85000-7f80b8c84000 ---p 018b6000 08:01 1964532                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f80b8c84000-7f80b8c85000 r--p 018b5000 08:01 1964532                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f80b8c85000-7f80b8c86000 rw-p 018b6000 08:01 1964532                    /usr/lib/x86_64-linux-gnu/libicudata.so.55.1
        7f80b8c86000-7f80b8c8a000 r-xp 00000000 08:01 537553                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f80b8c8a000-7f80b8e89000 ---p 00004000 08:01 537553                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f80b8e89000-7f80b8e8a000 r--p 00003000 08:01 537553                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f80b8e8a000-7f80b8e8b000 rw-p 00004000 08:01 537553                     /lib/x86_64-linux-gnu/libuuid.so.1.3.0
        7f80b8e8b000-7f80b8f93000 r-xp 00000000 08:01 538106                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f80b8f93000-7f80b9192000 ---p 00108000 08:01 538106                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f80b9192000-7f80b9193000 r--p 00107000 08:01 538106                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f80b9193000-7f80b9194000 rw-p 00108000 08:01 538106                     /lib/x86_64-linux-gnu/libm-2.23.so
        7f80b9194000-7f80b91b5000 r-xp 00000000 08:01 528501                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f80b91b5000-7f80b93b4000 ---p 00021000 08:01 528501                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f80b93b4000-7f80b93b5000 r--p 00020000 08:01 528501                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f80b93b5000-7f80b93b6000 rw-p 00021000 08:01 528501                     /lib/x86_64-linux-gnu/liblzma.so.5.0.0
        7f80b93b6000-7f80b9535000 r-xp 00000000 08:01 1964536                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f80b9535000-7f80b9735000 ---p 0017f000 08:01 1964536                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f80b9735000-7f80b9745000 r--p 0017f000 08:01 1964536                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f80b9745000-7f80b9746000 rw-p 0018f000 08:01 1964536                    /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1
        7f80b9746000-7f80b974a000 rw-p 00000000 00:00 0 
        7f80b974a000-7f80b974d000 r-xp 00000000 08:01 538532                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f80b974d000-7f80b994c000 ---p 00003000 08:01 538532                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f80b994c000-7f80b994d000 r--p 00002000 08:01 538532                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f80b994d000-7f80b994e000 rw-p 00003000 08:01 538532                     /lib/x86_64-linux-gnu/libdl-2.23.so
        7f80b994e000-7f80b9964000 r-xp 00000000 08:01 528472                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7f80b9964000-7f80b9b63000 ---p 00016000 08:01 528472                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7f80b9b63000-7f80b9b64000 rw-p 00015000 08:01 528472                     /lib/x86_64-linux-gnu/libgcc_s.so.1
        7f80b9b64000-7f80b9cd6000 r-xp 00000000 08:01 1964445                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f80b9cd6000-7f80b9ed6000 ---p 00172000 08:01 1964445                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f80b9ed6000-7f80b9ee0000 r--p 00172000 08:01 1964445                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f80b9ee0000-7f80b9ee2000 rw-p 0017c000 08:01 1964445                    /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
        7f80b9ee2000-7f80b9ee6000 rw-p 00000000 00:00 0 
        7f80b9ee6000-7f80b9f16000 r-xp 00000000 08:01 1973706                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f80b9f16000-7f80ba115000 ---p 00030000 08:01 1973706                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f80ba115000-7f80ba116000 r--p 0002f000 08:01 1973706                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f80ba116000-7f80ba117000 rw-p 00030000 08:01 1973706                    /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1
        7f80ba117000-7f80ba30b000 r-xp 00000000 08:01 1974066                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f80ba30b000-7f80ba50b000 ---p 001f4000 08:01 1974066                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f80ba50b000-7f80ba512000 r--p 001f4000 08:01 1974066                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f80ba512000-7f80ba513000 rw-p 001fb000 08:01 1974066                    /usr/lib/x86_64-linux-gnu/libxapian.so.22.7.0
        7f80ba513000-7f80ba530000 r-xp 00000000 08:01 1974120                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f80ba530000-7f80ba730000 ---p 0001d000 08:01 1974120                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f80ba730000-7f80ba731000 r--p 0001d000 08:01 1974120                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f80ba731000-7f80ba732000 rw-p 0001e000 08:01 1974120                    /usr/lib/x86_64-linux-gnu/libyaml-0.so.2.0.4
        7f80ba732000-7f80ba8e3000 r-xp 00000000 08:01 1964540                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f80ba8e3000-7f80baae2000 ---p 001b1000 08:01 1964540                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f80baae2000-7f80baaea000 r--p 001b0000 08:01 1964540                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f80baaea000-7f80baaec000 rw-p 001b8000 08:01 1964540                    /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3
        7f80baaec000-7f80baaed000 rw-p 00000000 00:00 0 
        7f80baaed000-7f80baaf4000 r-xp 00000000 08:01 1973106                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f80baaf4000-7f80bacf3000 ---p 00007000 08:01 1973106                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f80bacf3000-7f80bacf4000 r--p 00006000 08:01 1973106                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f80bacf4000-7f80bacf5000 rw-p 00007000 08:01 1973106                    /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4
        7f80bacf5000-7f80bad0c000 r-xp 00000000 08:01 538534                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f80bad0c000-7f80baf0c000 ---p 00017000 08:01 538534                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f80baf0c000-7f80baf0d000 r--p 00017000 08:01 538534                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f80baf0d000-7f80baf0e000 rw-p 00018000 08:01 538534                     /lib/x86_64-linux-gnu/libresolv-2.23.so
        7f80baf0e000-7f80baf10000 rw-p 00000000 00:00 0 
        7f80baf10000-7f80baf2f000 r-xp 00000000 08:01 528592                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f80baf2f000-7f80bb12e000 ---p 0001f000 08:01 528592                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f80bb12e000-7f80bb12f000 r--p 0001e000 08:01 528592                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f80bb12f000-7f80bb130000 rw-p 0001f000 08:01 528592                     /lib/x86_64-linux-gnu/libselinux.so.1
        7f80bb130000-7f80bb132000 rw-p 00000000 00:00 0 
        7f80bb132000-7f80bb14b000 r-xp 00000000 08:01 528357                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f80bb14b000-7f80bb34a000 ---p 00019000 08:01 528357                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f80bb34a000-7f80bb34b000 r--p 00018000 08:01 528357                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f80bb34b000-7f80bb34c000 rw-p 00019000 08:01 528357                     /lib/x86_64-linux-gnu/libz.so.1.2.8
        7f80bb34c000-7f80bb34f000 r-xp 00000000 08:01 1962658                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f80bb34f000-7f80bb54e000 ---p 00003000 08:01 1962658                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f80bb54e000-7f80bb54f000 r--p 00002000 08:01 1962658                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f80bb54f000-7f80bb550000 rw-p 00003000 08:01 1962658                    /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.2
        7f80bb550000-7f80bb568000 r-xp 00000000 08:01 538206                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f80bb568000-7f80bb767000 ---p 00018000 08:01 538206                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f80bb767000-7f80bb768000 r--p 00017000 08:01 538206                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f80bb768000-7f80bb769000 rw-p 00018000 08:01 538206                     /lib/x86_64-linux-gnu/libpthread-2.23.so
        7f80bb769000-7f80bb76d000 rw-p 00000000 00:00 0 
        7f80bb76d000-7f80bb7db000 r-xp 00000000 08:01 528563                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f80bb7db000-7f80bb9db000 ---p 0006e000 08:01 528563                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f80bb9db000-7f80bb9dc000 r--p 0006e000 08:01 528563                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f80bb9dc000-7f80bb9dd000 rw-p 0006f000 08:01 528563                     /lib/x86_64-linux-gnu/libpcre.so.3.13.2
        7f80bb9dd000-7f80bbb9d000 r-xp 00000000 08:01 538232                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f80bbb9d000-7f80bbd9d000 ---p 001c0000 08:01 538232                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f80bbd9d000-7f80bbda1000 r--p 001c0000 08:01 538232                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f80bbda1000-7f80bbda3000 rw-p 001c4000 08:01 538232                     /lib/x86_64-linux-gnu/libc-2.23.so
        7f80bbda3000-7f80bbda7000 rw-p 00000000 00:00 0 
        7f80bbda7000-7f80bbdf2000 r-xp 00000000 08:01 1972797                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f80bbdf2000-7f80bbff2000 ---p 0004b000 08:01 1972797                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f80bbff2000-7f80bbff3000 r--p 0004b000 08:01 1972797                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f80bbff3000-7f80bbff4000 rw-p 0004c000 08:01 1972797                    /usr/lib/x86_64-linux-gnu/libappstream.so.0.9.4
        7f80bbff4000-7f80bc046000 r-xp 00000000 08:01 1962682                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f80bc046000-7f80bc245000 ---p 00052000 08:01 1962682                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f80bc245000-7f80bc246000 r--p 00051000 08:01 1962682                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f80bc246000-7f80bc247000 rw-p 00052000 08:01 1962682                    /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.2
        7f80bc247000-7f80bc3c7000 r-xp 00000000 08:01 1962703                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f80bc3c7000-7f80bc5c7000 ---p 00180000 08:01 1962703                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f80bc5c7000-7f80bc5cb000 r--p 00180000 08:01 1962703                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f80bc5cb000-7f80bc5cd000 rw-p 00184000 08:01 1962703                    /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.2
        7f80bc5cd000-7f80bc5cf000 rw-p 00000000 00:00 0 
        7f80bc5cf000-7f80bc6de000 r-xp 00000000 08:01 528377                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f80bc6de000-7f80bc8dd000 ---p 0010f000 08:01 528377                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f80bc8dd000-7f80bc8de000 r--p 0010e000 08:01 528377                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f80bc8de000-7f80bc8df000 rw-p 0010f000 08:01 528377                     /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.2
        7f80bc8df000-7f80bc8e0000 rw-p 00000000 00:00 0 
        7f80bc8e0000-7f80bc906000 r-xp 00000000 08:01 538170                     /lib/x86_64-linux-gnu/ld-2.23.so
        7f80bcab9000-7f80bcac8000 rw-p 00000000 00:00 0 
        7f80bcade000-7f80bcadf000 rw-p 00000000 00:00 0 
        7f80bcadf000-7f80bcafe000 r--s 00000000 08:01 139139                     /usr/share/mime/mime.cache
        7f80bcafe000-7f80bcb05000 r--s 00000000 08:01 2227901                    /usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache
        7f80bcb05000-7f80bcb06000 r--p 00025000 08:01 538170                     /lib/x86_64-linux-gnu/ld-2.23.so
        7f80bcb06000-7f80bcb07000 rw-p 00026000 08:01 538170                     /lib/x86_64-linux-gnu/ld-2.23.so
        7f80bcb07000-7f80bcb08000 rw-p 00000000 00:00 0 
        7ffee8053000-7ffee8074000 rw-p 00000000 00:00 0                          [stack]
        7ffee81ef000-7ffee81f1000 r--p 00000000 00:00 0                          [vvar]
        7ffee81f1000-7ffee81f3000 r-xp 00000000 00:00 0                          [vdso]
        ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
        Aborted (core dumped)
        Reading package lists... Done
        ```

   ```
   turtlebot3-pc$ sudo apt install docker-ce=18.06.1~ce~3-0~ubuntu -y
   ```

    - 実行結果（例）

        ```
        Reading package lists... Done
        Building dependency tree       
        Reading state information... Done
        The following additional packages will be installed:
        aufs-tools cgroupfs-mount libseccomp2 pigz
        The following NEW packages will be installed:
        aufs-tools cgroupfs-mount docker-ce pigz
        The following packages will be upgraded:
        libseccomp2
        1 upgraded, 4 newly installed, 0 to remove and 318 not upgraded.
        Need to get 40.2 MB of archives.
        After this operation, 198 MB of additional disk space will be used.
        Get:1 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 pigz amd64 2.3.1-2 [61.1 kB]
        Get:2 http://jp.archive.ubuntu.com/ubuntu xenial-updates/main amd64 libseccomp2 amd64 2.3.1-2.1ubuntu2~16.04.1 [38.7 kB]
        Get:3 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 aufs-tools amd64 1:3.2+20130722-1.1ubuntu1 [92.9 kB]
        Get:4 http://jp.archive.ubuntu.com/ubuntu xenial/universe amd64 cgroupfs-mount all 1.2 [4970 B]
        Get:5 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce amd64 18.06.1~ce~3-0~ubuntu [40.0 MB]
        Fetched 40.2 MB in 4s (8500 kB/s)    
        Selecting previously unselected package pigz.
        (Reading database ... 255125 files and directories currently installed.)
        Preparing to unpack .../pigz_2.3.1-2_amd64.deb ...
        Unpacking pigz (2.3.1-2) ...
        Preparing to unpack .../libseccomp2_2.3.1-2.1ubuntu2~16.04.1_amd64.deb ...
        Unpacking libseccomp2:amd64 (2.3.1-2.1ubuntu2~16.04.1) over (2.2.3-3ubuntu3) ...
        Processing triggers for man-db (2.7.5-1) ...
        Processing triggers for libc-bin (2.23-0ubuntu10) ...
        Setting up libseccomp2:amd64 (2.3.1-2.1ubuntu2~16.04.1) ...
        Processing triggers for libc-bin (2.23-0ubuntu10) ...
        Selecting previously unselected package aufs-tools.
        (Reading database ... 255133 files and directories currently installed.)
        Preparing to unpack .../aufs-tools_1%3a3.2+20130722-1.1ubuntu1_amd64.deb ...
        Unpacking aufs-tools (1:3.2+20130722-1.1ubuntu1) ...
        Selecting previously unselected package cgroupfs-mount.
        Preparing to unpack .../cgroupfs-mount_1.2_all.deb ...
        Unpacking cgroupfs-mount (1.2) ...
        Selecting previously unselected package docker-ce.
        Preparing to unpack .../docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb ...
        Unpacking docker-ce (18.06.1~ce~3-0~ubuntu) ...
        Processing triggers for libc-bin (2.23-0ubuntu10) ...
        Processing triggers for man-db (2.7.5-1) ...
        Processing triggers for ureadahead (0.100.0-19) ...
        Processing triggers for systemd (229-4ubuntu21.16) ...
        Setting up pigz (2.3.1-2) ...
        Setting up aufs-tools (1:3.2+20130722-1.1ubuntu1) ...
        Setting up cgroupfs-mount (1.2) ...
        Setting up docker-ce (18.06.1~ce~3-0~ubuntu) ...
        Processing triggers for libc-bin (2.23-0ubuntu10) ...
        Processing triggers for systemd (229-4ubuntu21.16) ...
        Processing triggers for ureadahead (0.100.0-19) ...
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

1. dockerコマンドの実行権限を付与【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo gpasswd -a $USER docker
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
    turtlebot3-pc$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.35.0/minikube-darwin-amd64 \　&& chmod +x minikube
    ```

    - 実行結果(例）

        ```
        % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        100 38.2M  100 38.2M    0     0  6458k      0  0:00:06  0:00:06 --:--:-- 7906k
        ```

1. minikubeのバージョン確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ minikube version
    ```

    - 実行結果(例）

        ```
        minikube version: v0.35.0
        ```


## kubectlの設定【turtlebot3-pc】

1. kubectlのインストール【turtlebot3-pc】

    ```
    turtlebot3-pc$ curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl
    ```

    - 実行結果(例）

        ```
        % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        100 37.4M  100 37.4M    0     0  9131k      0  0:00:04  0:00:04 --:--:-- 9133k
        ```

1. kubectlのバージョン確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl version --client
    ```

    - 実行結果(例）

        ```
        lient Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.4", GitCommit:"c27b913fddd1a6c480c229191a087698aa92f0b1", GitTreeState:"clean", BuildDate:"2019-02-28T13:37:52Z", GoVersion:"go1.11.5", Compiler:"gc", Platform:"linux/amd64"}
        ```


# 仮想化なしでminikubeを起動【turtlebot3-pc】

## リポジトリ登録コマンドの作成【turtlebot3-pc】

1. リポジトリ登録コマンドの作成【turtlebot3-pc】

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
        ?  Stopping "minikube" in none ...
        "minikube" stopped.
        ```

1. minikubeの環境の削除【turtlebot3-pc】
    　
   ```
   turtlebot3-pc$ sudo minikube delete
   ```

    - 実行結果(例）

        ```
        Uninstalling Kubernetes v1.13.4 using kubeadm ...
        Deleting "minikube" from none ...
        The "minikube" cluster has been deleted.
        ```

   ```
   turtlebot3-pc$ sudo rm -rf /etc/kubernetes/
   turtlebot3-pc$ sudo rm -rf $HOME/.minikube/
   turtlebot3-pc$ rm -rf $HOME/.kube/
   ```

1. .kube/configの作成【turtlebot3-pc】

    ```
    turtlebot3-pc$ mkdir -p $HOME/.kube
    turtlebot3-pc$ touch $HOME/.kube/config
    ```

1. 環境変数の設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ export MINIKUBE_WANTUPDATENOTIFICATION=false
    turtlebot3-pc$ export MINIKUBE_WANTREPORTERRORPROMPT=false
    turtlebot3-pc$ export MINIKUBE_HOME=$HOME
    turtlebot3-pc$ export CHANGE_MINIKUBE_NONE_USER=true
    turtlebot3-pc$ export KUBECONFIG=$HOME/.kube/config
    ```

1. minikubeの起動【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo -E minikube start --memory 2048 --vm-driver=none --kubernetes-version v1.10.12
    ```

    - 実行結果(例）

        ```
        minikube v0.35.0 on linux (amd64)
        Configuring local host environment ...

        ??  The 'none' driver provides limited isolation and may reduce system security and reliability.
        ??  For more information, see:
        https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md

        Creating none VM (CPUs=2, Memory=2048MB, Disk=20000MB) ...
        "minikube" IP address is 10.0.2.15
        Configuring Docker as the container runtime ...
        ?  Preparing Kubernetes environment ...
        Downloading kubeadm v1.10.12
        Downloading kubelet v1.10.12
        Pulling images required by Kubernetes v1.10.12 ...
        ?  Unable to pull images, which may be OK: running cmd: sudo kubeadm config images pull --config /var/lib/kubeadm.yaml: running command: sudo kubeadm config images pull --config /var/lib/kubeadm.yaml: exit status 1
        Launching Kubernetes v1.10.12 using kubeadm ... 
        ?  Waiting for pods: apiserver proxy etcd scheduler controller addon-manager dns
        Configuring cluster permissions ...
        Verifying component health .....
        kubectl is now configured to use "minikube"
        Done! Thank you for using minikube!
        ```

1. .kube .minikubeのオーナー変更【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo chown -R $USER $HOME/.kube $HOME/.minikube
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
        ?  Stopping "minikube" in none ...
        ?  Stopping "minikube" in none ...
        "minikube" stopped.
      ```

1. minikubeの起動【turtlebot3-pc】

    ```
    turtlebot3-pc$ sudo -E minikube start --memory 2048 --vm-driver=none --kubernetes-version v1.10.12
    ```

    - 実行結果(例）

        ```
        minikube v0.35.0 on linux (amd64)
        Configuring local host environment ...

        ??  The 'none' driver provides limited isolation and may reduce system security and reliability.
        ??  For more information, see:
        https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md

        Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
        Restarting existing none VM for "minikube" ...
        ?  Waiting for SSH access ...
        "minikube" IP address is 10.0.2.15
        Configuring Docker as the container runtime ...
        ?  Preparing Kubernetes environment ...
        Pulling images required by Kubernetes v1.10.12 ...
        ?  Unable to pull images, which may be OK: running cmd: sudo kubeadm config images pull --config /var/lib/kubeadm.yaml: running command: sudo kubeadm config images pull --config /var/lib/kubeadm.yaml: exit status 1
        Relaunching Kubernetes v1.10.12 using kubeadm ... 
        ?  Waiting for pods: apiserver proxy etcd scheduler controller addon-manager dns
        Updating kube-proxy configuration ...
        Verifying component health ........
        kubectl is now configured to use "minikube"
        Done! Thank you for using minikube!
        ```

1. minikubeのバージョン確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl version
    ```

    - 実行結果(例）

        ```
        Client Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.4", GitCommit:"c27b913fddd1a6c480c229191a087698aa92f0b1", GitTreeState:"clean", BuildDate:"2019-02-28T13:37:52Z", GoVersion:"go1.11.5", Compiler:"gc", Platform:"linux/amd64"}
        Server Version: version.Info{Major:"1", Minor:"10", GitVersion:"v1.10.12", GitCommit:"c757b93cf034d49af3a3b8ecee3b9639a7a11df7", GitTreeState:"clean", BuildDate:"2018-12-19T11:04:29Z", GoVersion:"go1.9.3", Compiler:"gc", Platform:"linux/amd64"}
        ```

1. minikubeのnode確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get nodes
    ```

    - 実行結果(例）

        ```
        NAME       STATUS   ROLES    AGE   VERSION
        minikube   Ready    master   16m   v1.10.12
        ```

1. 全podが起動していることを確認【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl get pods --all-namespaces
    ```

    - 実行結果(例）

        ```
        NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
        kube-system   etcd-minikube                      1/1     Running   2          1m
        kube-system   kube-addon-manager-minikube        1/1     Running   1          5m
        kube-system   kube-apiserver-minikube            1/1     Running   0          1m
        kube-system   kube-controller-manager-minikube   1/1     Running   0          1m
        kube-system   kube-dns-86f4d74b45-82gcl          3/3     Running   3          6m
        kube-system   kube-proxy-bwbcw                   1/1     Running   0          31s
        kube-system   kube-scheduler-minikube            1/1     Running   0          1m
        kube-system   storage-provisioner                1/1     Running   1          6m
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

1. kube-dns-configmapファイルの作成【turtlebot3-pc】

    ```
    turtlebot3-pc$ vi /tmp/kube-dns-configmap.yaml
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

        ```
        {}
        ```

## 登録されているservice確認

1. deployer serviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/services/ | jq .
    ```

    - 実行結果(例）

    ```
    {
        "count": 1,
        "services": [
        {
            "commands": [],
            "lazy": [],
            "attributes": [],
            "_id": "5c8b26cf531d1300121dbf21",
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

        ```
        {}
        ```

1. idas側でdeployer deviceの登録確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/idas/ul20/manage/iot/devices/${DEPLOYER_ID}/ | jq .
    ```

    - 実行結果(例）

    ```
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

        ```
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

1. ユーザ名とパスワードの作成

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

1. MQTTエンドポイントのConfigmap設定ファイルの作成

    ```
    $ echo "kubectl create configmap mqtt-config --from-literal=mqtt_use_tls=false --from-literal=mqtt_host=${EXTERNAL_HOST_IPADDR} --from-literal=mqtt_port=1883 --from-literal=mqtt_cmd_topic=/${DEPLOYER_TYPE}/${DEPLOYER_ID}"
    ```

    - 実行結果(例）

        ```
        $ kubectl create configmap mqtt-config --from-literal=mqtt_use_tls=false --from-literal=mqtt_host=172.16.10.25 --from-literal=mqtt_port=1883 --from-literal=mqtt_cmd_topic=/deployer/deployer_01
        ```

1. MQTTエンドポイントのConfigmapの設定【turtlebot3-pc】

    ```
    turtlebot3-pc$ kubectl create configmap mqtt-config --from-literal=mqtt_use_tls=false --from-literal=mqtt_host=172.16.10.25 --from-literal=mqtt_port=1883 --from-literal=mqtt_cmd_topic=/deployer/deployer_01
    ```

    - 実行結果(例）

        ```
        configmap/mqtt-config created
        ```


## MQTT通信でリソースを操作するdeployerの起動【turtlebot3-pc】

1. mqtt-kube-pperatorファイルの作成

    ```
    turtlebot3-pc $ vi /tmp/mqtt-kube-operator.yaml
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
            image: roboticbase/mqtt-kube-operator:0.1.0
            imagePullPolicy: Always
            env:
            - name: MQTT_USERNAME
        
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
            - name: MQTT_CMD_TOPIC
            valueFrom:
                configMapKeyRef:
                name: mqtt-config
                key: mqtt_cmd_topic
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
        2019-03-18T04:17:17.426Z        INFO    mqtt-kube-operator/main.go:132  start main
        2019-03-18T04:17:17.458Z        INFO    mqtt-kube-operator/main.go:119      Connected to MQTT Broker(tcp://172.16.10.25:1883), start loop
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
        2019-03-18T04:17:17.426Z        INFO    mqtt-kube-operator/main.go:132  start main
        2019-03-18T04:17:17.458Z        INFO    mqtt-kube-operator/main.go:119  Connected to MQTT Broker(tcp://202.250.201.86:1883), start loop
        2019-03-18T04:45:13.126Z        INFO    handlers/messageHandler.go:108  received message: deployer_01@apply|{}
        2019-03-18T04:45:13.127Z        INFO    handlers/messageHandler.go:136  data: {}
        2019-03-18T04:45:13.127Z        INFO    handlers/messageHandler.go:167  invalid format, skip this message: Object 'Kind' is missing in '{}'
        2019-03-18T04:45:13.628Z        INFO    handlers/messageHandler.go:103  send message: deployer_01@apply|invalid format, skip this message
        ```

1. orion側でdeployer entityの確認

    ```
    $ TOKEN=$(cat ${CORE_ROOT}/secrets/auth-tokens.json | jq '.[0].settings.bearer_tokens[0].token' -r)
    $ curl -sS -H "Authorization: bearer ${TOKEN}" -H "Fiware-Service: ${FIWARE_SERVICE}" -H "Fiware-Servicepath: ${DEPLOYER_SERVICEPATH}" http://${HOST_IPADDR}:8080/orion/v2/entities/${DEPLOYER_ID}/ | jq .
    ```

    - 実行結果（例）

        ```
        {
        "id": "deployer_01",
        "type": "deployer",
        "TimeInstant": {
            "type": "ISO8601",
            "value": "2019-03-18T04:45:13.00Z",
            "metadata": {}
        },
        "apply_info": {
            "type": "commandResult",
            "value": "invalid format, skip this message",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-18T04:45:13.728Z"
            }
            }
        },
        "apply_status": {
            "type": "commandStatus",
            "value": "OK",
            "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2019-03-18T04:45:13.728Z"
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

        ```
        [
        {
            "id": "5c8f259ec45d56465adfacce",
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
            "lastNotification": "2019-03-18T04:59:10.00Z",
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
            },
            "lastSuccess": "2019-03-18T04:59:10.00Z"
            }
        }
        ]
        ```

## kibanaの設定

1. コマンドの作成

    ```
    $ echo 'kubectl --namespace monitoring port-forward $(kubectl get pod -l k8s-app=kibana-logging --namespace monitoring -o template --template "{{(index .items 0).metadata.name}}") 5601:5601'
    ```

    - 実行結果（例）

        ```
        kubectl --namespace monitoring port-forward $(kubectl get pod -l k8s-app=kibana-logging --namespace monitoring -o template --template "{{(index .items 0).metadata.name}}") 5601:5601
        ```

1. kibanaポートのforward設定【turtlebot3-pc】

    ```
    $ kubectl --namespace monitoring port-forward $(kubectl get pod -l k8s-app=kibana-logging --namespace monitoring -o template --template "{{(index .items 0).metadata.name}}") 5601:5601
    ```

    - 実行結果（例）

        ```
        Forwarding from 127.0.0.1:5601 -> 5601
        Forwarding from [::1]:5601 -> 5601
        ```

1. GUI画面にて下記のコマンドを実行【turtlebot3-pc】

    ```
    $ xdg-open http://localhost:5601/
    ```

1. 「Management」をクリック

    ![kibana001](images/kibana/kibana001.png)

1. 「Index Patterns」をクリック

    ![kibana002](images/kibana/kibana002.png)

1. 「Index Pattern」に「cygnus-fiwaredemo-deployer-*」を入力し「Next step」をクリック

    ![kibana003](images/kibana/kibana003.png)

1. 「Time Filter field name」で「recvTime」を選択し「Create index pattern」をクリック

    ![kibana004](images/kibana/kibana004.png)

1. Cygnus-fiwaredemo-deployer-* の画面が表示されていることを確認しブラウザを終了

    ![kibana005](images/kibana/kibana005.png)


## grafanaの設定

1. コマンドの作成

    ```
    $ echo 'kubectl --namespace monitoring port-forward $(kubectl get pod --namespace monitoring -l app=kp-grafana -o template --template "{{(index .items 0).metadata.name}}") 3000:3000'
    ```

    - 実行結果（例）

        ```
        kubectl --namespace monitoring port-forward $(kubectl get pod --namespace monitoring -l app=kp-grafana -o template --template "{{(index .items 0).metadata.name}}") 3000:3000
        ```

1. grafanaポートのforward設定【turtlebot3-pc】

    ```
    $ kubectl --namespace monitoring port-forward $(kubectl get pod --namespace monitoring -l app=kp-grafana -o template --template "{{(index .items 0).metadata.name}}") 3000:3000
    ```

    - 実行結果（例）

        ```
        Forwarding from 127.0.0.1:3000 -> 3000
        Forwarding from [::1]:3000 -> 3000
        ```

1. GUI画面にて下記のコマンドを実行【turtlebot3-pc】

    ```
    $ xdg-open http://localhost:3000/
    ```

1. 「email or username」に「admin」、「password」に設定したパスワードを入力し「Log In」をクリック

    ![grafana001](images/grafana/grafana001.png)

1. 「歯車」「Data Sources」をクリック

    ![grafana002](images/grafana/grafana002.png)

1. 「Add data source」をクリック

    ![grafana003](images/grafana/grafana003.png)

1. 「Elasticsearch」をクリック

    ![grafana004](images/grafana/grafana004.png)

1. 下記の設定値を入力し、「Save & Test」をクリック

    Name : cygnus-fiwaredemo-deployer  
    URL : http://elasticsearch-logging:9200  
    Access : Server(Default)  
    Index name : cygnus-fiwaredemo-deployer-*  
    Time field name : recvTime  
    Version : 6.0+  

    ![grafana005](images/grafana/grafana005.png)

    ![grafana006](images/grafana/grafana006.png)

1. 「Datasource Updated」が表示されたことを確認

    ![grafana007](images/grafana/grafana007.png)

1. 「＋」「import」をクリック

    ![grafana008](images/grafana/grafana008.png)

1. 「Upload .json File」をクリック

    ![grafana009](images/grafana/grafana009.png)

1. 「example-turtlebot3/monitoring/dashboard_turtlebot3.json」を選択し「開く」をクリック

    ![grafana010](images/grafana/grafana010.png)

1. 下記の設定値を選択し「Import」をクリック

    cygnus-fiwaredemo-deployer : cygnus-fiwaredemo-deployer  
    cygnus-fiwaredemo-robot : cygnus-fiwaredemo-deployer

    ![grafana011](images/grafana/grafana011.png)

1. Turtlebot3のグラフ画面が表示されることを確認しブラウザを終了

    ![grafana012](images/grafana/grafana012.png)








