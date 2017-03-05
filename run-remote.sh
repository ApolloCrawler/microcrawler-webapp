#!/usr/bin/env bash

AMQP_HOSTNAME="crawler.korczis.com" GAUC_URL="http://crawler.korczis.com:5000" ELASTIC_URL="http://elastic:changeme@crawler.korczis.com:9200" iex -S mix phoenix.server
