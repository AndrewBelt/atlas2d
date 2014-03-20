### Usage ###
# pip install autobahn
# python2 test.py

import json
import autobahn.twisted.websocket

class AtlasProtocol(autobahn.twisted.websocket.WebSocketServerProtocol):
  def onConnect(self, request):
    print("Client connecting: {}".format(request.peer))
  
  def onOpen(self):
    print("WebSocket connection open.")
    player = {
      'entity': {
        'name': 'player'
      }
    }
    
    self.sendMessage(JSON.dumps([
      {
        'cmd': 'entityCreate',
        'id': 0,
        'entity': player
      },
      {
        'cmd': 'setPlayer',
        'id': 0
      }
    ]))
  
  def onMessage(self, payload, isBinary):
    if isBinary:
      print("Binary message received: {} bytes".format(len(payload)))
    else:
      print("Text message received: {}".format(payload.decode('utf8')))
  
  def onClose(self, wasClean, code, reason):
    print("WebSocket connection closed: {}".format(reason))


if __name__ == '__main__':
  import sys
  import twisted.python
  import twisted.internet
  
  twisted.python.log.startLogging(sys.stdout)
  
  factory = autobahn.twisted.websocket.WebSocketServerFactory("ws://localhost:8080", debug = False)
  factory.protocol = AtlasProtocol
  
  twisted.internet.reactor.listenTCP(8080, factory)
  twisted.internet.reactor.run()
