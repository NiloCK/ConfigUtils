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
