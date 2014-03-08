
Game.init()


# AJAX request the tileset data
tilesetsRequest = new XMLHttpRequest()
tilesetsRequest.onreadystatechange = ->
  if tilesetsRequest.readyState == 4 and tilesetsRequest.status == 200
    addSprites(tilesetsRequest.responseText)
    Game.run()
tilesetsRequest.open('GET', '/assets/tilesets.json', true)
tilesetsRequest.send()

addSprites = (text) ->
  data = JSON.parse(text)
  for filename, tilesetData of data
    image = new Image()
    image.src = "/assets/#{filename}"
    
    for spriteName, coord of tilesetData
      sprite = new Sprite(image, new Vector(coord[0], coord[1]))
      Game.sprites[spriteName] = sprite
