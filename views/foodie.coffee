last_filter = ""

# Find rest id according to dom row
parse_row_id = (row) ->
  parseInt(row.id.match(/(rest|dinner)_(-?[\d]+)/)[2])

invoke_filtering = () ->
  filter_text = $("#filter").val()
  return if filter_text == last_filter
  for id, rest of window.restData
    row = $(rest.row)
    if filter(filter_text, rest.name) then row.show() else row.hide()
  last_filter = filter_text

filter = (filter_text, rest_name) ->
  # "fuzzy" fuzzy matching: true iff all chars from filter_text are somewhere in rest_name (=orderly, but not consequently)
  pos = -1
  for char, index in filter_text.split("")
    pos = rest_name.indexOf(char, pos + 1)
    return false if pos == -1
  true

window.confirmAnnounce = (id, dinner) ->
  rest = window.restData[id]
  comments = window.prompt("הערות עבור המשלוח של" + "\n" + rest.name)
  if comments != null
    img = $("#status_img_" + id)
    previousImgSrc = img.attr("src")
    img.attr("src", "loading.gif")
    $.ajax "announce",
      data:
        rest_id: id
        comments: comments
        dinner: dinner && "true"
      success: ->
        img.attr("src", "check.png")
      error: ->
        img.attr("src", previousImgSrc)
        window.alert("שליחת הודעה עבור" + " \"" + rest.name + "\" " + "נכשלה. באסוש.")


$(document).ready ->
  $(".restRow").hover( ->
    $(this).addClass("restHover")
  , ->
    $(this).removeClass("restHover")
  )

  # Find all rest rows and bind them
  $(".restRow").each (index, row) ->
    rest_id = parse_row_id(row)
    window.restData[rest_id].row = row
  setInterval invoke_filtering, 500
