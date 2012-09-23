(function($) {
  var soundCloudApiKey = 'cfd1c03433dca45c16f2f9ecb0ae5a2b'; //Notice
  //var soundCloudApiKey = '3b63847a403eb9c1c75cb28f4f68b14d'; //desktop - does not work due to linklocal reload blocking in FF and GC
  var user_id = '';
  var track_count = [];
  var group_count = [];
  var debug = true;
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
      if( debug ){ 
        $('input#group_cycle').removeAttr("class", "orange");
        $('span.username').append('<br />You are in <span class="red">DEBUG</span> mode so nothing is really going to happen');
      }
    }
  });
// then trigger it on page auto_reload ( (24*60*60) / $reload_count ) where reload_count is between 1 (once a day) and 4

 function del_track(g, t, i){
  // add sanity check code
    if( debug ){ return true; }
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
    if( debug ){ return true; }
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

  api.get('/me/tracks', function(data){
     if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
     $.map( data, function(track){
        track_count.push(track.id);
     });
  });

 var page_size = 80;
 // http://developers.soundcloud.com/docs/api/guide#pagination
 // going to have to step through pages while(api.get("/users/" + user_ud + "/groups", { limit: page_size, offset: page }, function(data) { return data.length;}) == page_size 
  api.get("/users/" + user_id + "/groups", { limit: page_size }, function(data) {
  //api.get('/me/groups', function(data) {
     if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
     $.map( data, function(group){ 
        group_count.push(group.id);
     });
  });


 function group_cycle(i) {

   var tracks = [];
   var count_span='<span id="count_span"><span id="cpgc-msg">Groups left to cycle</span>\
                <span id="group_count" class="red"></span>\
                <span id="groups" class="orange">\/' + group_count.length + '</span>\
                <span id="cptc-msg">Tracks left to cycle</span>\
                <span id="track_count" class="red"></span>\
                <span id="tracks" class="orange">\/' + track_count.length +'</span></span>';
 
// get an array of your tracks
   api.get('/me/tracks', function(data) {
     if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
     $.map( data, function(track, i){
        tracks.push(track.id);
     });

// so here we find the users groups
    api.get("/users/" + user_id + "/groups", { limit: page_size }, function(data) {
     // not sure that we really want to make these into arrays, but it works for now
     if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
   // alert($.type(data));
     $('#function').append(count_span); 
     $('#group_count').html(data.length); 
     $('#track_count').html('1');
     //console.log('set the track_count');
     if ( jQuery.isArray( data ) ) {
      //console.log('and here are your groups', data);
        $.map( data, function(group) { 
           //if ( ! jQuery.isArray(group) ) { group = $.parseJSON(group); group = $.makeArray(group); }
            // don't know why we don't need the previous line but it could be because I only have one track
            
           if ( jQuery.isArray( group ) ) {
// then we loop through the tracks in that group looking for the ones from our user
            //$('#group_count').html(group.length); 
            alert('set group_count to:', group.length);
           }else{
            $('#group_count').html('1');
            api.get("/groups/" + group.id + "/contributions", {user_id: user_id }, function(track) {
               var tracks_left = parseInt( $('#track_count').html() ) + 1;
               if(tracks_left >= 0 && ( tracks_left <= track_count.length )){
                $('#track_count').html(tracks_left);
               }else{
                $('#track_count').html('1');
               }
            //api.get("/groups/" + group.id + "/contributions/", {user_id: $user_ud}, function(track) {
                if ( ! jQuery.isArray(track) ) { track = $.parseJSON(track); track = $.makeArray(track); }
                if ( jQuery.isArray( track ) ) {
                   // alert('you have ' + track.length + ' tracks in this group');
                    $.map( track, function(row){
                        //console.log('here is the group', track);
                        //console.log('and here are the tracks in group', group.id);
                        if ( jQuery.isArray( row ) ) {
                            if( row.user_id == user_id ){
                                //console.log('contrib data:', row.id);
                                alert('your track');
                            }else{
                                alert('bu bub bub but what?');
                            }
                        }else{
                            var arrayNow = $.makeArray( row );
                            var len = arrayNow.length;
                            //console.log(arrayNow, ' has ', len, ' elements');
                            $.each(arrayNow, function(index){  
                                this_row = arrayNow[index];
                              if(this_row.user_id == user_id){
                                //console.log('track', this_row.id, ', in group:' + group.id + ' is by you (', this_row.user_id, ')');
                                // remove track from group
                                del_track(group.id, row.id);
                                // add track to group (we want it back in as soon as possible, and calling add_track twice does not hurt
                                add_track(group.id, row.id);
                                var tracks_left = parseInt( $('#track_count').html() ) + 1;
                                if(tracks_left >= 0 && ( tracks_left <= track_count.length ) ){
                                    $('#track_count').html(tracks_left);
                                }
                              }else{
                               // alert('track:' + this_row.id + ' belongs to ' + this_row.user_id + ' not you(' + user_id + ')');
                                //console.log('track:', this_row.id, ', in group:' + group.id + ' is by ', this_row.user_id, ', NOT YOU');
                                // remove _other-ppl's_ track from group ? (no)
                                //del_track(group.id, row.id, e);
                              }
                            });
                        }
                    // end track loop
                    });
                    //
                    $.each(tracks, function(t){
                        //console.log('adding ' + t + ' to group ' + group.id);
                        //add_track(group.id, tracks[t], function(){
                        //   var track_count = parseInt( $('#track_count').html() ) + 1;
                        //   $('#track_count').html(track_count);
                        //});
                        add_track(group.id, tracks[t]);
                        if(t == 11){  console.log('re-adding:' + tracks[t] + ' to group:' +group.id); }
                        var tracks_left = parseInt( $('#track_count').html() ) + 1;
                        if(tracks_left >= 0 && ( tracks_left <= track_count.length ) ){
                            $('#track_count').html(tracks_left);
                        }
                    });

                }
                var groups_left = parseInt( $('#group_count').html() ) + 1;
                if( parseInt( $('#track_count').html() ) >= track_count.length ){
                    // this is a dirty hack - because jQuery is async and we are trying to be sync!
                    $('#track_count').html('1');
                }
                if( parseInt( $('#group_count').html() ) >= group_count.length ){
                    console.log('removing count_span');
                    // wait a second and then remove the cound_span
                    setTimeout(function(){ $('#count_span').remove(); }, 1500);
                }else{
                    $('#group_count').html(groups_left);
                }
            });
           }
        // add all tracks back
         if( ! isNaN(parseInt(group.id, 10)) ){
           $.each(tracks, function(t){
              add_track(group.id, tracks[t]);
              if(t == 11){  console.log('adding:' + tracks[t] + ' to group:' +group.id); }
              var tracks_left = parseInt( $('#track_count').html() ) + 1;
              if(tracks_left >= 0){
                  $('#track_count').html(tracks_left);
              }else{
                //  $('#track_count').html('1');
              }
           });
         }else{
            console.log('group.id is not an int');
         }
       });
     }
        // end of loop
    });


   });
  }
 return 'success';
 });
})(jQuery);
