
game = new Game()

# Temporary setup

img = new Image()
img.addEventListener('load', ->
  game.run()
)
# Load the image
img.src = 'chasz.png'


sprites =
  grass: new Sprite(img, 0, 0)
  grass2: new Sprite(img, 1, 0)
  sand: new Sprite(img, 0, 1)
  water: new Sprite(img, 2, 0)


a = new Vector(1, 2)
b = new Vector(3, 4)
# Should return "Vector {x: 2, y: 2}"
# console.log(b - a)
