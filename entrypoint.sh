#!/bin/bash

set -e

if [[ -n "$REF" && -n "$SUBSTRING" ]]; then
  REF=${REF/$SUBSTRING/}
  echo "REF: $REF"
fi

if [ "$GITHUB_REF_NAME" = "test" ]; then
  export STAGE=test
  export TARGET=$TARGET_test
elif [[ "$GITHUB_REF_NAME" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  export STAGE=prod
  export TARGET=$TARGET_prod
else
  echo "Sorry, there is not matched host."
  exit 1
fi

if [ "$STAGE" = "prod" ]; then
  TOP_TAG=$(git tag --sort=-creatordate | sed -n '2p')
  VERSION_COMPARE=$(php -r "echo version_compare('$CI_COMMIT_TAG','$TOP_TAG');")
  if [ "$VERSION_COMPARE" != "1" ]; then
    echo "新版本号必须大于上一版本号才可发布"
    exit 1
  fi
fi

if [ -z "$1" ]; then
  CMD_ARGS=""
else
  CMD_ARGS="$@"
fi

mkdir -p /github/home/.ssh

eval $(ssh-agent -s)

echo -e "StrictHostKeyChecking no" >>/etc/ssh/ssh_config
echo "$SSH_PRIVATE_KEY" | tr -d '\r' >/tmp/id_rsa
chmod 600 /tmp/id_rsa
ssh-add /tmp/id_rsa

deployer --version
deployer -f deploy_web.php $STAGE -vvv
