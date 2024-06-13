#!/bin/bash

chmod +x wait-for-it.sh && ./wait-for-it.sh mariadb:3306 -- bash -c "sh bench_setup_scripts.sh";
