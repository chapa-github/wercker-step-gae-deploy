#!/bin/bash

# 必要そうな変数
# WC_GCP_ACCOUNT サービスアカウント
# WC_GCP_PROJECT 対象プロジェクト
# WC_TARGET_SERVICE 対象のGAEサービス
# WC_CREDENTIAL_FILE サービスアカウントの認証ファイル
# WC_ENV_FILE 環境変数のファイル
#
#
#

# if [ ! -n "$WERCKER_EB_DEPLOY_ACCESS_KEY" ]; then
#   error 'Please specify access-key'
#   exit 1
# fi


# サービスアカウントのクレデンシャルファイル作成(.credential.json)


# アプリケーションの環境変数ファイル作成(secret.yaml)


# JSTのyyyyMMdd-hhmmssでVersionを生成
apk --update add tzdata
cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
GAE_TAG=`date +"%Y%m%d-%H%M%S"`
echo | pwd
echo | ls -la



# # GCP Login
# gcloud auth activate-service-account $WC_GCP_ACCOUNT --key-file $WC_CREDENTIAL_FILE --project $WC_GCP_PROJECT
#
# # GAE deploy
# cd $WERCKER_SOURCE_DIR/$WC_TARGET_SERVICE
# echo Y | gcloud app deploy --project $WC_GCP_PROJECT --version $GAE_TAG
#
# # Old Version Delete
# GAE_VERSION_COUNT=`gcloud app versions list | grep $WC_TARGET_SERVICE | wc -l`
# GAE_OLD_VERSION=`gcloud app versions list | grep $WC_TARGET_SERVICE | sort -k 4,4 | awk '{print $2}' | head -n 1`
# test $GAE_VERSION_COUNT -gt 5 && echo Y | gcloud app versions delete $GAE_OLD_VERSION
# echo | gcloud app versions list
