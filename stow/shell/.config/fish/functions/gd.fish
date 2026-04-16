function gd --description 'Remove git worktree and branch'
    if not gum confirm "Remove worktree and branch?"
        return
    end

    set -l cwd (pwd)
    set -l worktree (basename $cwd)
    set -l root (string replace -r '--.*' '' $worktree)
    set -l branch (string replace -r '^[^-]*--' '' $worktree)

    # Protect against accidentally nuking a non-worktree directory
    if test $root != $worktree
        cd "../$root"
        git worktree remove $cwd --force; or return 1
        git branch -D $branch
    end
end
