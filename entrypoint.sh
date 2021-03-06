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

# Generate host keys if is necesary
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
echo ">> Creating borg group and borg user"
if [[ -z "${GID}" ]] || [[ -z "${UID}" ]]; then
	echo "ERROR: GUI or/and UID should have value"
	exit 0
fi
addgroup ${BORG_GROUP} -g ${GID}
adduser ${BORG_USER} -G ${BORG_GROUP} -u ${UID} > /dev/null
echo "${BORG_USER}:" | chpasswd

# Disable password authentication
echo ">> Disabling password authentication"
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' ${CONFIG_FILE}

# Set authorized keys
source /bin/genauthkeys.sh

# Remove MOTD
echo ">> Removing MOTD"
rm /etc/motd

# Launch daemon
echo ">> Launching daemon"
exec "$@"
