FROM alpine:latest

RUN apk add --update openssh borgbackup && \
    rm  -rf /tmp/* /var/cache/apk/*

EXPOSE 22

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]