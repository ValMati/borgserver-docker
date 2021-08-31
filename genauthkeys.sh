#!/bin/sh

generate_auth_keys() {
	echo ">> Configuring authorized keys"
	SOURCE_AUTH_KEYS='/etc/authorized_keys'
	DEST_AUTH_PATH='/home/'${BORG_USER}'/.ssh'
	DEST_AUTH_KEYS=${DEST_AUTH_PATH}'/authorized_keys'
	if [ ! -e "${DEST_AUTH_PATH}" ]; then
		mkdir ${DEST_AUTH_PATH}
		chown ${BORG_USER}:${BORG_GROUP} ${DEST_AUTH_PATH}
	else
		rm ${DEST_AUTH_KEYS}
	fi
	for f in ${SOURCE_AUTH_KEYS}/*.pub; do
		CLIENT_NAME=$(basename $f .pub)
		CLIENT_BACKUP_PATH='/backups/'${CLIENT_NAME}
        echo 'Adding client '${CLIENT_NAME}
		echo '# '${CLIENT_NAME} >> ${DEST_AUTH_KEYS}
		if [ ${RESTRICT_TO_PATH} ]; then
			echo -n 'command="cd '${CLIENT_BACKUP_PATH}'; borg serve --restrict-to-path '${CLIENT_BACKUP_PATH}'" ' >> ${DEST_AUTH_KEYS}
			if [ ! -e ${CLIENT_BACKUP_PATH} ]; then
				mkdir ${CLIENT_BACKUP_PATH}
				chown ${BORG_USER}:${BORG_GROUP} ${CLIENT_BACKUP_PATH}
			fi
		fi
		cat ${f} >> ${DEST_AUTH_KEYS}
	done
	chown ${BORG_USER}:${BORG_GROUP} ${DEST_AUTH_KEYS}
}

generate_auth_keys