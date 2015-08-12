
function results (d) {
  $('#results').html("<hr>" + d.results + "<hr>")
}

function choice (name) {
  return $('input:radio[name=' + name + ']:checked').val()
}

function search () {
  $('#results').html('<img src=spinner.gif>')
  params = {
    find: choice('find'),
    within: choice('within'),
    match: choice('match'),
    query: $('input.query').val()
  }
  window.history.pushState(params, "Search",'http://' + location.host + '/#/' + $.param(params))
  $.get('/search', params, results, 'json')
}

function keystroke (e) {
  if (e.keyCode == 13) {
    search()
  }
}

function explain(e) {
  var eg = $(this).data('eg')
  if (eg) {
    $('#eg').text('eg. ' + eg)
  }
}

function run () {
  var regex = /(\w+?)=([^&]+)/g
  var params = decodeURIComponent(location.hash)
  while ((p = regex.exec(params)) !== null) {
    switch (p[1]) {
      case 'find':
      case 'within':
        $('input:radio[name=' + p[1] + '][value=' + p[2] + ']').prop('checked',true)
        break
      case 'query':
        $('input.query').val(p[2].replace(/\+/g,' '))
    }
  }
  search()
}

function start () {
  $("input").keyup(keystroke)
  $("input").click(explain)
  if (location.hash.length) {run()}
}

$(start)
