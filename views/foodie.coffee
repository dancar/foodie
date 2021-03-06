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

window.updateFilter = () ->
  window.filterText = $("#filter").val()
  window.showRests()
  $("#filter").blur()
  return false

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
  ans = window.currentTab == "allTab"
  ans ||= window.currentTab == "expectedTab" && rest.is_expected
  ans ||= window.currentTab == "dinnersTab" && rest.is_dinner

window.showRests = () ->
  restsShown = false
  for id, rest of window.restData
    showRest = rest_visible(rest) && filter(window.filterText, rest.name)
    restsShown ||= showRest
    rest.row.style.display = if showRest then "table-row" else "none"

  $("#empty").css("display", if restsShown then "none" else "table-cell")


$(document).ready ->
  $(".restRow").hover( ->
    $(this).addClass("restHover")
  , ->
    $(this).removeClass("restHover")
  )

  $('.tab').click (e)->
    window.currentTab = e.target.id
    $(".tab").removeClass "selectedTab"
    $(e.target).addClass "selectedTab"
    showRests()

  # Find all rest rows and bind them
  $(".restRow").each (index, row) ->
    rest_id = parse_row_id(row)
    window.restData[rest_id].row = row
  window.currentTab = "expectedTab"
  showRests()
