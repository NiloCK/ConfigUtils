# creates a dirlist with parent directory names truncated to single character

# eg, ~/dev/colin/someDir becomes ~/d/c/someDir

# function directories(){
#    echo $(echo $(dirs +0) | sed 's/\B[^\/~]\*\//\//g')
# }
# function directories(){
#   echo $(echo $(dirs +0) | sed 's/\([^/]\)[^/]*/\1/g')
# }

function directories() {
    # Fetch the current directory path
    current_path=$(dirs +0)

    # Separate the path into base (all but last directory) and last directory
    base_path=$(dirname "$current_path")
    last_dir=$(basename "$current_path")

    # Simplify the base path by collapsing each directory to its first character
    simplified_base=$(echo "$base_path" | sed 's/\([^/]\)[^/]*/\1/g')

    # Combine the simplified base path with the last directory
    echo "${simplified_base}/${last_dir}"
}



PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\[\033[00m\]\[\033[01;34m\]$(directories)\[\033[00m\]$(\_\_git_ps1)\$ '

bind TAB:menu-complete

function countdown(){
date1=$((`date +%s` + $1));
   while [ "$date1" -ge `date +%s` ]; do
echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
     sleep 0.1
   done
}
function stopwatch(){
  date1=`date +%s`;
   while true; do
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
sleep 0.1
done
}

function gri() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    # If the input is a number, calculate HEAD~(N+2)
    git rebase --interactive "HEAD~$(( $1 + 2 ))"
  elif [[ $1 =~ ^[a-f0-9]{7,40}$ ]]; then
    # If the input is a hash (checking for typical hash length and characters)
    git rebase --interactive "$1"
  else
    echo "Error: Argument must be an integer or a valid commit hash."
  fi
}


export CDPATH=$CDPATH:/home/colin

alias serve=http-server
alias metro="metronome.sh 60 10"
alias xo=xdg-open
alias l="ls -hlX"
alias y="grep -Pzo \"(?s)\"scripts.\*?\}\" package.json"
alias lg=lazygit

alias gl="git log"
alias glg="git log --graph"
alias glo="git log --oneline"
alias glog="git log --oneline --graph"
alias gbl="git for-each-ref --sort=-committerdate refs/heads/ --format='%(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"

alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"
alias ......="cd ../../../../../"
alias .......="cd ../../../../../../"

# remove tmp items older than 5 days, then restore ~/tmp if it itself was deleted

find ~/tmp -mtime +5 -exec rm -rf {} \;
mkdir ~/tmp &>/dev/null

# old cleartmp script - remove if new one works well
#
# find ~/tmp -mtime +5 -print -exec echo "Slated for deletion: {}" \;
#  -exec echo {} >> ~/tmp/.todelete \;
#  -exec rm -rf {} \;

if [ -f $HOME/.bash_cleartmp ]; then
  . $HOME/.bash_cleartmp
fi


#############################
#  Command Copying Utility  #
#############################

# # Add to ~/.bashrc
#
# # Ensure history directory exists
# mkdir -p ~/.cmd_history/commands
#
# # Skip setup if running inside tmux
# if [ -n "$TMUX" ]; then
#     # Optional: Print a message during shell startup (remove if not wanted)
#     # echo "Command logging disabled in tmux session"
#     return 0 2>/dev/null || exit 0
# fi
#
# # Track command execution and output
# function execute_and_log() {
#     # Get the current command from history
#     local cmd=$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//")
#
#     # Skip our utility commands and empty commands
#     if [[ "$cmd" =~ ^c[0-9]+ || -z "$cmd" ]]; then
#         return
#     fi
#
#     # Create unique filename with timestamp
#     local timestamp=$(date +%Y%m%d_%H%M%S)
#     local log_file=~/.cmd_history/commands/${timestamp}_$$_${RANDOM}.log
#
#     # Record metadata
#     echo -e "# Working directory: $(pwd)\n# Time: $(date '+%Y-%m-%d %H:%M:%S')\n$ $cmd" > "$log_file"
#
#     # Capture command output
#     eval "$cmd" 2>&1 | tee -a "$log_file"
#
#     # Save exit code and completion time
#     local exit_code=${PIPESTATUS[0]}
#     echo -e "\n# Exit code: $exit_code\n# Completed: $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
#
#     # Return the original exit code
#     return $exit_code
# }
#
# # Set up as a trap for command execution
# trap 'execute_and_log' DEBUG
#
# # Function to copy the most recent command(s)
# function cn() {
#     local n=${1:-1}
#     local combined=""
#
#     # Get the most recent n command files
#     local files=$(ls -t ~/.cmd_history/commands/ 2>/dev/null | head -n $n)
#
#     if [[ -z "$files" ]]; then
#         echo "No command history found."
#         return 1
#     fi
#
#     # Process files in reverse order (oldest first)
#     for file in $(echo "$files" | tac); do
#         if [[ -f ~/.cmd_history/commands/"$file" ]]; then
#             # Add file content to combined output
#             combined+=$(cat ~/.cmd_history/commands/"$file")
#             combined+="\n\n"
#         fi
#     done
#
#     # Copy to clipboard
#     echo -e "$combined" | xclip -selection clipboard
#     echo "Copied last $n commands and their outputs to clipboard."
# }
#
# # Aliases for convenience
# alias c1='cn 1'
# alias c2='cn 2'
# alias c3='cn 3'
# alias c4='cn 4'
# alias c5='cn 5'
#
# # Clean older files periodically (keeps last 1000)
# find ~/.cmd_history/commands/ -type f -mtime +30 -delete 2>/dev/null
# ls -t ~/.cmd_history/commands/ | tail -n +1001 | xargs -I {} rm ~/.cmd_history/commands/{} 2>/dev/null

#############################
# /Command Copying Utility  #
#############################


#####################
# Worktree Utility  #
#####################

# Helper for logging - consider making these unique if adding to a shared bashrc
# to avoid conflicts, e.g., __colin_rmt_log
_rmt_log() { echo "[rmt] $1"; }
_rmt_err() { echo >&2 "[rmt] ERROR: $1"; }

function rmt() {
    local branch_name="$1"
    if [ -z "$branch_name" ]; then
        _rmt_err "Usage: rmt <branch_name>"
        _rmt_log "Removes the Git worktree directory and branch for <branch_name>."
        _rmt_log "Ensures commits are merged into main/master/trunk/develop first."
        return 1
    fi

    # --- Determine git_context_dir (any worktree in the repo) and paths ---
    local git_context_dir=""
    local worktree_parent_dir=""
    local original_cwd=$(pwd) # Not strictly used here but good practice from nt

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        git_context_dir=$(git rev-parse --show-toplevel)
        if [ -z "$git_context_dir" ]; then
            _rmt_err "Could not determine Git repository top-level from current directory $(pwd)."
            return 1
        fi
        _rmt_log "Operating relative to Git repository context: $git_context_dir"
    else
        _rmt_log "Not currently inside a Git repository. Checking for 'main', 'master', or 'trunk' subdirectories in $(pwd)..."
        local found_project_subdir=false
        for subdir_name in main master trunk; do
            if [ -d "./$subdir_name" ]; then
                # Use a subshell to cd and run git command
                local potential_repo_dir
                potential_repo_dir=$( (cd "./$subdir_name" && git rev-parse --show-toplevel) 2>/dev/null)

                if [ -n "$potential_repo_dir" ]; then
                    git_context_dir="$potential_repo_dir" # This will be an absolute path
                    _rmt_log "Found Git repository context via subdirectory './$subdir_name'. Context: $git_context_dir"
                    found_project_subdir=true
                    break
                fi
            fi
        done
        if ! $found_project_subdir; then
            _rmt_err "Not in a Git repository and no 'main', 'master', or 'trunk' subdirectory in $(pwd) appears to be a Git repository."
            return 1
        fi
    fi

    # Ensure git_context_dir is an absolute path
    git_context_dir=$(readlink -f "$git_context_dir")
    worktree_parent_dir=$(dirname "$git_context_dir")
    local target_worktree_path="$worktree_parent_dir/$branch_name"

    # --- Validations ---
    if [ "$target_worktree_path" == "$git_context_dir" ]; then
        _rmt_err "Cannot remove the worktree '$branch_name' because its path ($target_worktree_path) is the same as the current git context directory."
        _rmt_log "This typically means you're trying to remove the main/master/trunk worktree itself, or the branch name matches the current worktree's directory name."
        return 1
    fi

    # Check if the branch exists in the repository
    if ! git -C "$git_context_dir" rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        _rmt_err "Branch '$branch_name' does not exist in the repository (context: '$git_context_dir')."
        if [ -d "$target_worktree_path" ]; then
            _rmt_log "Note: A directory exists at '$target_worktree_path', but no corresponding branch '$branch_name' was found."
        fi
        return 1
    fi
    _rmt_log "Branch '$branch_name' found in repo (context: '$git_context_dir')."

    # Check if the target worktree directory exists
    if [ ! -d "$target_worktree_path" ]; then
        _rmt_err "Worktree directory '$target_worktree_path' does not exist."
        _rmt_log "If you only want to delete the branch '$branch_name' (after merge checks), do it manually."
        return 1
    fi
    _rmt_log "Worktree directory to remove: '$target_worktree_path'."

    # --- Identify and Update Primary Branch ---
    local primary_branch=""
    for pb_candidate in main master trunk develop; do
        if git -C "$git_context_dir" rev-parse --verify "$pb_candidate" >/dev/null 2>&1; then
            primary_branch="$pb_candidate"
            break
        fi
    done

    if [ -z "$primary_branch" ]; then
        _rmt_err "Could not determine a primary branch (main, master, trunk, develop) in context '$git_context_dir'."
        _rmt_log "Cannot perform merge safety check."
        return 1
    fi
    _rmt_log "Using '$primary_branch' as the primary branch for merge checks."

    _rmt_log "Updating '$primary_branch' in context '$git_context_dir'..."
    local current_branch_in_context_repo
    current_branch_in_context_repo=$(git -C "$git_context_dir" symbolic-ref --short HEAD 2>/dev/null)
    local switched_branch_in_context=false

    if [ "$current_branch_in_context_repo" != "$primary_branch" ]; then
        _rmt_log "Temporarily switching context repo to '$primary_branch'..."
        if ! git -C "$git_context_dir" checkout "$primary_branch"; then
            _rmt_err "Failed to switch context repo to '$primary_branch'. Aborting update and merge check."
            if [ -n "$current_branch_in_context_repo" ]; then
                 git -C "$git_context_dir" checkout "$current_branch_in_context_repo" # Best effort
            fi
            return 1
        fi
        switched_branch_in_context=true
    fi

    if ! git -C "$git_context_dir" pull --ff-only; then
        _rmt_err "Failed to pull latest changes for '$primary_branch' using --ff-only in '$git_context_dir'."
        _rmt_log "The primary branch may have diverged from its remote. Please resolve this manually."
        if $switched_branch_in_context && [ -n "$current_branch_in_context_repo" ]; then
            git -C "$git_context_dir" checkout "$current_branch_in_context_repo" # Switch back
        fi
        return 1
    fi
    _rmt_log "'$primary_branch' updated."

    # Switch context repo back now that primary_branch is updated, before merge check.
    if $switched_branch_in_context && [ -n "$current_branch_in_context_repo" ]; then
        _rmt_log "Switching context repo back to '$current_branch_in_context_repo'..."
        if ! git -C "$git_context_dir" checkout "$current_branch_in_context_repo"; then
            _rmt_err "Failed to switch context repo back to '$current_branch_in_context_repo'. Current branch in '$git_context_dir' is '$primary_branch'."
            # This is not fatal for rmt's operation, but user should be aware.
        fi
    fi

    # --- Safety Check: Commits Merged ---
    _rmt_log "Checking if branch '$branch_name' is fully merged into '$primary_branch'..."
    local unmerged_commits
    # Lists commits reachable from branch_name but not from primary_branch
    unmerged_commits=$(git -C "$git_context_dir" rev-list "${primary_branch}..${branch_name}")

    if [ -n "$unmerged_commits" ]; then
        _rmt_err "Branch '$branch_name' has commits not merged into '$primary_branch'."
        _rmt_log "Unmerged commits (shown from '$git_context_dir'):"
        git -C "$git_context_dir" log --oneline --graph "${primary_branch}..${branch_name}"
        _rmt_log "Please merge or rebase '$branch_name' onto '$primary_branch', or delete manually if intended."
        return 1
    fi
    _rmt_log "Branch '$branch_name' is fully merged into '$primary_branch'."

    # --- Perform Cleanup ---
    _rmt_log "Attempting to remove worktree for '$branch_name' at '$target_worktree_path'..."
    # Using --force to ensure directory removal, aligning with "rm -rf" intent.
    # `git worktree remove` can take the path or (if conventional) the branch name. Path is more explicit.
    if git -C "$git_context_dir" worktree remove --force "$target_worktree_path"; then
        _rmt_log "Git worktree at '$target_worktree_path' removed successfully."
    else
        _rmt_err "Command 'git worktree remove --force \"$target_worktree_path\"' failed."
        _rmt_log "This might happen if '$target_worktree_path' wasn't a registered worktree or due to other issues."
        _rmt_log "As per 'rm -rf' intent, will now attempt to remove the directory if it still exists."
        if [ -d "$target_worktree_path" ]; then
            _rmt_log "Forcefully removing directory '$target_worktree_path'..."
            if rm -rf "$target_worktree_path"; then
                _rmt_log "Directory '$target_worktree_path' removed."
            else
                _rmt_err "Failed to remove directory '$target_worktree_path'. Manual cleanup needed for the directory."
                # Continue to attempt branch deletion
            fi
        else
             _rmt_log "Directory '$target_worktree_path' no longer exists or was not there."
        fi
    fi

    _rmt_log "Attempting to delete local branch '$branch_name'..."
    if git -C "$git_context_dir" branch -d "$branch_name"; then
        _rmt_log "Branch '$branch_name' deleted successfully."
    else
        _rmt_err "Failed to delete branch '$branch_name' using 'git branch -d'."
        _rmt_log "This can happen if it's the current branch in '$git_context_dir' or not considered fully merged by HEAD's standards there."
        _rmt_log "The previous check confirmed it was merged into '$primary_branch'."
        _rmt_log "If needed, you may use 'git -C \"$git_context_dir\" branch -D \"$branch_name\"' or switch branches in '$git_context_dir'."
        return 1 # Indicate partial failure if branch deletion failed
    fi

    _rmt_log "Successfully removed worktree directory and branch for '$branch_name'."
    echo ""
    echo "--------------------------------------------------------------------"
    echo "Worktree and branch '$branch_name' removed."
    echo "  Repository Context: $git_context_dir"
    echo "  Removed Worktree:   $target_worktree_path"
    echo "  Removed Branch:     $branch_name (was merged into $primary_branch)"
    echo "--------------------------------------------------------------------"
    echo ""
    return 0
}

# Create a new worktree
function nt() {
    if [ -z "$1" ]; then
        echo "Usage: nt <branch_name>"
        echo "Creates a new Git branch and an adjacent worktree."
        return 1
    fi
    local branch_name="$1"

    # Basic validation for branch name to avoid issues with path construction.
    # Git has more complex rules, but this catches common problematic cases for paths.
    if [[ "$branch_name" =~ [/[:space:]] || "$branch_name" == ".." || "$branch_name" == "." ]]; then
        echo "Error: branch_name cannot contain slashes, spaces, or be '.' or '..'."
        return 1
    fi

    local original_cwd=$(pwd)
    local repo_dir="" # This will be the absolute path to the top-level directory of the Git repository.

    # Attempt to find the Git repository root
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        # We are inside a Git repository. Find its top-level directory.
        repo_dir=$(git rev-parse --show-toplevel)
        if [ -z "$repo_dir" ]; then
            echo "Error: Could not determine Git repository top-level from current directory $(pwd)."
            echo "The 'git rev-parse --show-toplevel' command failed."
            return 1
        fi
        echo "Operating relative to Git repository: $repo_dir"
    else
        # Not inside a Git repository. Check for 'main', 'master', or 'trunk' subdirectories.
        echo "Not currently inside a Git repository. Checking for 'main', 'master', or 'trunk' subdirectories in $(pwd)..."
        local found_project_subdir=false
        for subdir_name in main master trunk; do
            if [ -d "./$subdir_name" ]; then
                # Check if this subdir is part of a Git repo and get its top-level
                local potential_repo_dir
                # Use a subshell to cd and run git command to avoid changing current shell's CWD prematurely
                potential_repo_dir=$( (cd "./$subdir_name" && git rev-parse --show-toplevel) 2>/dev/null)

                if [ -n "$potential_repo_dir" ]; then
                    repo_dir="$potential_repo_dir" # This will be an absolute path
                    echo "Found Git repository via subdirectory './$subdir_name'. Project root: $repo_dir"
                    found_project_subdir=true
                    break
                else
                    echo "Info: Subdirectory './$subdir_name' exists but is not part of a Git repository or 'git' command failed within it."
                fi
            fi
        done

        if ! $found_project_subdir; then
            echo "Error: Not in a Git repository and no 'main', 'master', or 'trunk' subdirectory in $(pwd) is a Git repository."
            return 1
        fi
    fi

    # At this point, repo_dir is the absolute path to the Git repository's top-level directory.
    # The new worktree should be a sibling to this repo_dir.
    local worktree_parent_dir
    worktree_parent_dir=$(dirname "$repo_dir")
    local worktree_path="$worktree_parent_dir/$branch_name"

    # Check if the parent directory for the worktree is writable
    if [ ! -w "$worktree_parent_dir" ]; then
        echo "Error: Parent directory for worktree ('$worktree_parent_dir') is not writable."
        return 1
    fi

    # Check if the target worktree path (directory or file) already exists
    if [ -e "$worktree_path" ]; then
        echo "Error: Target path for worktree '$worktree_path' already exists. Please choose a different branch name or remove the existing file/directory."
        return 1
    fi

    # Check if HEAD is valid in the repo_dir (e.g., repository is not empty)
    if ! (cd "$repo_dir" && git rev-parse --verify HEAD > /dev/null 2>&1); then
        echo "Error: Repository at '$repo_dir' has no valid HEAD (e.g., it might be an empty repository with no commits)."
        echo "Please make an initial commit in the repository before creating a branch and worktree."
        return 1
    fi

    # Check if branch already exists in the repo
    if (cd "$repo_dir" && git rev-parse --verify "$branch_name" > /dev/null 2>&1); then
        echo "Error: Branch '$branch_name' already exists in the repository '$repo_dir'."
        echo "If you want to create a worktree for an existing branch, use 'git worktree add <path> <branch>' manually."
        return 1
    fi

    # Determine the base branch (main, master, trunk)
    local base_branch=""
    for branch in main master trunk develop; do
        if (cd "$repo_dir" && git rev-parse --verify "$branch" > /dev/null 2>&1); then
            base_branch="$branch"
            break
        fi
    done

    if [ -z "$base_branch" ]; then
        # Fallback: Use the currently checked out branch
        base_branch=$(cd "$repo_dir" && git symbolic-ref --short HEAD 2>/dev/null)

        if [ -z "$base_branch" ]; then
            echo "Warning: Could not determine a base branch (main, master, trunk, develop)."
            echo "Will use the current HEAD without pulling."
        else
            echo "Using current branch '$base_branch' as base."
        fi
    else
        echo "Found base branch: $base_branch"
    fi

    # Pull the base branch if we found one
    if [ -n "$base_branch" ]; then
        echo "Pulling latest changes for '$base_branch'..."

        # Store the current branch
        local current_branch=$(cd "$repo_dir" && git symbolic-ref --short HEAD 2>/dev/null)

        # Only switch if not already on the base branch
        if [ "$current_branch" != "$base_branch" ]; then
            echo "Temporarily switching to '$base_branch'..."
            if ! (cd "$repo_dir" && git checkout "$base_branch"); then
                echo "Error: Failed to switch to '$base_branch'. Using current HEAD instead."
            fi
        fi

        # Pull the latest changes
        if ! (cd "$repo_dir" && git pull); then
            echo "Warning: Failed to pull latest changes for '$base_branch'."
            echo "Proceeding with current state, which might not include the latest remote changes."
        fi

        # Switch back if we changed branches
        if [ "$current_branch" != "$base_branch" ] && [ -n "$current_branch" ]; then
            echo "Switching back to '$current_branch'..."
            if ! (cd "$repo_dir" && git checkout "$current_branch"); then
                echo "Error: Failed to switch back to '$current_branch'."
                echo "You are currently on '$base_branch'."
                echo "New branch will be created from '$base_branch'."
            fi
        fi
    fi

    echo "Creating new branch '$branch_name' in repository '$repo_dir'..."
    if ! (cd "$repo_dir" && git branch "$branch_name"); then
        echo "Error: Failed to create branch '$branch_name' in repository '$repo_dir'."
        return 1
    fi
    echo "Branch '$branch_name' created successfully in '$repo_dir'."

    echo "Creating worktree at '$worktree_path' for branch '$branch_name'..."
    # The `git worktree add` command is run from $repo_dir.
    # The path to the new worktree can be absolute or relative to $repo_dir.
    # Using an absolute path ($worktree_path) is robust.
    if ! (cd "$repo_dir" && git worktree add "$worktree_path" "$branch_name"); then
        echo "Error: Failed to create worktree at '$worktree_path' for branch '$branch_name'."
        echo "Attempting to clean up newly created branch '$branch_name'..."
        # Use -d for deleting a branch. It's safer.
        if ! (cd "$repo_dir" && git branch -d "$branch_name"); then
            echo "Warning: Failed to delete newly created branch '$branch_name' using 'git branch -d'."
            echo "This might be unexpected. You may need to use 'git branch -D $branch_name' manually in '$repo_dir'."
        else
            echo "Newly created branch '$branch_name' cleaned up successfully from '$repo_dir'."
        fi
        return 1
    fi

    echo ""
    echo "--------------------------------------------------------------------"
    echo "Successfully created Git branch '$branch_name' and worktree."
    echo "  Repository:      $repo_dir"
    echo "  Base Branch:     ${base_branch:-"(current HEAD)"}";
    echo "  New Branch:      $branch_name"
    echo "  Worktree Path:   $worktree_path"
    echo "--------------------------------------------------------------------"
    echo ""
    echo "To switch to the new worktree directory, you can run:"
    echo "  cd '$worktree_path'"
    echo ""

    return 0
}

#####################
# /Worktree Utility #
#####################

##########################
# Machine bashrc utility #
##########################

# Tries to determine a short machine name
# and sources a file like ~/.<machine_name>.bashrc if it exists.
# The determined machine name is converted to lowercase for the filename.

__msb_machine_name="" # Using a less common variable name prefix

# 1. Try using the 'hostname' command, if available
if command -v hostname >/dev/null 2>&1; then
    # Try to get the short hostname (e.g., "lenny")
    __msb_machine_name=$(hostname -s 2>/dev/null)

    # If 'hostname -s' failed or returned an empty string, try 'hostname' and parse
    if [ -z "$__msb_machine_name" ]; then
        __msb_full_hostname=$(hostname 2>/dev/null) # Get full hostname
        if [ -n "$__msb_full_hostname" ]; then
            __msb_machine_name="${__msb_full_hostname%%.*}" # Extract part before the first dot
        fi
        unset __msb_full_hostname # Clean up temporary variable
    fi
fi

# 2. Fallback to HOSTNAME environment variable if 'hostname' command methods failed or command wasn't available
if [ -z "$__msb_machine_name" ] && [ -n "$HOSTNAME" ]; then
    __msb_machine_name="${HOSTNAME%%.*}" # Extract part before the first dot
fi

# 3. If a machine name was determined, construct the path and source the file
if [ -n "$__msb_machine_name" ]; then
    # Convert to lowercase (requires Bash 4+; Ubuntu 24.04 has Bash 5.x)
    __msb_machine_name_lower="${__msb_machine_name,,}"

    __msb_rc_file="$HOME/.${__msb_machine_name_lower}.bashrc"

    if [ -f "$__msb_rc_file" ]; then
        # echo "[INFO] Sourcing machine-specific bashrc: $__msb_rc_file (derived from name: '${__msb_machine_name}')"
        . "$__msb_rc_file"
    # else
        # echo "[INFO] No machine-specific bashrc found at: $__msb_rc_file (derived from name: '${__msb_machine_name}', looked for lowercase: '${__msb_machine_name_lower}')"
    fi

    # Clean up temporary variables specific to this block
    unset __msb_machine_name_lower __msb_rc_file
fi

# Clean up the main temporary variable used
unset __msb_machine_name
# --- End of Load machine-specific bashrc ---

###########################
# /Machine bashrc utility #
###########################

#######################
# Self-update utility #
#######################

# Fetches the latest .bashrc from a specified URL and updates the local
# ~/.colin.bashrc if it differs. Runs asynchronously and checks periodically.

__update_dot_bashrc_from_github() {
    local remote_url="https://raw.githubusercontent.com/NiloCK/ConfigUtils/refs/heads/master/2025/.colin.bashrc"
    local local_bashrc_path="$HOME/.colin.bashrc" # This is the file that will be updated
    local temp_download_path="$HOME/.cache/bashrc_github_latest.tmp"
    local log_file="$HOME/.cache/bashrc_update.log"
    local last_check_timestamp_file="$HOME/.cache/bashrc_last_github_check"
    # Check interval: 1 day = 24 * 60 * 60 = 86400 seconds
    local check_interval_seconds=86400

    # Ensure cache directory exists for logs and temp files
    mkdir -p "$HOME/.cache"

    # --- Frequency Control: Only check if interval has passed ---
    if [ -f "$last_check_timestamp_file" ]; then
        # Check if 'stat' supports %Y (Unix timestamp for modification)
        local last_check_time
        if stat -c %Y "$last_check_timestamp_file" >/dev/null 2>&1; then
            last_check_time=$(stat -c %Y "$last_check_timestamp_file")
        elif stat -f %m "$last_check_timestamp_file" >/dev/null 2>&1; then # macOS alternative
            last_check_time=$(stat -f %m "$last_check_timestamp_file")
        else
            echo "[$(date)] WARNING: Cannot determine timestamp of $last_check_timestamp_file. Proceeding with check." >> "$log_file"
            # Fallthrough to check if stat failed
        fi

        if [ -n "$last_check_time" ]; then
            local current_time=$(date +%s)
            if (( (current_time - last_check_time) < check_interval_seconds )); then
                # Optional: Log that it's too soon, for debugging.
                # echo "[$(date)] Bashrc GitHub check: Too soon. Last check at $(date -d "@$last_check_time")." >> "$log_file"
                return 0 # Exit quietly, too soon to check
            fi
        fi
    fi
    # --- End Frequency Control ---

    # Ensure cleanup of the temporary file on exit/error
    trap 'rm -f "$temp_download_path"' EXIT

    # echo "[$(date)] Starting .colin.bashrc update check from GitHub: $remote_url" >> "$log_file"

    # Fetch the remote .bashrc using curl
    # -s: silent, -S: show error (if not silent), -L: follow redirects
    # --connect-timeout: max time for connection
    # --max-time: max total time for operation
    # -o: output to file
    # -f: (fail silently) on server errors (HTTP 4xx, 5xx). curl returns 22.
    # We'll check curl's exit code explicitly.
    if curl -sSL --connect-timeout 10 --max-time 30 -o "$temp_download_path" "$remote_url"; then
        # Check if download was successful and file is not empty
        if [ ! -s "$temp_download_path" ]; then
            echo "[$(date)] ERROR: Downloaded file from $remote_url is empty or download failed (curl succeeded but file empty)." >> "$log_file"
            # trap will clean up temp_download_path
            return 1
        fi

        # Compare with the local .colin.bashrc
        # `cmp -s` is silent and returns 0 if files are the same, 1 if different, >1 on error.
        if [ -f "$local_bashrc_path" ] && cmp -s "$temp_download_path" "$local_bashrc_path"; then
            :
            # echo "[$(date)] Local .colin.bashrc is already up-to-date." >> "$log_file"
        else
            if [ ! -f "$local_bashrc_path" ]; then
                echo "[$(date)] Local .colin.bashrc ($local_bashrc_path) does not exist. Creating new." >> "$log_file"
            else
                echo "[$(date)] Local .colin.bashrc differs. Updating from $remote_url..." >> "$log_file"
                # Backup current .colin.bashrc
                local backup_path="${local_bashrc_path}.bak_$(date +%Y%m%d_%H%M%S)"
                if cp "$local_bashrc_path" "$backup_path"; then
                    echo "[$(date)] Backup of current .colin.bashrc created at $backup_path" >> "$log_file"
                else
                    echo "[$(date)] WARNING: Failed to create backup of $local_bashrc_path." >> "$log_file"
                fi
            fi

            # Replace local .colin.bashrc with the downloaded one
            if mv "$temp_download_path" "$local_bashrc_path"; then
                echo "[$(date)] SUCCESS: $local_bashrc_path updated. Please source it or open a new terminal for changes to take effect." >> "$log_file"
            else
                echo "[$(date)] ERROR: Failed to move downloaded file to $local_bashrc_path." >> "$log_file"
                # trap will clean up temp_download_path if it still exists
                return 1
            fi
        fi
    else
        local curl_exit_code=$?
        echo "[$(date)] ERROR: curl failed to download $remote_url (exit code: $curl_exit_code)." >> "$log_file"
        # trap will clean up temp_download_path
        return 1
    fi

    # Update timestamp file after a successful check (whether an update happened or not)
    touch "$last_check_timestamp_file"
    # trap will clean up temp_download_path
    return 0
}

# Call the function asynchronously only for interactive shells.
# Output from the subshell itself (not the function's explicit logging) is also sent to the log file.
# `disown` detaches the process from the shell, allowing it to continue if the shell exits.
if [[ $- == *i* ]]; then # Check if the shell is interactive
    (
        __update_dot_bashrc_from_github
    ) >> "$HOME/.cache/bashrc_update.log" 2>&1 & disown
fi

########################
# /Self-update utility #
########################

##################
# BD Utility     #
##################

function bd() {
    local bd_dir="$HOME/pn/bd"

    # Check if ~/pn/bd exists
    if [ -d "$bd_dir" ]; then
        # Directory exists, open with zed
        zed "$bd_dir"
    else
        # Directory doesn't exist, need to set up
        echo "BD directory not found. Setting up..."

        # Create ~/pn if it doesn't exist
        if [ ! -d "$HOME/pn" ]; then
            echo "Creating ~/pn directory..."
            mkdir -p "$HOME/pn"
        fi

        # Clone the repository
        echo "Cloning bd repository..."
        if git clone https://github.com/patched-network/bd "$bd_dir"; then
            echo "Successfully cloned bd repository."
            # Open with zed after successful clone
            zed "$bd_dir"
        else
            echo "Failed to clone bd repository."
            return 1
        fi
    fi
}

##################
# /BD Utility    #
##################

##################
# CFG Utility    #
##################

function cfg() {
    local cfg_dir="$HOME/dev/configutils"

    # Check if ~/dev/configutils exists
    if [ -d "$cfg_dir" ]; then
        # Directory exists, open with zed
        zed "$cfg_dir"
    else
        # Directory doesn't exist, need to set up
        echo "ConfigUtils directory not found. Setting up..."

        # Create ~/dev if it doesn't exist
        if [ ! -d "$HOME/dev" ]; then
            echo "Creating ~/dev directory..."
            mkdir -p "$HOME/dev"
        fi

        # Clone the repository
        echo "Cloning configutils repository..."
        if git clone https://github.com/NiloCK/ConfigUtils "$cfg_dir"; then
            echo "Successfully cloned configutils repository."
            # Open with zed after successful clone
            zed "$cfg_dir"
        else
            echo "Failed to clone configutils repository."
            return 1
        fi
    fi
}

##################
# /CFG Utility   #
##################
