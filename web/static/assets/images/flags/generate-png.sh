#! /usr/bin/env bash

for res in 512 256 128 64 32
do
  for i in svg/*.svg 
  do
    IMAGE_NAME=$(basename $i .svg)
    echo "Converting ${IMAGE_NAME} to png/${res}/${IMAGE_NAME}.png"
    rsvg-convert -w ${res} $i -o png/${res}/${IMAGE_NAME}.png
  done
done

