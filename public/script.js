$(document).ready(function() {

  $('#check-form').submit(function(e) {
    e.preventDefault();
    $.ajax({
      url: $('#check-form').attr('action'),
      type: 'POST',
      data: $('#check-form').serialize(),
      error: function() {
        alert('ajax error');
      },
      success: function(data) {
        $('#check-result').empty();
        line = $('<hr></hr>');
        $('#check-result').append(line);

        for (var user in data ) {
          div = $('<div class="check-result-user" id="' + user + '"></div>');
          $('#check-result').append(div);
          username = $('<h2>'+ user +'</h2>');
          div.append(username);
          if ( data[user].length != 0 ) {
            div.append($('<p>' + data[user].length + ' Missing Badges:</p>'));
            ul = $('<ul id="' + user + '"></ul>');
            div.append(ul);
            for ( var i = 0 ; i < data[user].length ; i++ ) {
              ul.append('<li>' + data[user][i] + '</li>');
            }
          } else {
            div.append($('<p>No Missing Badges.</p>'));
          }
        }
      }
    });
  });

  $('#user-form').submit(function(e) {
    e.preventDefault();
    $.ajax({
      url: $('#user-form').attr('action'),
      type: 'POST',
      data: $('#user-form').serialize(),
      error: function() {
        alert('ajax error');
      },
      success: function(data) {
        $('.user-output').empty();
        trend_link = $('<a>See the chart</a>').attr('href', '/user/' + $('#home-form-username').val());
        $('.user-output').append(trend_link);
        $('.user-output').append($('<table id="user-output-table"></table>'))
        for ( var ary in data ) {
          $('#user-output-table').append($('<tr><td>' + ary + '</td><td>' + data[ary] + '</td></tr>'));
        }
      }
    });
  });

});
