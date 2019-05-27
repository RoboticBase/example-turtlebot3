FROM ubuntu:16.04
MAINTAINER Nobuyuki Matsui <nobuyuki.matsui@gmail.com>

ENV PYTHONUNBUFFERED 1

ARG MSGS_NAME="fiware_ros_turtlebot3_msgs"
ARG MSGS_GIT_REPO="https://github.com/RoboticBase/fiware_ros_msgs.git"
ARG MSGS_GIT_REV="master"

ARG BRIDGE_NAME="fiware_ros_turtlebot3_bridge"
ARG BRIDGE_GIT_REPO="https://github.com/RoboticBase/fiware_ros_bridge.git"
ARG BRIDGE_GIT_REV="0.2.2"

COPY ./kube_entrypoint.sh /opt/kube_entrypoint.sh
WORKDIR /opt/ros_ws

RUN apt update && apt upgrade -y && apt install -y git ca-certificates python-setuptools python-pip --no-install-recommends && \
    mkdir -p /opt/ros_ws/src && \
    git clone ${MSGS_GIT_REPO} src/${MSGS_NAME} && cd src/${MSGS_NAME} && git checkout ${MSGS_GIT_REV} && cd ../.. && \
    git clone ${BRIDGE_GIT_REPO} src/${BRIDGE_NAME} && cd src/${BRIDGE_NAME} && git checkout ${BRIDGE_GIT_REV} && cd ../.. && \
    pip install wheel --user && \
    pip install -r /opt/ros_ws/src/fiware_ros_turtlebot3_bridge/requirements/common.txt --user && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get purge -y --auto-remove git
