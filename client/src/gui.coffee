
GUI =
  init: ->
    $('#chat-input').keypress (e) ->
      if e.keyCode == 13 # Enter
        text = $(this).val()
        $(this).val('')
        if text
          GUI.chatDisplay(text)
          # Request.chatSend(text)
  
  chatDisplay: (text) ->
    $('<li>').text(text).appendTo('#messages')
    $('#messages').scrollTop($('#messages').prop('scrollHeight'));
  
  syncItems: ->
    inventoryDiv = $('#inventory')
    items = inventoryDiv.children().toArray()
    
    # Add entities not already in the inventory GUI
    for id, entity of Game.entities
      if entity.possession and entity.possession.owner == 0
        item = inventoryDiv.children("#item-#{id}")
        if item.length
          # The item already exists in the inventory.
          # Remove it from the list of items to remove
          itemIndex = items.indexOf(item[0])
          items.splice(itemIndex, 1) unless itemIndex < 0
        else
          # Create the item
          item = @createItem(entity)
          item.attr('id', "item-#{id}")
          item.appendTo(inventoryDiv)
    
    # Delete entities which have been removed
    $(items).remove()
  
  createItem: (entity) ->
    canvas = document.createElement('canvas')
    canvas.width = 16 * 2
    canvas.height = 16 * 2
    
    ctx = canvas.getContext('2d')
    ctx.mozImageSmoothingEnabled = false
    ctx.webkitImageSmoothingEnabled = false
    
    ctx.save()
    ctx.scale(2, 2)
    graphic = Game.graphics[entity.graphic.name]
    graphic.draw(ctx, new Vector(), entity.graphic)
    ctx.restore()
    return $(canvas)