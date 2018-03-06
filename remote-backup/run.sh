#!/bin/bash

CONFIG_PATH=/data/options.json

# parse inputs from options
SSH_HOST=$(jq --raw-output ".ssh_host" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh_user" $CONFIG_PATH)
SSH_KEY=$(jq --raw-output ".ssh_key[]" $CONFIG_PATH)
REMOTE_DIRECTORY=$(jq --raw-output ".remote_directory" $CONFIG_PATH)
REPEAT=$(jq --raw-output '.repeat' $CONFIG_PATH)

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
    echo "Copying ${slug} to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
    scp -F "${HOME}/.ssh/config" "/backup/${slug}.tar" remote:"${REMOTE_DIRECTORY}"
}

function delete-local-backup {
    hassio snapshots remove -name "${slug}"
    echo "Deleted local backup: ${slug}"
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
