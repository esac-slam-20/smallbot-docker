FROM ros:noetic-ros-core AS base
RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list
# Fix GPG key expire problem.
RUN apt-get update --allow-insecure-repositories && apt-get install -y curl wget && apt-get clean
RUN curl -s http://repo.ros2.org/repos.key | apt-key add -
RUN apt-get update && apt-get install -y ros-noetic-tf2-web-republisher ros-noetic-tf ros-noetic-tf2-ros ros-noetic-rosbridge-server ros-noetic-move-base && apt-get clean

FROM base AS devel
RUN apt-get update && apt-get install -y build-essential cmake gcc g++ tar git && apt-get clean
RUN mkdir -p /opt/smallbot/src
WORKDIR /opt/smallbot
COPY src ./src
RUN . /opt/ros/noetic/setup.sh && catkin_make

FROM base as RUN
RUN groupadd -g 999 spi && groupadd -g 997 gpio && useradd -d /opt/smallbot -l -m -u 1000 -G 20,997,999 -s /bin/bash smallbot
COPY --from=devel /opt/smallbot /opt/smallbot
RUN chown -R 1000:1000 /opt/smallbot
