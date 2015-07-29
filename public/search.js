
function results (d) {
  $('#results').html("<hr>" + d.results + "<hr>")
}

function choice (name) {
  return $('input:radio[name=' + name + ']:checked').val()
}

function search (e) {
  if (e.keyCode == 13) {
    $('#results').html('<img src=spinner.gif>')
    // url = $('input:radio[name=query]:checked').val();
    params = {
      find: choice('find'),
      within: choice('within'),
      query: $('input.query').val()
    }
    $.get('/search', params, results, 'json')
  }
}

function explain(e) {
  var eg = $(this).data('eg')
  if (eg) {
    $('#eg').text('eg. ' + eg)
  }
}

function start () {
  $("input").keyup(search)
  $("input").click(explain)
}

$(start)
