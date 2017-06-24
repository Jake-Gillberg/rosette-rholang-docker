# escape=`
#Working on Windows, set escape character that doesn't interfere with file paths
# (must be first line of dockerfile, which is why this comment is second)

####### VERSIONS #######
FROM ubuntu:trusty

LABEL maintainer "jake.gillberg@gmail.com"

#Non-interactive console during docker build process
ARG DEBIAN_FRONTEND=noninteractive

#Install apt-utils so debconf doesn't complain about configuration for every
# other install
RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
      apt-utils `
  && rm -rf /var/lib/apt/lists/*

# Install rosette
RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
    ca-certificates `
    g++ `
    g++-multilib `
	git `
	make `
  && rm -rf /var/lib/apt/lists/*
  
RUN `
  git clone --depth=1 -b ubuntu-16.04 --single-branch https://github.com/rchain/Rosette

WORKDIR /Rosette
RUN make
WORKDIR /

# Install rholang

RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
    apt-transport-https `
  && rm -rf /var/lib/apt/lists/*

# show apt how to install sbt
RUN `
  echo "deb https://dl.bintray.com/sbt/debian /" `
    > /etc/apt/sources.list.d/sbt.list `
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 `
    --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823

# Java is a dependency of the dependencies
RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
    openjdk-7-jdk `
  && rm -rf /var/lib/apt/lists/*
  
# Install rholang dependencies
RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
    bnfc `
    cup `
	jlex `
	sbt `
  && rm -rf /var/lib/apt/lists/*

# Get and build rholang
RUN `
  git clone --depth=1 --single-branch --branch source-to-source-rosette git://github.com/rchain/Rholang.git
WORKDIR /Rholang
RUN `
  sed -i '/cup/ s]$] from "file:///usr/share/java/cup.jar"]' build.sbt `
  && sed -i '/JLex/ s]$] from "file:///usr/share/java/JLex.jar"]' build.sbt `
  && sbt bnfc:generate `
  && sbt console
WORKDIR /