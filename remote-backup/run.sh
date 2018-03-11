#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# parse inputs from options
SSH_HOST=$(jq --raw-output ".ssh_host" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh_user" $CONFIG_PATH)
SSH_KEY=$(jq --raw-output ".ssh_key[]" $CONFIG_PATH)
REMOTE_DIRECTORY=$(jq --raw-output ".remote_directory" $CONFIG_PATH)
ZIP_PASSWORD=$(jq --raw-output '.zip_password' $CONFIG_PATH)
KEEP_LOCAL_BACKUP=$(jq --raw-output '.keep_local_backup' $CONFIG_PATH)

# create variables
SSH_ID="${HOME}/.ssh/id"

function add-ssh-key {
    echo "Adding SSH key"
    mkdir -p ~/.ssh
    (
        echo "Host remote"
        echo "    IdentityFile ${HOME}/.ssh/id"
        echo "    HostName ${SSH_HOST}"
        echo "    User ${SSH_USER}"
        echo "    Port ${SSH_PORT}"
        echo "    StrictHostKeyChecking no"
    ) > "${HOME}/.ssh/config"

    while read -r line; do
        echo "$line" >> ${HOME}/.ssh/id
    done <<< "$SSH_KEY"

    chmod 600 "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/id"
}

function copy-backup-to-remote {

    cd /backup/
    if [[ -z $ZIP_PASSWORD  ]]; then
      echo "Copying ${slug}.tar to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
      scp -F "${HOME}/.ssh/config" "${slug}.tar" remote:"${REMOTE_DIRECTORY}"
    else
      echo "Copying password-protected ${slug}.zip to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
      zip -P "$ZIP_PASSWORD" "${slug}.zip" "${slug}".tar
      scp -F "${HOME}/.ssh/config" "${slug}.zip" remote:"${REMOTE_DIRECTORY}" && rm "${slug}.zip"
    fi

}

function delete-local-backup {

    hassio snapshots reload

    if [[ ${KEEP_LOCAL_BACKUP} == "all" ]]; then
        :
    elif [[ -z ${KEEP_LOCAL_BACKUP} ]]; then
        echo "Deleting local backup: ${slug}"
        hassio snapshots remove -name "${slug}"
    else

        last_date_to_keep=$(hassio snapshots list | jq .data.snapshots[].date | sort -r | \
            head -n "${KEEP_LOCAL_BACKUP}" | tail -n 1 | xargs date -D "%Y-%m-%dT%T" +%s --date )

        hassio snapshots list | jq -c .data.snapshots[] | while read backup; do
            if [[ $(echo ${backup} | jq .date | xargs date -D "%Y-%m-%dT%T" +%s --date ) -lt ${last_date_to_keep} ]]; then
                echo "Deleting local backup: $(echo ${backup} | jq -r .slug)"
                hassio snapshots remove -name "$(echo ${backup} | jq -r .slug)"
            fi
        done

    fi
}

function create-local-backup {
    name="Automated backup $(date +'%Y-%m-%d %H:%M')"
    echo "Creating local backup: \"${name}\""
    slug=$(hassio snapshots new --options name="${name}" | jq --raw-output '.data.slug')
    echo "Backup created: ${slug}"
}


add-ssh-key
create-local-backup
copy-backup-to-remote
delete-local-backup

echo "Backup process done!"
exit 0
