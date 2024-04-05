#!/usr/bin/env bash

repo_owner="${REPO_OWNER:-Pathoschild}"
repo_name="${REPO_NAME:-SMAPI}"

echo "repo owner: $repo_owner"
echo "repo name: $repo_name"

current_dir="$(dirname -- "$(readlink -f -- "$0";)";)"
tmp_dir="$(dirname $current_dir)/tmp"
output_dir="$(dirname $current_dir)/data"
tags_file="$output_dir/tags.json"

echo "current directory: $current_dir"
echo "tmp directory: $tmp_dir"
echo "tags file: $tags_file"

mkdir -p $current_dir
mkdir -p $tmp_dir

if [[ ! -r $tags_file ]]; then
    echo "File $tags_file is not readable, make sure to run get_tags.sh"
    exit 1
fi

jq -r .[] $tags_file | while read tag; do
    output_file="$tmp_dir/$tag/Constants.cs"
    mkdir -p $(dirname "$output_file")

    url="https://github.com/$repo_owner/$repo_name/raw/$tag/src/SMAPI/Constants.cs" 

    echo "tag is $tag"
    echo "output file is $output_file"
    echo "url is $url"

    if [[ -r $output_file ]]; then
        echo "file already exists, skipping"
        continue
    fi

    if [[ -z "$GITHUB_TOKEN" ]]; then
        curl -sL "$url" -o "$output_file"
    else
        curl -sL --header "Authorization: Bearer $GITHUB_TOKEN" "$url" -o "$output_file"
    fi

    sleep 1
done

