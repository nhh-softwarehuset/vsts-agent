FROM ubuntu:16.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        apt-utils \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl3 \
        libicu55 \
        wget \
        dnsutils \
        file \
        ftp \
        iproute2 \
        iputils-ping \
        locales \
        openssh-client \
        rsync\
        shellcheck \
        sudo \
        telnet \
        time \
        unzip \
        wget \
        zip \
        tzdata \
        apt-transport-https \
        build-essential

# Setup the locale
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
RUN locale-gen $LANG \
 && update-locale

# Accept EULA - needed for certain Microsoft packages like SQL Server Client Tools
ENV ACCEPT_EULA=Y

# Install Ansible
RUN apt-get update \   
 && apt-get install -y --no-install-recommends \
    ansible \      
 && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*
ENV CHROME_BIN /usr/bin/google-chrome

# Install Haskell
RUN apt-get update \
 && apt-get install -y haskell-platform \
 && rm -rf /var/lib/apt/lists/*

# Install Helm
RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl

# Install Miniconda
RUN curl -sL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
 && chmod +x miniconda.sh \
 && ./miniconda.sh -b -p /usr/share/miniconda \
 && rm miniconda.sh
ENV CONDA=/usr/share/miniconda

# Install Powershell Core

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
 && curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/microsoft.list \
 && apt-get update

RUN apt-get install -y --no-install-recommends powershell

# Install .NET Core SDK and initialize package cache
RUN apt-get install -y --no-install-recommends dotnet-sdk-2.2
RUN dotnet help
ENV dotnet=/usr/bin/dotnet


# Install LTS Node.js and related tools
RUN curl -sL https://git.io/n-install | bash -s -- -ny - \
 && ~/n/bin/n lts \
 && npm install -g bower \
 && npm install -g grunt \
 && npm install -g gulp \
 && npm install -g n \
 && npm install -g webpack webpack-cli --save-dev \
 && npm install -g parcel-bundler \
 && npm i -g npm \
 && rm -rf ~/n
ENV bower=/usr/local/bin/bower \
    grunt=/usr/local/bin/grunt

# Install PhantomJS
RUN apt-get update \
 && apt-get install -y chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev \
 && rm -rf /var/lib/apt/lists/* \
 && export PHANTOM_JS=phantomjs-2.1.1-linux-x86_64 \
 && wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
 && tar xvjf $PHANTOM_JS.tar.bz2 \
 && mv $PHANTOM_JS /usr/local/share \
 && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

# Install Go
RUN GO_VERSION='go1.12.6' \
 && curl -sL https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz -o ${GO_VERSION}.linux-amd64.tar.gz \
 && mkdir -p /usr/local/${GO_VERSION} \
 && tar -C /usr/local/${GO_VERSION} -xzf ${GO_VERSION}.linux-amd64.tar.gz --strip-components=1 go \
 && rm ${GO_VERSION}.linux-amd64.tar.gz
ENV GOROOT_1_12_X64=/usr/local/${GO_VERSION} \
    GOROOT=/usr/local/go1.12
ENV PATH $PATH:$GOROOT/bin

# Instally PyPy2
RUN wget -q -P /tmp https://bitbucket.org/pypy/pypy/downloads/pypy2-v6.0.0-linux64.tar.bz2 \
 && tar -x -C /opt -f /tmp/pypy2-v6.0.0-linux64.tar.bz2 \
 && rm /tmp/pypy2-v6.0.0-linux64.tar.bz2 \
 && mv /opt/pypy2-v6.0.0-linux64 /opt/pypy2 \
 && ln -s /opt/pypy2/bin/pypy /usr/local/bin/pypy

# Install PyPy3
RUN wget -q -P /tmp https://bitbucket.org/pypy/pypy/downloads/pypy3-v6.0.0-linux64.tar.bz2 \
 && tar -x -C /opt -f /tmp/pypy3-v6.0.0-linux64.tar.bz2 \
 && rm /tmp/pypy3-v6.0.0-linux64.tar.bz2 \
 && mv /opt/pypy3-v6.0.0-linux64 /opt/pypy3 \
 && ln -s /opt/pypy3/bin/pypy3 /usr/local/bin/pypy3

# Install Python
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    python \
    python-pip \
    python3 \
    python3-pip \
&& rm -rf /var/lib/apt/lists/*


# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends yarn \
 && rm -rf /var/lib/apt/lists/* \
&& rm -rf /etc/apt/sources.list.d/*

# Install Terraform TODO:UPDATE to v 12
#RUN TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version) \
RUN TERRAFORM_VERSION='0.11.14' \
 && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
 && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
 && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Clean system
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
&& rm -rf /etc/apt/sources.list.d/*

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]