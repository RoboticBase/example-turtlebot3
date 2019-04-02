FROM ubuntu:16.04
MAINTAINER Nobuyuki Matsui <nobuyuki.matsui@gmail.com>

ENV PYTHONUNBUFFERED 1

ARG MSGS_NAME="fiware_ros_turtlebot3_msgs"
ARG MSGS_GIT_REPO="https://github.com/RoboticBase/fiware_ros_turtlebot3_msgs.git"
ARG MSGS_GIT_REV="master"

ARG OPERATOR_NAME="fiware_ros_turtlebot3_operator"
ARG OPERATOR_GIT_REPO="https://github.com/RoboticBase/fiware_ros_turtlebot3_operator.git"
ARG OPERATOR_GIT_REV="0.2.1"

COPY ./kube_entrypoint.sh /opt/kube_entrypoint.sh
WORKDIR /opt/ros_ws

RUN apt update && apt upgrade -y && apt install -y git ca-certificates --no-install-recommends && \
    mkdir -p /opt/ros_ws/src && \
    git clone ${MSGS_GIT_REPO} src/${MSGS_NAME} && cd src/${MSGS_NAME} && git checkout ${MSGS_GIT_REV} && cd ../.. && \
    git clone ${OPERATOR_GIT_REPO} src/${OPERATOR_NAME} && cd src/${OPERATOR_NAME} && git checkout ${OPERATOR_GIT_REV} && cd ../.. && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get purge -y --auto-remove git
