#!/bin/bash

echo "Creating the circleci user with permissions to handle future deployments";
sudo useradd -m -d /home/circleci -s /bin/bash circleci;
sudo ufw allow http;
sudo mkdir /home/circleci/.ssh;
sudo touch /home/circleci/.ssh/authorized_keys;
sudo echo "${SCOPULI_RUNNER_SSH_KEY}" > /home/circleci/.ssh/authorized_keys;

touch ~/.ssh/config;
echo "Host github.com" >> ~/.ssh/config;
echo "  StrictHostKeyChecking no" >> ~/.ssh/config;
chmod 600 ~/.ssh/config;

cp ~/.ssh/config /home/circleci/.ssh;
chown circleci /home/circleci/.ssh/config;
sudo usermod -aG docker circleci;

echo "Cloning dbt repo into ${SCOPULI_RUNNER_DIR}"

cd $SCOPULI_RUNNER_DIR && git clone git@github.com:tm41m/scopuli.git;
chown -R circleci $SCOPULI_RUNNER_DIR/scopuli;
chown -R root $SCOPULI_RUNNER_DIR/scopuli;
cd $SCOPULI_RUNNER_DIR/scopuli && git checkout -b $SCOPULI_RUNNER_ENV && git push -u origin $SCOPULI_RUNNER_ENV;
chown -R circleci $SCOPULI_RUNNER_DIR/scopuli;

echo "Pulling docker image from ghcr.io/dbt-labs/dbt-postgres:1.5.2"

docker pull ghcr.io/dbt-labs/dbt-postgres:1.5.2;
