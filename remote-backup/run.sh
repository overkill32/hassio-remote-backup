#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# parse inputs from options
SSH_HOST=$(jq --raw-output ".ssh_host" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh_user" $CONFIG_PATH)
SSH_KEY=$(jq --raw-output ".ssh_key[]" $CONFIG_PATH)
SSH_PASSWORD=$(jq --raw-output ".ssh_password" $CONFIG_PATH) # todo: not implemented yet
ADDONS_TO_BACKUP=$(jq --raw-output ".addons_to_backup" $CONFIG_PATH)
REMOTE_DIRECTORY=$(jq --raw-output ".remote_directory" $CONFIG_PATH)
ZIP_PASSWORD=$(jq --raw-output ".zip_password" $CONFIG_PATH)
KEEP_LOCAL_BACKUP=$(jq --raw-output ".keep_local_backup" $CONFIG_PATH)

# create variables
SSH_CONFIG="${HOME}/.ssh/config"

function create-ssh-config {
    echo "Creating SSH config."
    mkdir -p ${HOME}/.ssh
    mkdir -p ~/.ssh
    (
        echo "Host remote"
        echo "    IdentityFile ${HOME}/.ssh/id_rsa"
        echo "    HostName ${SSH_HOST}"
        echo "    User ${SSH_USER}"
        echo "    Port ${SSH_PORT}"
        echo "    StrictHostKeyChecking no"
    ) > "${SSH_CONFIG}"

    while read -r line; do
        echo "$line" >> ${HOME}/.ssh/id_rsa
    done <<< "$SSH_KEY"

    chmod 600 "${SSH_CONFIG}"
    chmod 600 "${HOME}/.ssh/id_rsa"
}

function copy-backup-to-remote {

    cd /backup/
    if [[ -z $ZIP_PASSWORD  ]]; then
      echo "Copying ${slug}.tar to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
      scp -F "${SSH_CONFIG}" "${slug}.tar" remote:"${REMOTE_DIRECTORY}" > /dev/null
    else
      echo "Copying password-protected ${slug}.zip to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
      zip -P "$ZIP_PASSWORD" "${slug}.zip" "${slug}".tar > /dev/null
      scp -F "${SSH_CONFIG}" "${slug}.zip" remote:"${REMOTE_DIRECTORY}" > /dev/null && rm "${slug}.zip"
    fi

}

function delete-local-backup {

    hassio snapshots reload > /dev/null

    if [[ ${KEEP_LOCAL_BACKUP} == "all" ]]; then
        :
    elif [[ -z ${KEEP_LOCAL_BACKUP} ]]; then
        echo "Deleting local backup with slug: ${slug}"
        hassio snapshots remove -name "${slug}" > /dev/null
    else
        last_date_to_keep=$(hassio snapshots list | jq .data.snapshots[].date | sort -r | \
            head -n "${KEEP_LOCAL_BACKUP}" | tail -n 1 | xargs date -D "%Y-%m-%dT%T" +%s --date )

        hassio snapshots list | jq -c .data.snapshots[] | while read backup; do
            if [[ $(echo ${backup} | jq .date | xargs date -D "%Y-%m-%dT%T" +%s --date ) -lt ${last_date_to_keep} ]]; then
                echo "Deleting local backup: $(echo ${backup} | jq -r .slug)"
                hassio snapshots remove -name "$(echo ${backup} | jq -r .slug)" > /dev/null
            fi
        done
    fi
}

function create-local-backup {
    if [[ -z $(echo $ADDONS_TO_BACKUP | jq .[]) ]]; then
        name="Automated backup $(date +'%Y-%m-%d %H:%M')"
        slug=$(hassio snapshots new --options name="${name}" | jq --raw-output '.data.slug')
    else
        name="Automated partial backup $(date +'%Y-%m-%d %H:%M')"
        # todo: slug not being returned
        slug=$(curl -X POST -H "X-HASSIO-KEY: $HASSIO_TOKEN" \
                -d '{"name": "${name}", "addons": '"$ADDONS_TO_BACKUP"'}' \
                http://hassio/homeassistant/api/services/hassio/snapshot_partial)
    fi
    echo "${name} created with slug: ${slug}."
}

function run-all {
    create-ssh-config
    create-local-backup
    copy-backup-to-remote
    delete-local-backup
    echo "Backup process succeeded!"; exit 0
}

run-all || { echo "Backup process failed!"; exit 1; }
