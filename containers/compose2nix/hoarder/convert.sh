#!/usr/bin/env bash

rm -f docker-compose.nix

nix run github:aksiksi/compose2nix -- \
    --env_files=/run/agenix/hoarder-env-file \
    -env_files_only=true \
    -ignore_missing_env_files \
    -project=hoarder
