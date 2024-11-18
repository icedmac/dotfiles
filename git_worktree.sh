#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat << EOF
Usage: $(basename "$0") [-h] -r <repo_url> -t <worktree_directory> -b <branch_name> [-d <target_directory>]

Options:
  -h, --help                Show this help and exit
  -r, --repo <repo_url>     URL of the Git repository to clone
  -t, --worktree <directory> Worktree directory to create under the main repository directory
  -b, --branch <branch>     Branch to use for creating worktrees (default: main)
  -d, --target <directory>  Target directory to create the bare repository (default: \$HOME/developer)
EOF
  exit 1
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

parse_params() {
  repo_url=""
  worktree_dir=""
  branch="main"
  target_dir="$HOME/developer"

  while :; do
    case "${1-}" in
      -h | --help) usage ;;
      -r | --repo)
        repo_url="${2-}"
        shift
        ;;
      -t | --worktree)
        worktree_dir="${2-}"
        shift
        ;;
      -b | --branch)
        branch="${2-}"
        shift
        ;;
      -d | --target)
        target_dir="${2-}"
        shift
        ;;
      -?*)
        echo "Unknown option: $1"
        usage
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ -z "$repo_url" || -z "$worktree_dir" ]]; then
    echo "Missing or invalid parameters"
    usage
  fi

  return 0
}

parse_params "$@"

# Step 1: Derive the main target directory from the repo URL
repo_name=$(basename -s .git "$repo_url")
target_dir="$target_dir/$repo_name"

# Step 2: Create the target directory if it doesn't exist
mkdir -p "$target_dir"

# Step 3: Clone the repository in bare mode
bare_repo_dir="$target_dir/.bare"

echo "Cloning the repository in bare mode to $bare_repo_dir..."
git clone --bare "$repo_url" "$bare_repo_dir"

# Step 4: Adjust the remote fetch locations
pushd "$bare_repo_dir" > /dev/null
echo "Adjusting origin fetch locations..."
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
popd > /dev/null

# Step 5: Create the .git file in the target directory
echo "Setting .git file for the main repository..."
echo "gitdir: $bare_repo_dir" > "$target_dir/.git"

# Step 6: Move to the target directory before creating the worktree
pushd "$target_dir" > /dev/null

# Step 7: Create the specified worktree for the specified branch
worktree_full_path="$target_dir/$worktree_dir"
echo "Creating worktree at $worktree_full_path..."
git worktree add "$worktree_full_path" "$branch"

popd > /dev/null

echo "All worktrees have been created successfully."
