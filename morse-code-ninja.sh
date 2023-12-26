#!/bin/bash

docker compose run --rm app perl render.pl "$@"
