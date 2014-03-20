
$(document).ready ->
  Game.init()
  
  # AJAX request the tileset data
  $.getJSON 'assets/tilesets.json', (data) ->
    addGraphics(data)
    Game.run()
  
  addGraphics = (data) ->
    for filename, tilesetData of data
      image = new Image()
      image.src = "assets/#{filename}"
      
      for graphicName, graphicData of tilesetData
        graphic = new Graphic(image, graphicData)
        Graphic.all[graphicName] = graphic
