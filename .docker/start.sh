#!/bin/bash

mix deps.compile \
  && mix compile \
  && mix phoenix.digest \
  && mix ecto.create \
  && mix phoenix.server

echo "Press [CTRL+C] to stop.."
while :
do
	sleep 60
done
