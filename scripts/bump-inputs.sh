#!/bin/sh
# Update flake inputs and push the result to main.
#
# Driven by two environment variables, which .woodpecker/bump-input.yml
# receives as pipeline parameters:
#
#   SEABIRD_CI_TASK=nix-input-bump          update the single input named by
#                                           INPUT_NAME
#   SEABIRD_CI_TASK=nix-input-bump-seabird  update every seabird-* input
#   SEABIRD_CI_TASK=nix-input-bump-all      update the whole lock file
#
# FORGEJO_TOKEN must hold a token that can push to seabird-nix.
set -eu

REPO_URL="https://seabird-bot:$FORGEJO_TOKEN@forgejo.elwert.cloud/seabird-chat/seabird-nix.git"
MAX_ATTEMPTS=3

# Fails if INPUT_NAME doesn't name a real input. Worth checking, because
# `nix flake update <name>` only warns and still exits 0 in that case, so a
# bad name would otherwise look like a clean bump that changed nothing.
check_input_exists() {
  nix eval --impure --raw --expr '
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      inputs = (builtins.getAttr lock.root lock.nodes).inputs;
      name = builtins.getEnv "INPUT_NAME";
    in
    if builtins.hasAttr name inputs then
      "ok"
    else
      throw ("INPUT_NAME is not a flake input of this repo: " + name)
  ' > /dev/null
}

seabird_inputs() {
  nix eval --impure --raw --expr '
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      names = builtins.attrNames (builtins.getAttr lock.root lock.nodes).inputs;
    in
    builtins.concatStringsSep " "
      (builtins.filter (n: builtins.substring 0 8 n == "seabird-") names)
  '
}

# An empty `inputs` means "every input", which is what a bare
# `nix flake update` does.
case "${SEABIRD_CI_TASK:-}" in
  nix-input-bump)
    check_input_exists
    inputs="$INPUT_NAME"
    subject="flake: bump $INPUT_NAME"
    ;;
  nix-input-bump-seabird)
    inputs="$(seabird_inputs)"
    subject="flake: bump all seabird inputs"
    ;;
  nix-input-bump-all)
    inputs=""
    subject="flake: bump all inputs"
    ;;
  *)
    echo "unknown SEABIRD_CI_TASK: ${SEABIRD_CI_TASK:-<unset>}" >&2
    exit 1
    ;;
esac

# Service repos trigger bumps independently, so several of these run at once
# and race each other to push. Each pass reads main, recomputes the lock on
# top of it, and pushes — a compare-and-swap, where a rejected push means
# someone else won and the work has to be redone against the new main. A
# rebase can't substitute for redoing it: two bumps edit the same region of
# flake.lock, and the result has to come from nix rather than a merge.
#
# The fetch sits as late as it can — immediately before the recompute — so
# the window is only as long as the update and the push. Retries are also
# much faster than the first pass, since nix has the fetched inputs cached
# by then, so a small bound is enough to converge.
attempt=1
while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
  # Fetch through the token URL rather than `origin`: in a Woodpecker
  # workspace the origin remote has no usable credentials, since the netrc
  # belongs to the clone step.
  git fetch -q "$REPO_URL" main
  git reset -q --hard FETCH_HEAD

  # Unquoted on purpose: this is a list of inputs, and empty means "all".
  # shellcheck disable=SC2086
  nix flake update $inputs

  if git diff --quiet flake.lock; then
    echo "flake.lock is already current"
    exit 0
  fi

  git -c user.name=seabird-bot -c user.email=belak+seabird-bot@coded.io \
    commit -q -m "$subject" flake.lock

  if git push "$REPO_URL" HEAD:main; then
    exit 0
  fi

  echo "push rejected on attempt $attempt; another bump landed first"
  attempt=$((attempt + 1))
done

echo "gave up after $MAX_ATTEMPTS attempts" >&2
exit 1
