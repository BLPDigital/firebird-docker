FROM ubuntu:18.04

# Install firebird 3.0
RUN apt-get update
RUN apt-get install -y firebird3.0-server firebird3.0-utils

# Install gsutils to download data
ARG CLOUD_SDK_VERSION=274.0.1
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV PATH "$PATH:/opt/google-cloud-sdk/bin/"

RUN apt-get update
RUN apt-get install -y libicu-dev libncurses5 libtommath-dev
RUN apt-get install -y curl apt-transport-https lsb-release
RUN  export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0

# Install fbexport
RUN apt-get install -y g++ make libfbclient2

COPY /fbexport /build/fbexport
WORKDIR /build/fbexport
RUN make
RUN cp exe/fbexport /usr/local/bin
RUN cp exe/fbcopy /usr/local/bin

# Load data to init empty db with meta
RUN mkdir -p /etc/firebird/3.0/init
ADD db_create.sql /etc/firebird/3.0/init
ADD db_meta.sql /etc/firebird/3.0/init
ADD db_auth.sql /etc/firebird/3.0/init

# ARGS
ARG FIREBIRD_DATABASE="28dc98d6-4df0-5e57-bf3b-ea36413990b3"
ENV FIREBIRD_DATABASE=$FIREBIRD_DATABASE

VOLUME ["/firebird"]

# Download data
COPY download_data.sh /usr/local/bin/download_data.sh
RUN chmod +x /usr/local/bin/download_data.sh

# Create database
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
