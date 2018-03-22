#!/usr/bin/env bash

docker build -f ./Dockerfile -t aspro/nginx-php-fpm:latest .
docker build -f ./Dockerfile.dev -t aspro/nginx-php-fpm:dev .