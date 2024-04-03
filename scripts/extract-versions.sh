#!/usr/bin/env bash

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
    echo "File $tags_file is not readable, make sure to run get-tags.sh"
    exit 1
fi

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
version_regex="(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?"

jq -r .[] $tags_file | while read tag; do
    input_file="$tmp_dir/$tag/Constants.cs"
    output_file="$tmp_dir/$tag/versions.json"

    echo "tag is $tag"
    echo "input file is $input_file"
    echo "output file is $output_file"

    if [[ ! -r $input_file ]]; then
        echo "input file is not readable, make sure to run get-files.sh"
        continue
    fi

    if [[ -r $output_file ]]; then
        echo "file already exists, skipping"
        continue
    fi

    minimum_game_version=$(grep -o 'MinimumGameVersion.*;' $input_file | grep -Po "$version_regex")
    maximum_game_version=$(grep -o 'MaximumGameVersion.*;' $input_file | grep -Po "$version_regex")

    echo "min game version: $minimum_game_version"
    echo "max game version: $maximum_game_version"

    if [[ -z $minimum_game_version ]]; then
        minimum_game_version="null"
    else
        minimum_game_version="\"$minimum_game_version\""
    fi

    if [[ -z $maximum_game_version ]]; then
        maximum_game_version="null"
    else
        maximum_game_version="\"$minimum_game_version\""
    fi

    echo "{ \"SMAPIVersion\": \"$tag\", \"MinimumGameVersion\": $minimum_game_version, \"MaximumGameVersion\": $maximum_game_version }" | jq -s '.[0]' > $output_file
done

