FROM php:7.4-cli

LABEL "repository" = "https://github.com/upcorno/action-deployer-php"
LABEL "homepage" = "https://github.com/upcorno/action-deployer-php"

LABEL "com.github.actions.name"="Action - Deployer php"
LABEL "com.github.actions.description"="Use your Deployer PHP script with your github action workflow."
LABEL "com.github.actions.icon"="server"
LABEL "com.github.actions.color"="yellow"

ENV DEPLOYER_VERSION=6.8.0


RUN sed -i "s@http://\(deb\|security\).debian.org@https://mirrors.aliyun.com@g" /etc/apt/sources.list
RUN apt-get update && apt-get install -y bash openssh-client rsync git

# Change default shell to bash (needed for conveniently adding an ssh key)
RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

RUN curl -L https://deployer.org/releases/v$DEPLOYER_VERSION/deployer.phar > /usr/local/bin/deployer \
    && chmod +x /usr/local/bin/deployer

COPY entrypoint.sh /entrypoint.sh
COPY deploy_web.php /deploy_web.php

RUN chmod +x /entrypoint.sh
RUN echo "StrictHostKeyChecking no" >>/etc/ssh/ssh_config
RUN groupadd -g 1000 node \
    && useradd -u 1000 -g 1000 -s /bin/bash node
USER node
ENTRYPOINT ["/entrypoint.sh"]
