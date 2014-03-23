# This file controlls any HTML elements outside of the main game canvas.

GUI =
  init: ->
    $('#chat-input').keypress (e) ->
      if e.keyCode == 13 # Enter
        text = $(this).val()
        $(this).val('')
        if text
          Request.chatSend(text)
          $('#chat-input').blur()
  
  pushMessage: (text, type) ->
    li = $('<li>').text(text).attr('class', type)
    li.appendTo('#messages')
    $('#messages').scrollTop($('#messages').prop('scrollHeight'));
