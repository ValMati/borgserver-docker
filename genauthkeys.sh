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
		clientName=$(basename $f .pub)
        echo 'Adding client '${clientName}
		echo '# '${clientName} >> ${DEST_AUTH_KEYS}
		if [ ${RESTRICT_TO_PATH} == 'true' ]; then
			clientPath='/backups/'${clientName}
			echo -n 'command="cd '${clientPath}'; borg serve --restrict-to-path '${clientPath}'" ' >> ${DEST_AUTH_KEYS}
			if [ ! -e ${clientPath} ]; then
				mkdir ${clientPath}
				chown ${BORG_USER}:${BORG_GROUP} ${clientPath}
			fi
		else
			clientPath='/backups/'
			echo -n 'command="cd '${clientPath}'; borg serve" ' >> ${DEST_AUTH_KEYS}
		fi

		cat ${f} >> ${DEST_AUTH_KEYS}
	done

	chown ${BORG_USER}:${BORG_GROUP} ${DEST_AUTH_KEYS}
}

generate_auth_keys