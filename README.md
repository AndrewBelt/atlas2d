
# Atlas 2D

Codenamed Atlas 2D for now, this project is an HTML5 browser-based sandbox MMORPG with crafting, skills, multiplayer collaboration, and more.

## Setup

First you should compile the client code. You'll need a number of dependencies, including [HAML](http://haml.info/) `gem install haml` and [CoffeeScript](http://coffeescript.org/) `npm install -g coffee-script`.

    cd client
    ./compile.rb

Then serve the `client/public` directory on the root URL of a webserver. You can use Python's build in ad-hoc server, or your own webserver, but loading local files may not work.

    cd public
    python2 -m SimpleHTTPServer

In another terminal session, run the primitive WebSocket game server. You'll need [em-websocket](https://github.com/igrigorik/em-websocket) `gem install em-websocket` for this.

    ruby server/test.rb

Finally, navigate to [localhost:8000](http://localhost:8000) to try out the game.


## Authors

- [Andrew Belt](https://github.com/AndrewBelt)
- [Marviel](https://github.com/Marviel)
- your-name-here
