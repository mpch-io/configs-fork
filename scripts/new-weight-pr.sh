#!/usr/bin/env bash

echo "Runing new-weight-pr.sh script..."

# 0. First get latest from upstream 
# 1. Update approved-sv-id-values.yaml with new rewardWeightBps and extraBeneficiaries (format like this 1_0000) and comment like GSF latest ones
# 2. Run bash like this example 
# CIP_NUMBER=CIP-0087 CLIENT_NAME="Hex Trust" SV_NAME=MPC-Holding-Inc URL=https://lists.sync.global/g/cip-announce/message/63 VOTE_EXPIRES="2025-11-26 16:45 UTC +1" VOTE_EFFECTIVE="2025-11-27 16:45 UTC +1" bash scripts/new-weight-pr.sh

set -euo pipefail

# Get latest from upstream
git pull upstream main
git push

NETWORKS=("DevNet" "MainNet" "TestNet")
BASE_BRANCH="main"

for NET in "${NETWORKS[@]}"; do
  FILE="configs/${NET}/approved-sv-id-values.yaml"
  if git diff --quiet "$BASE_BRANCH" -- "$FILE"; then
    echo "No changes for $NET, skipping."
    continue
  fi

  # Custom PR title and description
  PR_TITLE="${CIP_NUMBER:-CIP-XXX} Add ${CLIENT_NAME:-Client} weight to the ${SV_NAME:-SV} SV node on ${NET} [allow-total-reward-weight-change]"


  BRANCH="${CIP_NUMBER// /-}-${CLIENT_NAME// /-}-${NET,,}"
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
done
