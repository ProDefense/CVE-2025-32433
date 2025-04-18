FROM debian:bookworm

WORKDIR /build

RUN apt-get update && apt-get install -y \
  git build-essential libssl-dev autoconf libncurses5-dev \
  libgl1-mesa-dev libglu1-mesa-dev libpng-dev \
  libssh-dev libxml2-utils xsltproc fop wget curl \
  openssh-client

# Clone and build Erlang/OTP 26.2.5.11
RUN git clone https://github.com/erlang/otp.git && \
    cd otp && \
    git checkout OTP-26.2.5.10 && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install

WORKDIR /root

COPY ssh_server.erl .
RUN erlc ssh_server.erl

# Generate RSA key in PEM format that Erlang understands
RUN mkdir -p /root/ssh_keys && \
    ssh-keygen -m PEM -t rsa -b 2048 -f /root/ssh_keys/ssh_host_rsa_key -N "" && \
    ssh-keygen -y -f /root/ssh_keys/ssh_host_rsa_key > /root/ssh_keys/ssh_host_rsa_key.pub

EXPOSE 2222

CMD ["erl", "-noshell", "-pa", ".", "-s", "ssh_server", "start"]
