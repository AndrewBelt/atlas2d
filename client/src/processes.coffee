
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
      direction = switch
        when delta.y < 0 then "up"
        when delta.y > 0 then "down"
        when delta.x < 0 then "left"
        when delta.x > 0 then "right"
      
      if player.graphic.animation != direction
        Request.playerFace(direction)
        player.graphic.animation = direction
      
      player.graphic.animating = true
      
      # Scale approximately by 1/sqrt(2) ~ 3/4 if going diagonal
      delta.mulBy(0.75) if delta.x != 0 and delta.y != 0
      delta.mulBy(Game.settings.speed / 16)
      # Correct due to framerate skew
      delta.mulBy(Math.min(60 * Game.lastDelta, 2))
      
      oldPosition = Vector.fromArray(player.location.position)
      playerBox = Rect.fromVectors(oldPosition.add(delta), new Vector(1, 1))
      
      # TEMP
      # Collide
      for id, entity of Game.entities
        if entity != player and entity.location and entity.physics and entity.physics.collides
          entityBox = Rect.fromArrays(entity.location.position, [1, 1])
          if playerBox.overlaps(entityBox)
            # Choose the smallest delta which would fix the impending collision
            # There are four choices for a rectangle-rectangle collision.
            collisionDeltas = [
              new Vector(entityBox.x + entityBox.w - playerBox.x, 0),
              new Vector(entityBox.x - playerBox.w - playerBox.x, 0),
              new Vector(0, entityBox.y + entityBox.h - playerBox.y),
              new Vector(0, entityBox.y - playerBox.h - playerBox.y)
            ]
            # Find the minimum delta
            collisionDelta = collisionDeltas.reduce (a, b) ->
              if a and a.max() < b.max() then a else b
            
            playerBox.x += collisionDelta.x
            playerBox.y += collisionDelta.y
      
      # Commit the movement
      newPosition = playerBox.position()
      player.location.position = newPosition.toArray()
      
      # If the player moves onto a new cell, send it over the network
      roundedPosition = newPosition.round()
      if !roundedPosition.isEqual(oldPosition.round())
        Request.playerMove(roundedPosition)
