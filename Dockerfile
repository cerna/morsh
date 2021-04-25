#####################################################################
# Description:  Dockerfile
#
#               This file, 'Dockerfile', implements Debian styled Docker images
#               used for building, testing and running Machinekit-HAL in CI/CD
#               workflows.
#
# Copyright (C) 2020            Jakub Fišer  <jakub DOT fiser AT eryaf DOT com>
#
#   based on original Docker mk-cross-builder images by:
#
# Copyright (C) 2016 - 2019     John Morris  <john AT zultron DOT com>
# Copyright (C) 2016 - 2019     Mick Grant   <arceye AT mgware DOT co DOT uk>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
######################################################################

ARG DEBIAN_DISTRO_BASE

FROM ${DEBIAN_DISTRO_BASE} AS machinekit-hal_base

SHELL [ "bash", "-c" ]

###########################
# Generic apt configuration

ENV TERM=dumb

# Apt config:  silence warnings and set defaults
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV LC_ALL=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LANG=C.UTF-8

# Turn off recommends on container OS
RUN printf "%s;\n%s;\n"                 \
    'APT::Install-Recommends "0"'       \
    'APT::Install-Suggests "0"'         \
    > /etc/apt/apt.conf.d/01norecommend

# Add Machinekit Dependencies repository
RUN apt-get update &&                                                             \
    apt-get install -y                                                            \
        curl                                                                      \
        apt-transport-https                                                       \
        lsb-release                                                               \ 
        ca-certificates &&                                                        \
    curl -1sLf                                                                    \
    'https://dl.cloudsmith.io/public/machinekit/machinekit/cfg/setup/bash.deb.sh' \
        | distro="$(lsb_release -is)" codename="$(lsb_release -cs)" bash &&                                                                 \
    apt-get clean

# Update system OS
RUN apt-get update &&     \
    apt-get -y upgrade && \
    apt-get clean

####################################
# Set up Machinekit user environment

ENV USER=machinekit

RUN addgroup --gid 1000 ${USER} &&                            \
    adduser --uid 1000 --ingroup ${USER} --home /home/${USER} \
    --shell /bin/bash --disabled-password --gecos "" ${USER}

RUN apt-get update &&        \
    apt-get install -y       \
        sudo                 \
        machinekit-fixuid && \
    apt-get clean

COPY buildsystem/debian/base-entrypoint.sh /opt/bin/base-entrypoint.sh

RUN chmod +x /opt/bin/base-entrypoint.sh &&                       \
    mkdir /opt/environment &&                                     \
    echo "${USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    mkdir -p /etc/fixuid &&                                       \
    printf "user: ${USER}\ngroup: ${USER}\n" > /etc/fixuid/config.yml

ENTRYPOINT [ "/opt/bin/base-entrypoint.sh" ]

######################################################################

FROM machinekit-hal_base AS machinekit-hal_codelabs_base

RUN apt-get update &&        \
    apt-get install -y       \
        xz-utils &&          \
    apt-get clean

RUN cd /tmp && \
    curl -L https://golang.org/dl/go1.16.3.linux-amd64.tar.gz -o go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz

RUN cd /tmp && \
    curl -L https://nodejs.org/dist/v14.16.1/node-v14.16.1-linux-x64.tar.xz -o node.tar.xz && \
    rm -rf /usr/local/lib/nodejs && \
    mkdir /usr/local/lib/nodejs && \
    tar -C /usr/local/lib/nodejs -xJvf node.tar.xz && \
    chown -R machinekit:machinekit /usr/local/lib/nodejs/node-v14.16.1-linux-x64

RUN cd /usr/local/bin && \
    curl -L https://github.com/googlecodelabs/tools/releases/download/v2.2.4/claat-linux-amd64 -o claat-linux-amd64 && \
    chmod +x claat-linux-amd64

ENV PATH="${PATH}:/usr/local/lib/nodejs/node-v14.16.1-linux-x64/bin:/usr/local/go/bin" \
    GOPATH="/usr/local/go" \
    GOROOT="/usr/local/go"

######################################################################

FROM machinekit-hal_codelabs_base

RUN apt-get update &&        \
    apt-get install -y       \
        git &&               \
    apt-get clean

USER machinekit

RUN cd /home/machinekit && \
    git clone https://github.com/googlecodelabs/tools gcl_tools && \
    cd gcl_tools && \
    npm install -g npm && \
    npm install -g gulp-cli

COPY --chown=machinekit writing_codelabs.md /home/machinekit/gcl_tools/site/codelabs/writing_codelabs.md
COPY --chown=machinekit machinekit-hal.svg /home/machinekit/gcl_tools/site/codelabs/assets/machinekit-hal.svg

RUN cd /home/machinekit/gcl_tools/site && \
    claat-linux-amd64 export codelabs/writing_codelabs.md && \
    npm install

