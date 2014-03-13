
window.onload = ->
  Game.init()
  
  # AJAX request the tileset data
  # TEMP
  tilesetsRequest = new XMLHttpRequest()
  tilesetsRequest.onreadystatechange = ->
    if tilesetsRequest.readyState == 4 and tilesetsRequest.status == 200
      addGraphics(JSON.parse(tilesetsRequest.responseText))
      Game.run()
  tilesetsRequest.open('GET', 'assets/tilesets.json', true)
  tilesetsRequest.send()
  
  # TEMP
  addGraphics = (data) ->
    for filename, tilesetData of data
      image = new Image()
      image.src = "assets/#{filename}"
      
      for graphicName, graphicData of tilesetData
        graphic = new Graphic(image, graphicData)
        Game.graphics[graphicName] = graphic
