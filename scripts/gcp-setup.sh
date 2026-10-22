#!/usr/bin/env bash
# One-time GCP setup for CI/CD. Run in Google Cloud Shell:
#   bash gcp-setup.sh .env
# Safe to re-run: steps that already exist are skipped.
set -euo pipefail

PROJECT_ID="tripplanner-512418"
FIREBASE_PROJECT="ai-trip-planner-a9afa"     # existing Firebase project (Auth + Hosting)
REGION="asia-south1"
REPO="Pratham-1604/trip-planner-genai"     # GitHub owner/repo allowed to deploy
ENV_FILE="${1:-}"

DEPLOY_SA="github-deployer@${PROJECT_ID}.iam.gserviceaccount.com"
RUNTIME_SA="trip-planner-runtime@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud config set project "$PROJECT_ID" >/dev/null
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')

echo "==> 1/6 Enabling APIs (takes ~1 min)"
gcloud services enable \
  run.googleapis.com artifactregistry.googleapis.com secretmanager.googleapis.com \
  iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com \
  cloudresourcemanager.googleapis.com

echo "==> 2/6 Artifact Registry repo (stores Docker images, keeps last 3)"
gcloud artifacts repositories describe trip-planner --location="$REGION" >/dev/null 2>&1 || \
  gcloud artifacts repositories create trip-planner --repository-format=docker --location="$REGION"
cat > /tmp/cleanup.json <<'JSON'
[
  {"name":"keep-3","action":{"type":"Keep"},"mostRecentVersions":{"keepCount":3}},
  {"name":"delete-old","action":{"type":"Delete"},"condition":{"tagState":"any","olderThan":"1d"}}
]
JSON
gcloud artifacts repositories set-cleanup-policies trip-planner --location="$REGION" \
  --policy=/tmp/cleanup.json --no-dry-run --quiet

echo "==> 3/6 Service accounts"
gcloud iam service-accounts describe "$DEPLOY_SA" >/dev/null 2>&1 || \
  gcloud iam service-accounts create github-deployer --display-name="GitHub Actions deployer"
gcloud iam service-accounts describe "$RUNTIME_SA" >/dev/null 2>&1 || \
  gcloud iam service-accounts create trip-planner-runtime --display-name="Cloud Run runtime"

echo "==> 4/6 Permissions"
for ROLE in roles/run.admin roles/artifactregistry.writer; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$DEPLOY_SA" \
    --role="$ROLE" --condition=None --quiet >/dev/null
done
# deployer may deploy the website to the Firebase project
gcloud services enable firebasehosting.googleapis.com --project="$FIREBASE_PROJECT"
for ROLE in roles/firebasehosting.admin roles/serviceusage.serviceUsageConsumer; do
  gcloud projects add-iam-policy-binding "$FIREBASE_PROJECT" --member="serviceAccount:$DEPLOY_SA" \
    --role="$ROLE" --condition=None --quiet >/dev/null
done
# deployer may "act as" the runtime account when deploying
gcloud iam service-accounts add-iam-policy-binding "$RUNTIME_SA" \
  --member="serviceAccount:$DEPLOY_SA" --role=roles/iam.serviceAccountUser --quiet >/dev/null
# the running app may read secrets
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$RUNTIME_SA" \
  --role=roles/secretmanager.secretAccessor --condition=None --quiet >/dev/null

echo "==> 5/6 Workload Identity Federation (GitHub -> GCP login, no keys)"
gcloud iam workload-identity-pools describe github --location=global >/dev/null 2>&1 || \
  gcloud iam workload-identity-pools create github --location=global --display-name="GitHub"
gcloud iam workload-identity-pools providers describe github-provider --location=global \
  --workload-identity-pool=github >/dev/null 2>&1 || \
  gcloud iam workload-identity-pools providers create-oidc github-provider \
    --location=global --workload-identity-pool=github \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --attribute-condition="assertion.repository=='${REPO}'"
gcloud iam service-accounts add-iam-policy-binding "$DEPLOY_SA" \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository/${REPO}" \
  --quiet >/dev/null

echo "==> 6/6 Secrets from ${ENV_FILE:-<no file given, skipping>}"
if [[ -n "$ENV_FILE" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue
    KEY="${line%%=*}"; VAL="${line#*=}"
    VAL="${VAL%\"}"; VAL="${VAL#\"}"; VAL="${VAL%\'}"; VAL="${VAL#\'}"
    [[ "$KEY" == "PROJECT_ID" || "$KEY" == "LOCATION" ]] && continue
    if gcloud secrets describe "$KEY" >/dev/null 2>&1; then
      printf '%s' "$VAL" | gcloud secrets versions add "$KEY" --data-file=- >/dev/null
      echo "   updated $KEY"
    else
      printf '%s' "$VAL" | gcloud secrets create "$KEY" --data-file=- --replication-policy=automatic >/dev/null
      echo "   created $KEY"
    fi
  done < "$ENV_FILE"
fi

echo
echo "================ DONE. Add these as GitHub repo VARIABLES ================"
echo "GCP_PROJECT_ID = $PROJECT_ID"
echo "WIF_PROVIDER   = projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/providers/github-provider"
echo "DEPLOY_SA      = $DEPLOY_SA"
echo "=========================================================================="
