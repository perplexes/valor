FROM phusion/passenger-nodejs:0.9.15
# FROM node:0.10-onbuild
MAINTAINER Colin Curtin <colin.t.curtin@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install stuff here
WORKDIR /tmp
ADD package.json package.json
RUN npm install -g

RUN mkdir -p /home/app
WORKDIR /home/app
ADD . /home/app/valor

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT make all
