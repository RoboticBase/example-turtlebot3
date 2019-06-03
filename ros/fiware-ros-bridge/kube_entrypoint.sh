#!/bin/bash

PIDS=""
trap 'kill -TERM $PIDS' TERM INT

rm -f /opt/ros_ws/src/fiware_ros_bridge/config/mqtt.yaml
ln -s /etc/fiware_ros_bridge/secrets/mqtt.yaml /opt/ros_ws/src/fiware_ros_bridge/config/mqtt.yaml
rm -f /opt/ros_ws/src/fiware_ros_bridge/config/robot_cmd.yaml
ln -s /etc/fiware_ros_bridge/configmaps/robot_cmd.yaml /opt/ros_ws/src/fiware_ros_bridge/config/robot_cmd.yaml
rm -f /opt/ros_ws/src/fiware_ros_bridge/config/robot_attrs.yaml
ln -s /etc/fiware_ros_bridge/configmaps/robot_attrs.yaml /opt/ros_ws/src/fiware_ros_bridge/config/robot_attrs.yaml

source /opt/ros/kinetic/setup.bash
catkin_make
source /opt/ros_ws/devel/setup.bash
roslaunch fiware_ros_bridge fiware_ros_bridge.launch &
PIDS="$PIDS $!"

wait $PIDS
trap - TERM INT
wait $PIDS
