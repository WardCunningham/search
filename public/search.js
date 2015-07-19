
function results (d) {
  console.log('results', d)
  $('#results').html(d.results)
}

function search (e) {
  if (e.keyCode == 13) {
      console.log('search', $(this).val())
      $.get('/search', {words: $(this).val()}, results, 'json')
  }
}

function start () {
  $("input").keyup(search)
}

$(start)
