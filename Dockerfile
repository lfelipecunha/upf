FROM golang:1.14.4-stretch AS builder

LABEL maintainer="Luiz Felipe Cunha"

RUN apt-get update \
    && apt-get install -y libmnl0 libyaml-0-2 iproute2 gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev \
    && apt-get clean

RUN cd $GOPATH/src \
    && git clone --recursive -b v3.0.4 -j 33 https://github.com/free5gc/free5gc.git \
    && cd free5gc \
    && go mod download

RUN rm -rf $GOPATH/src/free5gc/src/upf
COPY . $GOPATH/src/free5gc/src/upf
WORKDIR $GOPATH/src/free5gc/src/upf

RUN make upf

RUN mkdir -p config/ support/TLS/

# Copy executables
RUN cp -r build/bin/* ./

# Copy linked libs
RUN cp build/updk/src/third_party/libgtp5gnl/lib/libgtp5gnl.so.0 /usr/local/lib
RUN cp build/utlt_logger/liblogger.so /usr/local/lib


ENV F5GC_MODULE free5gc-upfd
ENV DEBIAN_FRONTEND noninteractive
ARG DEBUG_TOOLS

# Install debug tools ~ 100MB (if DEBUG_TOOLS is set to true)
RUN if [ "$DEBUG_TOOLS" = "true" ] ; then apt-get update && apt-get install -y vim strace net-tools iputils-ping curl netcat ; fi

VOLUME [ "$GOPATH/src/free5gc/src/upf/config" ]

# Update links
RUN ldconfig
