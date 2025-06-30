#!/bin/bash

# clean-branch.sh
# Remove local branches and worktrees that don't exist on remote

set -e

echo "🔍 Fetching remote information..."
git fetch --prune origin

echo "🗂️ Cleaning up worktrees for deleted remote branches..."
git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2 | while read worktree_path; do
  if [ -d "$worktree_path" ]; then
    cd "$worktree_path" 2>/dev/null || continue
    branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    if [ -n "$branch_name" ] && [ "$branch_name" != "HEAD" ]; then
      if ! git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        echo "🗑️ Removing worktree: $worktree_path (branch: $branch_name)"
        cd - > /dev/null
        git worktree remove "$worktree_path" --force 2>/dev/null || true
      fi
    fi
  fi
done

echo "🌿 Cleaning up local branches that don't exist on remote..."
git for-each-ref --format='%(refname:short)' refs/heads/ | while read branch; do
  if [ "$branch" != "main" ] && [ "$branch" != "master" ] && [ "$branch" != "develop" ]; then
    if ! git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      echo "🗑️ Deleting local branch: $branch"
      git branch -D "$branch" 2>/dev/null || true
    fi
  fi
done

echo "🧹 Cleaning up .claude-workspaces directory..."
if [ -d ".claude-workspaces" ]; then
  find .claude-workspaces -type d -mindepth 1 -maxdepth 1 | while read workspace_dir; do
    if [ ! -d "$workspace_dir/.git" ]; then
      workspace_name=$(basename "$workspace_dir")
      echo "🗑️ Removing orphaned workspace: $workspace_name"
      rm -rf "$workspace_dir"
    fi
  done
fi

echo "✅ Branch and worktree cleanup completed!"