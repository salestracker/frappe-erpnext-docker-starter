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

# setup dummy site
if [ ! -d "sites/lms.localhost" ]; then
  bench get-app lms https://github.com/frappe/lms.git;
  bench new-site lms.localhost --force --admin-password=admin --db-host=mariadb --db-port=3306 --db-password=${MARIADB_PASSWORD} --db-user=${MARIADB_USER} --mariadb-root-password=${MARIADB_ROOT_PASSWORD} --mariadb-user-host-login-scope="'${MARIADB_USER}'@'mariadb'" --verbose --install-app lms
fi;

bench reinstall --yes --admin-password=admin --mariadb-root-password=${MARIADB_ROOT_PASSWORD}

bench use lms.localhost

echo "starting frappe server..."
bench serve