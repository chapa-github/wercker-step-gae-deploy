#!/bin/bash

# 必要そうな変数
# WERCKER_GCP_GAE_DEPLOY_ACCOUNT サービスアカウント
# WERCKER_GCP_GAE_DEPLOY_PROJECT 対象プロジェクト
# WERCKER_GCP_GAE_DEPLOY_SERVICE 対象のGAEサービス
# WERCKER_GCP_GAE_DEPLOY_CREDENTIAL サービスアカウントの認証ファイル
# WERCKER_GCP_GAE_DEPLOY_ENV_FILE 環境変数のファイル
# WERCKER_GCP_GAE_DEPLOY_GS_BUCKET デプロイ時に保存されるGSバケット

if [ ! -n "$WERCKER_GCP_GAE_DEPLOY_ACCOUNT" ]; then
  error 'Please GCP ServiceAccount'
  exit 1
fi

if [ ! -n "$WERCKER_GCP_GAE_DEPLOY_PROJECT" ]; then
  error 'Please GCP Deploy Project'
  exit 1
fi

if [ ! -n "$WERCKER_GCP_GAE_DEPLOY_GS_BUCKET" ]; then
  error 'Please GS Bucket'
  exit 1
fi

if [ ! -n "$WERCKER_GCP_GAE_DEPLOY_SERVICE" ]; then
  error 'Please GAE Deploy Service'
  exit 1
fi

if [ ! -n "$WERCKER_GCP_GAE_DEPLOY_CREDENTIAL" ]; then
  error 'Please GAE Credential'
  exit 1
fi

if [ ! -n "$WERCKER_GCP_GAE_DEPLOY_ENV_FILE" ]; then
  error 'Please GAE ENV file'
  exit 1
fi

cd $WERCKER_GCP_GAE_DEPLOY_SERVICE

# JSTのyyyyMMdd-hhmmssでVersionを生成
apk --update add tzdata
cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
GAE_TAG=`date +"%Y%m%d-%H%M%S"`
echo | pwd
echo | ls -la


# アプリケーションの環境変数ファイル作成(secret.yaml)
echo -e "$WERCKER_GCP_GAE_DEPLOY_ENV_FILE" > secret.yaml

# GCPサービスアカウント認証json(.credential.json)
echo -e "$WERCKER_GCP_GAE_DEPLOY_CREDENTIAL" > .credential.json

# GCP Login
gcloud auth activate-service-account $WERCKER_GCP_GAE_DEPLOY_ACCOUNT \
  --key-file .credential.json --project $WERCKER_GCP_GAE_DEPLOY_PROJECT

# GAE deploy
echo Y | gcloud app deploy --project $WERCKER_GCP_GAE_DEPLOY_PROJECT --version $GAE_TAG

if [ $WERCKER_GCP_GAE_DEPLOY_OLD_VERSION_CLEAN ]; then
  # Old Version Delete (gae)
  GAE_VERSION_COUNT=`gcloud app versions list | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE | wc -l`
  GAE_OLD_VERSION=`gcloud app versions list | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE | sort -k 4,4 | awk '{print $2}' | head -n 1`
  test $GAE_VERSION_COUNT -gt 5 && \
    echo Y | gcloud app versions delete $GAE_OLD_VERSION
  gcloud app versions list | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE

  # Old Version Delete (gcr)
  GCR_VERSION_COUNT=`gcloud container images list --repository=asia.gcr.io/$WERCKER_GCP_GAE_DEPLOY_PROJECT/appengine \
    | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE | wc -l`
  GCR_OLD_VERSION=`gcloud container images list --repository=asia.gcr.io/$WERCKER_GCP_GAE_DEPLOY_PROJECT/appengine \
    | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE | sort -k 1,1 | head -1`
  test $GCR_VERSION_COUNT -gt 5 && \
    echo Y | gcloud container images delete $GCR_OLD_VERSION --force-delete-tags --quiet
  gcloud container images list --repository=asia.gcr.io/$WERCKER_GCP_GAE_DEPLOY_PROJECT/appengine \
    | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE

  # Old Version Delete (gs)
  GCS_VERSION_COUNT=`gsutil ls $WERCKER_GCP_GAE_DEPLOY_GS_BUCKET/asia.gcr.io/$WERCKER_GCP_GAE_DEPLOY_PROJECT/appengine \
    | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE | wc -l`
  GCS_OLD_VERSION=`gsutil ls $WERCKER_GCP_GAE_DEPLOY_GS_BUCKET/asia.gcr.io/$WERCKER_GCP_GAE_DEPLOY_PROJECT/appengine \
    | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE | sort -k 1,1 | head -1`
  test $GCS_VERSION_COUNT -gt 5 && \
    echo Y | gsutil rm $GCS_OLD_VERSION
  gsutil ls $WERCKER_GCP_GAE_DEPLOY_GS_BUCKET/asia.gcr.io/$WERCKER_GCP_GAE_DEPLOY_PROJECT/appengine \
    | grep $WERCKER_GCP_GAE_DEPLOY_SERVICE
fi
