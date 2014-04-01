require 'sinatra'
require 'haml'
require 'less'
require 'coffee-script'
require 'json'
require 'yaml'

set :public_folder, './static'
set :views, '.'


COFFEESCRIPTS = %w{
  src/util.coffee
  src/network.coffee
  src/controller.coffee
  src/renderer.coffee
  src/processes.coffee
  src/game.coffee
  src/main.coffee
  src/gui.coffee
}


get '/' do
  haml :index
end

get '/game.css' do
  less :game
end

get '/game.js' do
  src = COFFEESCRIPTS.collect {|file| IO.read(file) }.join
  coffee src
end

get '/tilesets.json' do
  content_type 'application/json'
  JSON.dump(YAML.load_file('tilesets.yml'))
end
