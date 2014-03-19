
# This is where new processes go until they find a home in a new file.

Movement =
  move: ->
    return unless Game.playerId
    player = Game.entities[Game.playerId]
    return unless player
    
    delta = new Vector(0, 0)
    delta.x = Controller.isPressed(39) - Controller.isPressed(37)
    delta.y = Controller.isPressed(40) - Controller.isPressed(38)
    
    if delta.isZero()
      player.graphic.animating = false
    else
      # Change animation
      player.graphic.animation = switch
        when delta.y < 0 then "up"
        when delta.y > 0 then "down"
        when delta.x < 0 then "left"
        when delta.x > 0 then "right"
      player.graphic.animating = true
      
      position = Vector.fromArray(player.location.position)
      
      # Scale approximately by 1/sqrt(2) ~ 3/4 if going diagonal
      delta.mulBy(0.75) if delta.x != 0 and delta.y != 0
      delta.mulBy(Game.settings.speed / 16)
      # Correct due to framerate skew
      delta.mulBy(Math.min(60 * Game.lastDelta, 2))
      
      playerBox = new Rect(position.add(delta), new Vector(1, 1))
      
      # TEMP
      # Collide
      for id, entity of Game.entities
        if entity.physics and entity.physics.collides and entity.location and entity != player
          entityBox = new Rect(Vector.fromArray(entity.location.position), new Vector(1, 1))
          if playerBox.overlaps(entityBox)
            return
      
      # Commit the movement
      player.location.position = playerBox.position.toArray()
      Request.playerMove(playerBox.position)
