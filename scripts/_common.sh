#
# Common Variables
#

APPNAME="ts3server"

# Teamspeak 3 Server version
# TODO: Add mariadb version
TS3S_VERSION="3.13.6"

# TODO: Add dependencies here
# libmariadb

# Remote URL to fetch teamspeak tar.bz2 archive
SOURCE_URL=https://files.teamspeak-services.com/releases/server/${TS3S_VERSION}/teamspeak3-server_linux_ARCH-${TS3S_VERSION}.tar.bz2

# TeamSpeak 3 Server tar.bz2 checksums
# TODO: get url for checksums
declare -A SOURCE_SHA256=( [x86]="f142a215e76feb0e5b9aa36fa37017c109d444ec1b66753465387d575ef39b14" \
						   [amd64]="53704d27826385ddfd803ee232c1d3f021ad9bf18540313691841ad9bb722bec" )


#
# Common Helpers
#

# Download and extract Teamspeak 3 server source
# usage: extract_ts3server ARCH DESTDIR [USER]
extract_ts3server() {
	local ARCH=$1
	local DESTDIR=$2
	local USER=${3:-admin} # make sure parent script has admin var
	
	# Retrieve tar.bz2
	ts3server_src="/tmp/ts3server.tar.bz2"
	rm -f "$ts3server_src"
	
	# Download source and verify checksum
	wget -q -O "$ts3server_src" "$(sed -e "s/ARCH/${ARCH}/g" <<< $SOURCE_URL)" \
	   || ynh_die "Unable to download teamspeak 3 server source."
	echo "${SOURCE_SHA256[${ARCH}]} $ts3server_src" | sha256sum -c >/dev/null \
	   || ynh_die "Invalid checksum of Teamspeak 3 server source."
	
	# Extract source to specified directory
	exec_as "$USER" tar -xjf "$ts3server_src" -C "$DESTDIR" --strip-components 1 \
		|| ynh_die "Unable to extract Teamspeak 3 server source."
	rm -f "$ts3server_src"
}

# Execute a command as another user (sourced from owncloud_ynh)
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval "$@"
  else
    # use sudo twice to be root and be allowed to use another user
    sudo sudo -u "$USER" "$@"
  fi
}
