#!/usr/bin/env bash

echo "Running new-weight-pr.sh script..."

# 0. First get latest from upstream 
# 1. Update approved-sv-id-values.yaml with new rewardWeightBps and extraBeneficiaries (format like this 1_0000) and comment like GSF latest ones
# 2. Run bash like this example 
# NETWORK=MainNet CIP_NUMBER=CIP-0087 CLIENT_NAME="Hex Trust" SV_NAME=MPC-Holding-Inc URL=https://lists.sync.global/g/cip-announce/message/63 VOTE_EXPIRES="2025-12-01 17:11 UTC +1" VOTE_EFFECTIVE="2025-12-02 17:11 UTC +1" bash scripts/new-weight-pr.sh

set -euo pipefail

# Get latest from upstream
git pull upstream main
git push

NETWORK="${NETWORK:-MainNet}"
BASE_BRANCH="main"

FILE="configs/${NETWORK}/approved-sv-id-values.yaml"
if git diff --quiet "$BASE_BRANCH" -- "$FILE"; then
  echo "No changes for $NETWORK, skipping."
  exit 0
fi

# Custom PR title and description
PR_TITLE="${CIP_NUMBER:-CIP-XXX} Add ${CLIENT_NAME:-Client} weight to the ${SV_NAME:-SV} SV node on ${NETWORK} [allow-total-reward-weight-change]"

BRANCH="${CIP_NUMBER// /-}-${CLIENT_NAME// /-}-${NETWORK,,}"
git checkout -b "$BRANCH"
git add "$FILE"
git commit -m "$PR_TITLE"
git push --set-upstream origin "$BRANCH"

PR_DESC="${URL:-https://example.com}

The vote expires on ${VOTE_EXPIRES}
The vote becomes effective on ${VOTE_EFFECTIVE}"

gh pr create \
  --title "$PR_TITLE" \
  --body "$PR_DESC" \
  --head "mpch-io:$BRANCH" \
  --base $BASE_BRANCH \
  --repo global-synchronizer-foundation/configs

git checkout "$BASE_BRANCH"
