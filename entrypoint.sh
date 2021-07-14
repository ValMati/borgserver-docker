#!/bin/sh

CONFIG_FILE='/etc/ssh/sshd_config'
HOST_KEYS_DIR='/etc/ssh/host_keys'

echo "> Configuring and starting SSH daemon"

# Add host keys to config file
echo ">> Adding HostKey to paths to" ${CONFIG_FILE}
echo "" >> ${CONFIG_FILE}
echo 'HostKey '${HOST_KEYS_DIR}'/ssh_host_rsa_key' >> ${CONFIG_FILE}
echo 'HostKey '${HOST_KEYS_DIR}'/ssh_host_dsa_key' >> ${CONFIG_FILE}
echo 'HostKey '${HOST_KEYS_DIR}'/ssh_host_ecdsa_key' >> ${CONFIG_FILE}
echo 'HostKey '${HOST_KEYS_DIR}'/ssh_host_ed25519_key' >> ${CONFIG_FILE}

# Generate Host keys if is necesary
echo ">> Generating host keys if is necesary"
if [ ! -d ${HOST_KEYS_DIR} ]; then
    mkdir ${HOST_KEYS_DIR}
fi
if [ ! -f "${HOST_KEYS_DIR}/ssh_host_rsa_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "${HOST_KEYS_DIR}/ssh_host_dsa_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_dsa_key -N '' -t dsa
fi
if [ ! -f "${HOST_KEYS_DIR}/ssh_host_ecdsa_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_ecdsa_key -N '' -t ecdsa
fi
if [ ! -f "${HOST_KEYS_DIR}/ssh_host_ed25519_key" ]; then
	ssh-keygen -f ${HOST_KEYS_DIR}/ssh_host_ed25519_key -N '' -t ed25519
fi

# Disable SFTP
echo ">> Disabling SFTP"
sed -i 's/Subsystem\tsftp/#Subsystem\tsftp/g' ${CONFIG_FILE}

# Create borggroup and borguser without password and home directory
echo ">> Creating borggroup and borguser"
if [[ -z "${GID}" ]] || [[ -z "${UID}" ]]; then
	echo "ERROR: GUI or/and UID should have value"
	exit 0
fi
addgroup borggroup -g ${GID}
adduser borguser -G borggroup -u ${UID} > /dev/null
echo "borguser:" | chpasswd

# Disable password authentication
echo ">> Disabling password authentication"
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' ${CONFIG_FILE}

# Set authorized keys path and permissions
echo ">> Configuring authirized keys"
sed -i 's/AuthorizedKeysFile\t.ssh\/authorized_keys/AuthorizedKeysFile\t\/etc\/authorized_keys\/%u/g' ${CONFIG_FILE}
chmod 755 /etc/authorized_keys
for f in $(find /etc/authorized_keys/ -type f -maxdepth 1); do
	[ -w "${f}" ] && chmod 644 "${f}"
done

# Remove MOTD
echo ">> Removing MOTD"
rm /etc/motd

# Launch daemon
echo ">> Launching daemon"
exec "$@"
