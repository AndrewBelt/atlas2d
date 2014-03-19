#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

# Directories
puts "Creating directories..."
mkpath 'public'
mkpath 'public/js'
mkpath 'public/css'
mkpath 'public/assets'


# HTML
puts "Compiling HTML..."
`haml index.haml > public/index.html`

# CSS
puts "Compiling CSS..."
`lessc main.less > public/css/main.css`

# Javascript
puts "Compiling Javascript..."
coffeescripts = %w{
  src/util.coffee
  src/network.coffee
  src/controller.coffee
  src/renderer.coffee
  src/processes.coffee
  src/game.coffee
  src/main.coffee
  src/gui.coffee
}.join ' '
`coffee -cj public/js/game.js #{coffeescripts}`

# JSON
puts "Compiling JSON..."
require 'json'
require 'yaml'
tilesets = YAML.load_file('tilesets.yml')
JSON.dump(tilesets, File.open('public/assets/tilesets.json', 'w'))
