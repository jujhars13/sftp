FROM debian:13-slim

LABEL org.opencontainers.image.description="SFTP server in a container"
LABEL org.opencontainers.image.title="SFTP server"
LABEL org.opencontainers.image.version="1.5.0"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/jujhars13/sftp"
LABEL org.opencontainers.image.authors="Jujhar Singh <jujhar.com>"

# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get update && \
    apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /
COPY README.md /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
