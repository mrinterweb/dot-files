git-worktree-recent() {
  local branch=$(git reflog | grep 'checkout:' | head -20 | awk '{print $8}' | grep -v '^$' | awk '!seen[$0]++' | fzf --height=15 --reverse --prompt='Select branch for worktree: ')
}

# This function allows you to switch branches in a git repository using fzf.
# It will even cd to the worktree if the branch is already checked out somewhere.
git-branch-switch() {
  # Get all branches sorted by last commit date
  local branches=$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/)

  # Use fzf to select a branch with preview
  local selected_branch=$(echo "$branches" | fzf --height=15 --reverse --prompt="Select branch: " --preview='git log -1 --oneline --color=always {}')

  if [ -n "$selected_branch" ]; then
    # Get repo info
    local repo=$(basename "$(git rev-parse --show-toplevel)")
    local parent_dir=$(dirname "$(git rev-parse --show-toplevel)")

    # Find the main repo directory
    local main_repo=$(git worktree list | grep -v "worktrees_" | head -1 | awk '{print $1}')

    # Check if selected branch is already checked out somewhere
    local worktree_location=$(git worktree list | grep "\\[$selected_branch\\]" | awk '{print $1}')

    if [ -n "$worktree_location" ]; then
      # Branch is already checked out, go to that location
      echo "Branch already checked out at: $worktree_location"
      cd "$worktree_location"
    else
      # Branch is not checked out anywhere
      if [[ "$(git rev-parse --show-toplevel)" == *"worktrees_${repo}"* ]]; then
        # We're in a worktree, create new worktree for this branch
        local branch_dir=$(echo "$selected_branch" | sed 's/\//__/g')
        local worktree_dir="${parent_dir}/worktrees_${repo}/${branch_dir}"

        if git worktree add "$worktree_dir" "$selected_branch"; then
          cd "$worktree_dir"
          echo "Created worktree at: $worktree_dir"
        else
          echo "Failed to create worktree"
          return 1
        fi
      else
        # We're in the primary repo, just switch branches
        echo "Switching to branch: $selected_branch"
        git checkout "$selected_branch"
      fi
    fi
  else
    echo "No branch selected"
  fi
}
alias gswitch=git-branch-switch

# This creates a worktree for the current branch or switches to an existing one.
git-create-worktree() {
  # Get the current branch name
  local branch=$(git branch --show-current)

  # Get the repository name (folder name)
  local repo=$(basename "$(git rev-parse --show-toplevel)")

  # Get the parent directory of the current repo
  local parent_dir=$(dirname "$(git rev-parse --show-toplevel)")

  # Replace / with -- in branch name for directory
  local branch_dir=$(echo "$branch" | sed 's/\//__/g')

  # Create worktree directory path
  local worktree_dir="${parent_dir}/worktrees_${repo}/${branch_dir}"

  # Check if already in a worktree
  if [[ "$(git rev-parse --show-toplevel)" == *"worktrees_${repo}"* ]]; then
    echo "Already in a worktree. Switching to: $worktree_dir"
    cd "$worktree_dir"
  else
    # Check if worktree already exists
    if git worktree list | grep -q "$worktree_dir"; then
      echo "Worktree already exists. Switching to: $worktree_dir"
      cd "$worktree_dir"
    else
      # Check for uncommitted changes
      local stashed=false
      if ! git diff-index --quiet HEAD --; then
        echo "Stashing uncommitted changes..."
        git stash push -m "Auto-stash for worktree creation"
        stashed=true
      fi

      # Try to switch to main branch
      echo "Switching to main branch..."
      if ! git checkout main 2>/dev/null; then
        echo "Cannot switch to main - it's checked out elsewhere."
        echo "Please manually switch to a different branch and try again."
        if [ "$stashed" = true ]; then
          git stash pop
        fi
        return 1
      fi

      # Create the worktree
      if git worktree add "$worktree_dir" "$branch"; then
        cd "$worktree_dir"
        echo "Created worktree at: $worktree_dir"
        pwd > ~/.last_worktree_dir

        # Pop stash if we stashed earlier
        if [ "$stashed" = true ]; then
          echo "Applying stashed changes..."
          git stash pop
        fi
      else
        echo "Failed to create worktree."
        # Switch back to original branch if worktree creation failed
        git checkout "$branch"
        if [ "$stashed" = true ]; then
          git stash pop
        fi
        return 1
      fi
    fi
  fi

  echo "Changed directory to: $(pwd)"
}

git-worktree-to-main() {
  # Get current branch name
  local branch=$(git branch --show-current)

  # Get current worktree path
  local current_path=$(pwd)

  # Find main repo path
  local main_repo=$(git worktree list | grep -v "worktrees_" | head -1 | awk '{print $1}')

  # Check if we're actually in a worktree
  if [[ "$current_path" != *"worktrees_"* ]]; then
    echo "Not in a worktree"
    return 1
  fi

  # Go to main repo first
  cd "$main_repo"

  # Remove the worktree
  echo "Removing worktree at: $current_path"
  if git worktree remove "$current_path" 2>/dev/null || git worktree remove --force "$current_path"; then
    # Checkout the branch in main repo
    git checkout "$branch"
    echo "Switched to branch '$branch' in main repository"
  else
    echo "Failed to remove worktree"
    return 1
  fi
}
