
# atlas2d

## Usage

Run the primitive test server to get the client working.

    ruby server/test.rb

Then compile the client code. You'll need a number of dependencies, including HAML `gem install haml` and Coffeescript `gem install coffee-script`.

    cd client
    ./compile.rb

You can then serve the `client/public` directory on the root of a server.

    python2 -m SimpleHTTPServer

Finally, navigate to localhost:8000 to use the client.


## Authors

- [Andrew Belt](https://github.com/AndrewBelt)
- your-name-here