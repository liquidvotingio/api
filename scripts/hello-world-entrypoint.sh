#!/bin/sh
set -e

/opt/app/bin/liquid_voting eval "LiquidVoting.Release.migrate"

exec "$@"
