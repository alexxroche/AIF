(function($) {
  var soundCloudApiKey = 'cfd1c03433dca45c16f2f9ecb0ae5a2b'; //Notice
  //var soundCloudApiKey = '3b63847a403eb9c1c75cb28f4f68b14d'; //desktop - does not work due to linklocal reload blocking in FF and GC
  var user_id = '';
  var api = $.sc.api(soundCloudApiKey, {
    onAuthSuccess: function(user, container) {
    // for ff 15.0.1 (and possibly others)
     //if ( ! jQuery.isArray( user ) ) {
     if ( ! user.id ) { user = JSON.parse(user); } // for ff 15.0.1 (and possibly others - not needed for Chrome 18.0.1025.162) 
        user_id = user.id;
       // console.log(user);
      $('<span class="username">Logged in as: <strong title="' + user_id + '">' + user.username + '</strong></a>').prependTo(container);
      $('#function').removeAttr("class", "hidden");
      $('#footer').removeAttr("class", "hidden");
    }
  });

 function del_track(g, t, i){
  // add sanity check code
    api.delete('/groups/' + g + '/contributions/' + t , function(reply, e){
      if(e){
        alert("track del ERROR");
        }else{
            //alert('removing track ' + track_id + ' from group ' + group_id);
         console.log('track', t, ' removed from group', g);
        }
    });
 }

 function add_track(g, t, i){
  // add sanity check code
    api.put('/groups/' + g + '/contributions/' + t, function(reply, e){
        if(e){ console.log('err:' + e + ',reply:' + reply); alert('Failed to add track to group:' + e.message);}else{
            console.log('track ' + t + ' added to group ' + g);
        }
    });
 }

 // wait for the API to be available
 $(document).bind($.sc.api.events.AuthSuccess, function(event) {


// countdown
	var note = $('#note'),
		ts = (new Date()).getTime() + 6*60*60*1000;
		//ts = (new Date()).getTime() + 2*1000;
	$('#countdown').countdown({
		timestamp	: ts,
		callback	: function(days, hours, minutes, seconds){
			var message = "";
			//message += days + " day" + ( days==1 ? '':'s' ) + ", ";
			message += hours + " hour" + ( hours==1 ? '':'s' ) + ", ";
			message += minutes + " minute" + ( minutes==1 ? '':'s' ) + " and ";
			message += seconds + " second" + ( seconds==1 ? '':'s' ) + " <br />";
		    message += "left until automatic reload";
			note.html('<br />' + message);

    // trigger page auto_reload ( (24*60*60) / $reload_count ) where reload_count is between 1 (once a day) and 4
            if((new Date()) > ts){ 
                var r = group_cycle('do'); 
                if(r){
                    console.log('autoCycle failed:' + r);
                    alert('autoCycle failed:' + r);
                    //window.location.reload(true);
                }else{
                    console.log('auto cycle triggered');
                    //alert('autoCycle done:' + r);
                    window.location.reload(true);
                }
            }
		}
	});

// Methods in my madness

  $('#logout').submit(function(e){
    e.preventDefault();
    api.logout();
    console.log('loged out');
    return false;
  });
	
// main trigger

  $('#group_cycle').submit(function(e){
     e.preventDefault();
     group_cycle();
     return false;
  });

 function group_cycle(i) {

   var count_span='<span id="count_span"><span id="cpgc-msg">Groups left to cycle</span>\
                <span id="group_count" class="red"></span>\
                <span id="cptc-msg">Tracks left to cycle</span>\
                <span id="track_count" class="red"></span></span>';
 
// get an array of your tracks
   var tracks = [];
   api.get('/me/tracks', function(data) {
     // GglChrome says array, FF says string, (which is technically correct, but does not help me!)
     if ( ! jQuery.isArray( data ) ) {
        data = $.parseJSON(data);
       // alert($.type(data)); // GC says array, FF says string!
       data = $.makeArray( data ); // for ff 15.0.1 (and possibly others - not needed for Chrome 18.0.1025.162) 
     }
     $.map( data, function(track, i){
        if(track.id){
            tracks.push(track.id);
        }
     });

// so here we find the users groups
    api.get("/users/" + user_id + "/groups", function(data) {
     if ( ! jQuery.isArray( data ) ) { data = $.makeArray( data ); }
     if ( jQuery.isArray( data ) ) {
      //console.log('and here are your groups', data);
        $.map( data, function(group, i){ 
           $('#function').append(count_span); 
           if ( ! jQuery.isArray( group ) ) { group = $.makeArray( group ); }
           if ( jQuery.isArray( group ) ) {
// then we loop through the tracks in that group looking for the ones from our user
            $('#group_count').html(group.length); 
            alert('set group_count to:', group.length);
           }else{
            $('#group_count').html('1');
            api.get("/groups/" + group.id + "/contributions", {user_id: "$user_id}"}, function(track) {
            //api.get("/groups/" + group.id + "/contributions/", {user_id: $user_ud}, function(track) 
                if ( ! jQuery.isArray( track ) ) { track = $.makeArray( track ); }
                if ( jQuery.isArray( track ) ) {
                    $('#track_count').html(track.length); 
                   // alert('you have ' + track.length + ' tracks in this group');
                    $.map( track, function(row, j){
                        //console.log('here is the group', track);
                        //console.log('and here are the tracks in group', group.id);
                        if ( ! jQuery.isArray( row ) ) {
                            row = $.makeArray( row );
                        }
                        if ( jQuery.isArray( row ) ) {
                            var len = row.length;
                            //console.log(arrayNow, ' has ', len, ' elements');
                            $.each(row, function(index){  
                                this_row = row[index];
                              if(this_row.user_id == user_id){
                                //console.log('track', this_row.id, ', in group:' + group.id + ' is by you (', this_row.user_id, ')');
                                // remove track from group
                                del_track(group.id, row.id);
                                // add track to group (we want it back in as soon as possible, and calling add_track twice does not hurt
                                add_track(group.id, row.id);
                                var track_count = $('#track_count').html() - 1;
                                $('#track_count').html(track_count);
                              }else{
                                //console.log('track:', this_row.id, ', in group:' + group.id + ' is by ', this_row.user_id, ', NOT YOU');
                                // remove _other-ppl's_ track from group ? (no)
                                //del_track(group.id, row.id, e);
                              }
                            });
                        }
                    // end track loop
                    }).each(tracks, function(i, t){
                        //console.log('adding ' + t + ' to group ' + group.id);
                        add_track(group.id, t);
                    });

                }
                var group_count = $('#group_count').html() - 1;
                $('#group_count').html(group_count);
                if($('#group_count').html() <= 0){
                    console.log('removing count_span');
                    //alert('all done');
                    // wait a second and then remove the cound_span
                    setTimeout(function(){ $('#count_span').remove(); }, 1500);
                }
            });
           }
        });
     }
    }); // end of group loop
   }); // end of tracks
  //return 'success';
  } // end of group_cycle function
 });
})(jQuery);
