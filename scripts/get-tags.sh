#!/usr/bin/env bash

repo_owner="${REPO_OWNER:-Pathoschild}"
repo_name="${REPO_NAME:-SMAPI}"

echo "repo owner: $repo_owner"
echo "repo name: $repo_name"

current_dir="$(dirname -- "$(readlink -f -- "$0";)";)"
tmp_dir="$(dirname $current_dir)/tmp"
output_dir="$(dirname $current_dir)/data"
output_file="$output_dir/tags.json"

echo "current directory: $current_dir"
echo "tmp directory: $tmp_dir"
echo "output file: $output_file"

mkdir -p $current_dir
mkdir -p $tmp_dir
mkdir -p $output_dir

echo "getting tags"

page=1
tags_array='[]'

while true; do
    url="https://api.github.com/repos/$repo_owner/$repo_name/releases?page=$page"
    echo "page is $page"
    echo "url is $url"

    if [[ -z "$GITHUB_TOKEN" ]]; then
        response=$(curl -sL "$url")
    else
        response=$(curl -sL --header "Authorization: Bearer $GITHUB_TOKEN" "$url")
    fi

    tags=$(echo "$response" | jq '.[].tag_name' | jq -s .)
    echo "tags: $tags"

    if [ -z "$tags" ] || [ "$tags" = "[]" ]; then
        echo "break"
        break
    fi

    tags_array=$(echo "$tags_array$tags" | jq -s '.[0] + .[1]' )
    page=$((page + 1))

    echo "$tags_array" > $output_file
    echo "sleep for 1s"
    sleep 1s
done

echo "$tags_array" > $output_file
echo "done"
