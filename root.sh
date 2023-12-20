#!/usr/bin/env bash

set -eu

BASE="$(dirname "$0")"
cd "$BASE"

meta_out() {
    jo "$@" >&4
    exec 4>&-
}

META="$(cat <&3)"
P="$(jq -r .path <<<"$META")"
METHOD="$(jq -r .method <<<"$META")"
CLIENT="$(jq -r '"\(.remote_ip):\(.remote_port)"' <<<"$META")"

if [[ "$METHOD" == "GET" && "$P" == "/" ]]; then
    meta_out headers="$(jo "content-type"="text/html")"
    jo request="$META" | tera -i --template html/index.html --stdin
    exit
fi

if [[ "$METHOD" == "POST" && "$P" == "/message" ]]; then
    meta_out headers="$(jo "content-type"="text/html")"
    echo '<li><mark>'"$CLIENT"'</mark>'$(jq -r .message)'</li>' >>"$STORE"/messages.html
    cat html/input.html
    exit
fi

meta_out status=404 headers="$(jo "content-type"="text/html")"
echo "Not Found:" $METHOD $P
