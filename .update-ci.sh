#!/usr/bin/env bash

export INPUT=$(nix flake show --allow-import-from-derivation --json | json-to-dhall)
dhall-to-yaml --file .gitlab-ci.dhall
