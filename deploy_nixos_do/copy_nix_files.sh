#!/usr/bin/env bash
# copy_nix_files.sh copies local nix files to the server
#
# Usage: copy_nix_files.sh <nix_config> <host> <port> <private_key> <replacement_configuration_nix_name>
set -euo pipefail

### Defaults ###

# will be set later
sshOpts=(
  -o "ControlMaster=auto"
  -o "ControlPersist=60"
  # Avoid issues with IP re-use. This disable TOFU security.
  -o "StrictHostKeyChecking=no"
  -o "UserKnownHostsFile=/dev/null"
  -o "GlobalKnownHostsFile=/dev/null"
  # interactive authentication is not possible
  -o "BatchMode=yes"
)

###  Argument parsing ###

# beware of escaping nixConfig
nixConfig=$1
targetHost="$2"
targetPort="$3"
sshPrivateKey="$4"
replacementName="$5"

sshOpts+=( -o Port="${targetPort}" )

workDir=$(mktemp -d)
trap 'rm -rf "$workDir"' EXIT

if [[ -n "${sshPrivateKey}" && "${sshPrivateKey}" != "-" ]]; then
  sshPrivateKeyFile="$workDir/ssh_key"
  echo "$sshPrivateKey" > "$sshPrivateKeyFile"
  chmod 0700 "$sshPrivateKeyFile"
  sshOpts+=( -o "IdentityFile=${sshPrivateKeyFile}" )
fi

### Functions ###

log() {
  echo "--- $*" >&2
}

# assumes that passwordless sudo is enabled on the server
targetHostCmd() {
  # ${*@Q} escapes the arguments losslessly into space-separted quoted strings.
  # `ssh` did not properly maintain the array nature of the command line,
  # erroneously splitting arguments with internal spaces, even when using `--`.
  # Tested with OpenSSH_7.9p1.
  #
  # shellcheck disable=SC2029
  ssh "${sshOpts[@]}" "$targetHost" "./maybe-sudo.sh ${*@Q}"
}

# Setup a temporary ControlPath for this session. This speeds-up the
# operations by not re-creating SSH sessions between each command. At the end
# of the run, the session is forcefully terminated.
setupControlPath() {
  sshOpts+=(
    -o "ControlPath=$workDir/ssh_control"
  )
  cleanupControlPath() {
    local ret=$?
    # Avoid failing during the shutdown
    set +e
    # Close ssh multiplex-master process gracefully
    log "closing persistent ssh-connection"
    targetHostCmd rm -rf ${remoteTempDir}
    ssh "${sshOpts[@]}" -O stop "$targetHost"
    rm -rf "$workDir"
    exit "$ret"
  }
  trap cleanupControlPath EXIT
}

### Main ###

setupControlPath

nixConfigFile="configuration.nix.$$"
echo "${nixConfig}" > ${nixConfigFile}
trap 'rm -rf "${nixConfigFile}"' EXIT

remoteTempDir=$(ssh "${sshOpts[@]}" "$targetHost" mktemp -d)
log "Remote temp dir ${remoteTempDir}"

log "Remove /etc/nixos"
targetHostCmd rm -rf /etc/nixos 

log "Copy other nix files"
nix-shell files.nix --arg file "./${nixConfigFile}" | grep -v ${nixConfigFile} | xargs -n 1 -I {} ssh "${sshOpts[@]}" "${targetHost}" mkdir -p ${remoteTempDir}/$(pathname {} 2>/dev/null)
nix-shell files.nix --arg file "./${nixConfigFile}" | grep -v ${nixConfigFile} | xargs -n 1 -I {} scp "${sshOpts[@]}" {} ${targetHost}:${remoteTempDir}/{}
# If there is some collision handle it here
log "Salvage possible configuration.nix"
ssh "${sshOpts[@]}" "${targetHost}" "{ ls ${remoteTempDir}/${replacementName} > /dev/null 2>&1 && exit 1; } || true" # Make sure to fail if there is already some such file
ssh "${sshOpts[@]}" "${targetHost}" "mv -f ${remoteTempDir}/configuration.nix ${remoteTempDir}/${replacementName} || true"
# Make sure real configuration.nix is copied after all other files
log "Copy configuration.nix"
scp "${sshOpts[@]}" "${nixConfigFile}" "${targetHost}:${remoteTempDir}/configuration.nix"
log "Patch configuration.nix references"
ssh "${sshOpts[@]}" "${targetHost}" "find ${remoteTempDir} -type f -print0 | xargs -0 sed -i s@configuration.nix@${replacementName}@g"

log "Atomic swap to /etc/nixos"
targetHostCmd mv -f ${remoteTempDir} /etc/nixos

rm -rf ${nixConfigFile}
