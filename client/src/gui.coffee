
GUI =
  init: ->
    $('#message-input').keypress (e) ->
      if e.keyCode == 13
        val = $(this).val()
        $(this).val('')
        if val
          Request.chatSend(val)
  chatDisplay: (text) ->
    $('<p>').text(text).appendTo('#messages')
    $('#messages').scrollTop($('#messages').prop('scrollHeight'));
