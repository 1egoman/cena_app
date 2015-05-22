# reverse filter (reverse the displayed list)
@app.filter 'reverse', ->
  (items) ->
    if typeof items == 'object'
      items.slice().reverse()
    else
      []
