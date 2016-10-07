#!/usr/bin/env sh

POSTGRES_PASSWORD=postgres docker run --name postgres -p 5432:5432 -d postgres
