#!/bin/sh

CONFIG_FILE='/etc/ssh/sshd_config'

echo "> Configuring and starting SSH daemon"

# Add host keys to config file
echo 'HostKey /etc/ssh/keys/ssh_host_rsa_key' >> ${CONFIG_FILE}
echo 'HostKey /etc/ssh/keys/ssh_host_dsa_key' >> ${CONFIG_FILE}
echo 'HostKey /etc/ssh/keys/ssh_host_ecdsa_key' >> ${CONFIG_FILE}
echo 'HostKey /etc/ssh/keys/ssh_host_ed25519_key' >> ${CONFIG_FILE}

# Generate Host keys if is necesary
HOST_KEYS_DIR='/etc/ssh/keys'
if [ ! -d ${HOST_KEYS_DIR} ]; then
    mkdir ${HOST_KEYS_DIR}
fi
if [ ! -f "${HOST_KEYS_DIR}/ssh_host_rsa_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "${HOST_KEYS_DIR}/ssh_host_dsa_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_dsa_key -N '' -t dsa
fi
if [ ! -f "${HOST_KEYS_DIR}ssh_host_ecdsa_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_ecdsa_key -N '' -t ecdsa
fi
if [ ! -f "${HOST_KEYS_DIR}/ssh_host_ed25519_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_ed25519_key -N '' -t ed25519
fi

# Disable SFTP
sed -i 's/Subsystem\tsftp/#Subsystem\tsftp/g' ${CONFIG_FILE}

exec "$@"
