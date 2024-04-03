#!/usr/bin/env bash

current_dir="$(dirname -- "$(readlink -f -- "$0";)";)"
tmp_dir="$(dirname $current_dir)/tmp"
output_dir="$(dirname $current_dir)/data"
tags_file="$output_dir/tags.json"
output1_file="$output_dir/smapi-game-versions.json"
output2_file="$output_dir/game-smapi-version.json"

echo "current directory: $current_dir"
echo "tmp directory: $tmp_dir"
echo "tags file: $tags_file"
echo "output1 file: $output1_file"
echo "output2 file: $output2_file"

mkdir -p $current_dir
mkdir -p $tmp_dir

if [[ ! -r $tags_file ]]; then
    echo "File $tags_file is not readable, make sure to run get-tags.sh"
    exit 1
fi

input_files=""
tags=$(jq -r '.[]' $tags_file)
while read tag; do
    input_file="$tmp_dir/$tag/versions.json"

    echo "tag is $tag"
    echo "input file is $input_file"

    if [[ ! -r $input_file ]]; then
        echo "input file is not readable, make sure to run extract-versions.sh"
        continue
    fi

    input_files+=" $input_file"
done < <(echo "$tags")

echo "calling jq"

res1=$(jq -s 'map({(.SMAPIVersion): {MinimumGameVersion: .MinimumGameVersion, MaximumGameVersion: .MaximumGameVersion}}) | add' $input_files)

res2=$(jq -s 'map(select(.MinimumGameVersion != null)) | group_by(.MinimumGameVersion) | map({(.[0].MinimumGameVersion): map(.SMAPIVersion)}) | add' $input_files)

echo "done"

echo "$res1" > $output1_file
echo "$res2" > $output2_file
