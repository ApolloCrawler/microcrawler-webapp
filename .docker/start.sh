#!/bin/bash

source /root/.nvm/nvm.sh

mix ecto.create
mix phoenix.server

echo "Press [CTRL+C] to stop.."
while :
do
	sleep 10
done
