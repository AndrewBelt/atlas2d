
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
        graphic = null
        
        if graphicData instanceof Array
          graphic = new StaticGraphic()
          graphic.source = Vector.fromArray(graphicData)
        else if graphicData.frames?
          graphic = new AnimatedGraphic()
          graphic.frames = for coords in graphicData.frames
            Vector.fromArray(coords)
          graphic.delay = graphicData.delay
          graphic.size = Vector.fromArray(graphicData.size)
        
        graphic.image = image
        Game.graphics[graphicName] = graphic
