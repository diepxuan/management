#!/usr/bin/env bash
#!/bin/bash

set -e
# set -u
. $(dirname $(realpath "$BASH_SOURCE"))/head.sh

start_group "put package to buildkite"
regex='.*(.deb)$'
while read -r file; do
    curl -X POST https://api.buildkite.com/v2/packages/organizations/diepxuan/registries/diepxuan/packages \
        -H "Authorization: Bearer $KITE_TOKEN" \
        -F "file=@$dists_dir/$file" || true
done < <(ls $dists_dir/ | grep -E $regex)
end_group
