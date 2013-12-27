# Find rest id according to dom row
parse_row_id = (row) ->
  parseInt(row.id.match(/(rest|dinner)_(-?[\d]+)/)[2])

filter = (filter_text, rest_name) ->
  return true unless filter_text
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
      type: "POST"
      data:
        rest_id: id
        comments: comments
      success: ->
        img.attr("src", "check.png")
      error: ->
        img.attr("src", previousImgSrc)
        window.alert("שליחת הודעה עבור" + " \"" + rest.name + "\" " + "נכשלה. באסוש.")

window.rest_visible = (rest) ->
  window.showAll || rest.is_expected

window.showRests = () ->
  filterText = $("#filter").val()
  for id, rest of window.restData
    showRest = false
    showRest ||= window.showAll
    showRest ||= rest.is_expected
    showRest &&= filter(filterText, rest.name)
    rest.row.style.display = if showRest then "table-row" else "none"


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
  setInterval showRests, 750
  window.showAll = false
  showRests()
