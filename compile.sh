#!/bin/bash

haml index.haml > index.html

coffee --watch -cj js/game.js \
  src/components.coffee \
  src/processes.coffee \
  src/main.coffee
