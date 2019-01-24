#!/bin/sh

SCREEN_WIDTH=1600
SCREEN_HEIGHT=900

Xvfb :99 -screen 0 $SCREEN_WIDTHx$SCREEN_HEIGHTx24 &

set -e

exec "$@"
