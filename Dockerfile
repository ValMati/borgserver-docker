FROM alpine:latest

RUN apk add --update openssh borgbackup && \
    rm  -rf /tmp/* /var/cache/apk/*

EXPOSE 22

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]c