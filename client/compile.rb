#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

# Directories
mkpath 'public'
mkpath 'public/js'
mkpath 'public/css'
mkpath 'public/assets'


# HTML
`haml index.haml > public/index.html`

# CSS
cp 'main.css', 'public/css/'

# Javascript
`coffee -cj public/js/game.js \
  src/components.coffee \
  src/processes.coffee \
  src/game.coffee \
  src/main.coffee`

# JSON
require 'json'
require 'yaml'
tilesets = YAML.load_file('tilesets.yml')
JSON.dump(tilesets, File.open('public/assets/tilesets.json', 'w'))
