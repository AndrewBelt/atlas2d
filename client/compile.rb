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
puts "Compiling HAML..."
`haml index.haml > public/index.html`

# CSS
puts "Copying assets..."
cp 'main.css', 'public/css/'

# Javascript
puts "Compiling CoffeeScript..."
coffeescripts = %w{
  src/util.coffee
  src/processes.coffee
  src/game.coffee
  src/main.coffee
}.join ' '
`coffee -cj public/js/game.js #{coffeescripts}`

# JSON
puts "Compiling JSON..."
require 'json'
require 'yaml'
tilesets = YAML.load_file('tilesets.yml')
JSON.dump(tilesets, File.open('public/assets/tilesets.json', 'w'))
