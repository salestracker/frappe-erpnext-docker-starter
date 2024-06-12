#!/bin/bash

echo "running bench setup script";

if [ ! -d "frappe-bench" ]; then
  echo "creating frappe-bench";
  bench init --dev --clone-without-update --verbose --ignore-exist --no-backups --no-procfile --skip-redis-config-generation --frappe-branch=${FRAPPE_BRANCH} frappe-bench
else
  echo "frappe-bench already exists";
fi;

echo "switching directory to frappe-bench";
cd frappe-bench/

bench set-mariadb-host mariadb
bench set-redis-cache-host redis-cache:6379
bench set-redis-queue-host redis-cache:6379
bench set-redis-socketio-host redis-cache:6379

bench start