# SMAPI/Stardew Valley Compatibility Matrix

## Data

- [`tags.json`](./data/tags.json): JSON array with all SMAPI releases
- [`smapi-game-versions.json`](./smapi-game-versions.json): JSON object that maps SMAPI versions to minimum and maximum game versions it supports
- [`game-smapi-versions.json`](./game-smapi-versions.json): JSON object that maps game versions to minimum SMAPI versions

## Generate data

1) [`get-tags.sh`](./scripts/get-tags.sh): Gets all release tags from the GitHub API.
2) [`get-files.sh`](./scripts/get-files.sh): Downloads all files uses the previous step.
3) [`extract-versions.sh`](./scripts/extract-versions.sh): Extract all versions from the files of the previous step.
4) [`merge-data.sh`](./scripts/merge-data.sh): Merges all versions from the previous step.
