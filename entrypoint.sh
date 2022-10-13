#!/bin/bash

set -e

if [[ -n "$REF" && -n "$SUBSTRING" ]]; then
  REF=${REF/$SUBSTRING/}
  echo "REF: $REF"
fi

if [ "$GITHUB_REF_NAME" = "test" ]; then
  export STAGE=test
elif [ "$GITHUB_REF_NAME" = "tmp" ]; then
  export STAGE=test
elif [[ "$GITHUB_REF_NAME" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  export STAGE=prod
else
  echo "Sorry, there is not matched host."
  exit 1
fi

mkdir -p /github/home/.ssh

eval $(ssh-agent -s)

echo 'Host *' >> ~/.ssh/config
echo 'StrictHostKeyChecking no' >> ~/.ssh/config
echo "$SSH_PRIVATE_KEY" | tr -d '\r' >/tmp/id_rsa
chmod 600 /tmp/id_rsa
ssh-add /tmp/id_rsa


deployer --version
git config --global --add safe.directory /github/workspace
deployer -f=/deploy_web.php deploy $STAGE -vvv
