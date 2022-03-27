FROM alpine:3.15.2

RUN apk add --update openssh borgbackup tzdata py3-pip && \
    rm  -rf /tmp/* /var/cache/apk/*

EXPOSE 22

ENV BORG_GROUP='borggroup'
ENV BORG_USER='borguser'

COPY entrypoint.sh genauthkeys.sh /bin/

ENTRYPOINT [ "/bin/entrypoint.sh" ]

CMD [ "/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config" ]
