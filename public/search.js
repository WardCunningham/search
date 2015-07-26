
function results (d) {
  $('#results').html("<hr>" + d.results + "<hr>")
}

function search (e) {
  if (e.keyCode == 13) {
    $('#results').html('<img src=spinner.gif>')
    url = $('input:radio[name=query]:checked').val();
    $.get(url, {words: $('input.query').val()}, results, 'json')
  }
}

function start () {
  $("input").keyup(search)
}

$(start)
