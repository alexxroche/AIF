(function($) {
// (global)  variables
  var protocols = ['imap4','smtp'];
  var debug = true;
  var show_db = true;
  var ac = new Object(); // associative array of accounts { folder: { [message_headers] } }
  var offset_html = '<select id="offset_html" name="offset">';
  var h_html = '<select id="h_html" name="h">';
  var m_html = '<select id="m_html" name="m">';
  var username = ''; // imap login 
  var password = ''; // clear text
  var passwd = ''; // encrypted
  var imap_server = 'localhost';
  var imap_port = 143;

// auth-check
  var api = $.imap.api(username, password, imap_server, {
    onAuthSuccess: function(user, container) {
     //if ( ! user.id ) { user = JSON.parse(user); }
      $('<span class="username">Logged in as: <strong title="' + user_id + '">' + user.username + '</strong></a>').prependTo('#header');
      $('#footer').removeAttr("class", "hidden");
      if( debug ){ 
        $('span.username').append('<br />You are in <span class="red">DEBUG</span> mode so nothing is going to be changed');
      }
      setTimeout(function(){ $('.loading').remove(); }, 1000);
    }
  });

 $(document).ready(function() {
      $('#container').prepend('<div id="body"><table><tr><td><span id="folders"></span></td><td><span id="headers"></span></td></tr></table></div>');
 });

})(jQuery);
