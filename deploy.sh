#!/bin/bash
set -e

function get_commit_message {
    if [[ -n "$GITHUB_SHA" ]]; then
        echo $(git log --format=%B -n 1 $GITHUB_SHA)
    else
        echo "pdf updates"
    fi
}

if [[ ! -d _gh_pages ]]; then
    git clone --branch gh-pages git@github.com:petuhovskiy/petuhovskiy.git _gh_pages
fi

# clean up
pushd _gh_pages
git pull
rm -rf *
popd

# build
hugo -d _gh_pages

# push
commit_message=$(get_commit_message)

pushd _gh_pages

git add -A

if git diff --quiet; then
    # author=${GITHUB_ACTOR:=github-actions}
    # git config user.name "$author"
    # git config user.email "$author@users.noreply.github.com"

    git commit --allow-empty -m "$commit_message"
    git push origin gh-pages
else
    echo "No diff found"
fi

popd
