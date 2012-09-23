(function($) {
// (global)  variables
  //var soundCloudApiKey = 'cfd1c03433dca45c16f2f9ecb0ae5a2b'; //Notice
  //var soundCloudApiKey = '542bdb53829b5b7cf02988d566c708de'; //dev_Notice
  var soundCloudApiKey = '3b63847a403eb9c1c75cb28f4f68b14d'; //dev_Notice
  var app = 'Notice_SoundCloud';
  var db_key = 'my_lxr_data'; //could just user scAPIkey + app
  var debug = false;
  var show_db = false;
  //var page_size = 50; //the default
  var page_size = 75; //the default
  var tracks = new Object(); // associative array of track data (we only really need id,title,URI)
  var t = []; //array of track IDs
  var g = []; //array of group IDs
  var offset_html = '<select id="offset_html" name="offset">';
  var h_html = '<select id="h_html" name="h">';
  var m_html = '<select id="m_html" name="m">';
  for (var h = 0;h<=24;h++) {
            offset_html = offset_html + '<option>' + h + ' </option>';
            h_html = h_html + '<option>' + h + ' </option>';
            m_html = m_html + '<option>' + h + ' </option>';
  }
  for (var m = 25;m<=59;m++)
            m_html = m_html + '<option>' + m + ' </option>';
  offset_html = offset_html + '</select>';
  h_html = h_html + '</select>';
  m_html = m_html + '</select>';

// auth-check
  var api = $.sc.api(soundCloudApiKey, {
    onAuthSuccess: function(user, container) {
     if ( ! user.id ) { user = JSON.parse(user); } // for ff 15.0.1 (and possibly others - not needed for Chrome 18.0.1025.162) 
        user_id = user.id;
      $('<span class="username">Logged in as: <strong title="' + user_id + '">' + user.username + '</strong></a>').prependTo(container);
      $('#footer').removeAttr("class", "hidden");
      if( debug ){ 
        $('input#group_cycle').removeAttr("class", "orange");
        $('span.username').append('<br />You are in <span class="red">DEBUG</span> mode so nothing is going to be changed');
      }
      setTimeout(function(){ $('.loading').remove(); }, 1000);
    }
  });

// authenticate without redirect
// As we let the user store details about their tracks in their browser, 
// and we do not share that with anyone, (not even ourselves), they /could/
// store their username and password and then they would not be sent to the
// login screen.

function no_redirect_auth(){
    var nra_api = $.sc.api(client_id= soundCloudApiKey,
                           client_secret='YOUR_CLIENT_SECRET',
                           username='YOUR_USERNAME',
                           password='YOUR_PASSWORD');
}


 // let them know we are working
  if( ! $('.sc-authorize').length ){$('<span class="orange loading" title="Welcome!">Loading Notice::SoundCloud</span>').prependTo(container); }

 //functions

 function parse(str, callback){
    if(!jQuery.isArray(str)){
       callback(JSON.stringify(str));
    }else{
      callback(JSON.parse(str));
    }
 }

 function del_track(g, t){
  // add sanity check code
    if( debug ){ return true; }
    api.delete('/groups/' + g + '/contributions/' + t , function(reply, e){
      if(e){
        console.error("track del ERROR");
        }
    });
 }

 function add_track(g, t, i){
  // add sanity check code
    if( debug ){ return true; }
    api.put('/groups/' + g + '/contributions/' + t, function(reply, e){
        if(e){ console.log('err:' + e + ',reply:' + reply); alert('Failed to add track to group:' + e.message);}
    });
 }

 // remove and add track t from all groups in this bunch b (or all groups)
 function track_cycle(t, b) {  //track, bunch 
    $('button[name="track_cycle"][id="' +t+ '"]').removeAttr("class", "orange").attr("class", "small green button");
    if ( ! b ){
        b = g ;
        console.log('track_cycle ALL groups');
    }
    $.each(g, function(ok, group){
        del_track(group, t, function(o, k){
             add_track(group, t, callback, function(e){
                 try{ alert(callback); }catch(e){ console.error(e); }
            });
        });
    });
    // would have thought this should be in a function within del_track, but it seems not
    setTimeout(function(){ 
        $.each(g, function(ok, group){
            add_track(group, t);
        });
    }, 3000); // give the SC API time to update its DB
    // NOTE check that the track is back in the group
    setTimeout(function(){ $('button[name="track_cycle"][id="' +t+ '"]').removeAttr("class", "green").attr("class", "small orange button"); }, 3100);
    return true;
 }

 function show_tracks(store) {
  if ( t.length >= 1 ){
    for (var i = 0;i<t.length;i++) {
      var id = t[i];
      var title = tracks[id].title ? tracks[id].title : 'Track: ' + id;
      var link = tracks[id].permalink_url;
      var wave = tracks[id].waveform_url;
      if( ! $('div#track[name="' + id + '"]').length ) {
            $('div#tracks').append('<div id="track" name="' + id + '"><form method="post"><table><tr> \
            <td id="' + id + '"><button title="press me to cycle this track in all groups" class="small orange button" id="' + id + '" name="track_cycle">Reload:</button></td>\
            <td><input id="' + id + '" name="reload" type="checkbox" /></td>\
            <td id="' + id + '">at:' + h_html + ':' + m_html + '</td>\
            <td id="' + id + '" name="every">and every ' + offset_html + ' hours</td>\
            <td id="' + id + '" name="cdh"><span id="countdown" name="' + id + '"></span></td>\
            <td id="' + id + '"><a href="' + link + '" title="' + id + '">' + title + '</a></td> \
            </tr></table></form></div>');
            $('select[id="h_html"]').removeAttr('id').attr('id' , id);
            $('select[id="m_html"]').removeAttr('id').attr('id' , id);
            $('select[id="offset_html"]').removeAttr('id').attr('id' , id);

     load_db(store, db_key, function(this_data){
        if(this_data){
            try {
                if($.type(this_data) == 'string'){
                    try {
                        this_data = JSON.parse(this_data);
                    }catch(e){
                        console.log('unable to parse this data:' + e.message);
                        console.log('probably duff data');
                        // NTS try to scrub the data or wipe the DB NOTE: {needs to be written }
                    }
                }
            }catch(e){ 
                console.error('JSON failed to parse:' + e.message);  
                console.error(e.toSource());
            }
        // now we see if we have to set any of these
            if(this_data[id]){
              if(this_data[id].reload){
                if( $('input[id="' + id + '"][name="reload"]').attr('checked') ){
                    console.log('track:' + id + ' IS enabled for reload in DB and on the page');
                }else{
                    if( $('input[id="' + id + '"][name="reload"]').length ){
                        $('input[id="' + id + '"][name="reload"]').attr('checked', true);
                    }
                }
              }
              if(this_data[id].h || this_data[id].m || this_data[id].offset){
                $('select[id="' + id + '"][name="m"]').val(this_data[id].m);
                $('select[id="' + id +'"][name="h"]').val(this_data[id].h);
                $('select[id="' + id + '"][name="offset"]').val(this_data[id].offset);
              }
       if(this_data[id].reload){
        if(this_data[id].h || this_data[id].m){
         // add the countdown clock
           next_trigger(this_data[id].h, this_data[id].m, this_data[id].offset, function(callback){
                if(callback >= 0){
                    $('[id="countdown"][name="' + id +'"]').html('(in <span name="cdd" id= "' + id + '"></span>)');
                    //$('[name="every"][id="' + id +'"]').append('['+(parseInt(((24-this_data[id].h)/this_data[id].offset), 10)+1)+' reload/day]');
                    $('[name="every"][id="' + id +'"]').append('[' + ( ( ( 24 - this_data[id].h ) / this_data[id].offset ) | 1 ) + ' left today]');
                    countdown_for(id, callback);
                }
           });
        } // end "only countdown if we have an hour and minute for this track"
       } // end "only add countdown for enabled tracks"
      }else{
        console.log('no data in DB for ' + id);
      }
     }
    });
   }
  }
 }
}

//store data

 function save_db(db, key, val, callback) {
    var theString = (typeof val == "string") ? val : JSON.stringify(val);
    //var theString = JSON.stringify(val);
     db.set(key, theString);
 }

 function load_db(db, key, callback){
    db.get(key, function(ok, val) {
      if (ok){
        callback(val);
      }else{
        console.err('db missing');
      }
    });
  }

// add track data to databse

 function update_track(db, key, tid, k, v){
     load_db(db, key, function(this_data){
        //console.log('saving using:' + key);
          //if(this_data){ // works for google chrome
          if(this_data.length >=3){
            // now we need to update this_data
            // probably best to turn it inso JSON and then change it
            if(!jQuery.isArray(this_data)){ 
                try {
                     this_data=$.parseJSON(this_data);
                }catch(e){ 
                    console.log('probably duff data');
                    //try to scrub the data or wipe the DB NOTE: {needs to be written }
                }
            }
            if( this_data[tid] ){
                    this_data[tid][k] = v;
            }else{
                    this_data[tid] = new Object();
                    this_data[tid][k] = v;
                    var now = (new Date()).getTime();
                    this_data[tid]['now'] = now;
            }
            save_db(db, key, this_data);
          }else{
                var newDB = new Object();
                var now = (new Date()).getTime();
                newDB[tid] = new Object();
                newDB[tid][k] = v;
                newDB[tid]['when'] = now;
                console.log('saving new DB');
                console.log(newDB);
                save_db(db, key, newDB);
          }
        });
 } 

 function next_trigger(h, m, period, callback){
  // we have to know what time it is now
    var date = new Date();
    var hour = date.getHours();
    var minute = date.getMinutes();
    var now = hour + ':' + minute;
    var wait = (((0+h+period)*3600) + (0+m)*60);
  
    if( h >= hour ){
        // we have not got to the first time of the day
        if(m > minute){
            callback( ((h - hour ) *60) + (m - minute));
        }else{
            if( ( h - hour ) <= 0 ){
                callback( (period*60) - (minute - m) );
            }else if((h - hour) <= period){
                callback( (h - hour) *60 - (minute - m));
            }else{
                callback( (((h - hour) + period ) *60) - (minute - m) );
            }
        }
    }else if( hour > h && period > 0){
        while(hour > h){
            h = parseInt(h) + parseInt(period);
        }
        var hsl = h - hour;
        var msl = minute > m ? ( parseInt(m) +60 ) - parseInt(minute) : ( parseInt(m) ) - (parseInt(minute));
        wait = ( ( hsl * 60 ) + msl);
        callback(wait);
    }else if(period > 0){
        // TRIGGER IT NOW!
        callback(period); //this is NOT right, maybe
        return true;
    }else{
        callback(0); // not sure this is right
        return false;
    }
 }

// countdown
 function countdown_for(id, offset) {
    var future = offset ? offset*60*1000 : 24*60*60*1000,
        ts = (new Date()).getTime() + future;
    if( $('[name="cdd"][id="' + id + '"]').length){
      $('[name="cdd"][id="' + id + '"]').countdown({
        timestamp   : ts,
        callback    : function(days, hours, minutes){

            if((new Date()) > ts){
                ts = (new Date()).getTime() + future*60*1000; 
                var this_tracks_bunch = g; //this is the default for now
                var r = track_cycle(id, this_tracks_bunch);
                if(r){
                    console.log('auto cycle triggered for:' + id);
                    //window.location.reload(true);
                    reset_track(id, tracks);
                }else{
                    console.log('autoCycle failed:' + r);
                    alert('autoCycle failed:' + r);
                   // window.location.reload(true);
                }
            }

        }
    });
   }
 }

 function reset_track(id, tracks){
    var this_data = tracks;
    if(tracks[id]){
        var h = 0,
            m = 0,
            offset = 0;
        if ( ! tracks[id].h && ! tracks[id].m && ! tracks[id].offset ){
            // we need to raid the DB for this info (and possibly compare it with the screen
            load_db(store, db_key, function(this_data){
                if(this_data){
                    try {
                        if($.type(this_data) == 'string'){
                            try {
                                this_data = JSON.parse(this_data);
                            }catch(e){
                                console.log('unable to parse this data:' + e.message);
                                console.log('probably duff data');
                            }
                        }else{
                            console.log(typeof this_data);
                        }
                    }catch(e){
                        console.error('JSON failed to parse:' + e.message);
                        console.error(e.toSource());
                    }
                // now we see if we have to set any of these
                    if(this_data[id]){
                            h = this_data[id].h,
                            m = this_data[id].m,
                        offset= this_data[id].offset;
                    }
                }else{
                    console.error('can NOT reset as we do not know the times for this track');
                }
            });
            if( ! h && ! m && ! offset){
                h = $('select[name="h"][id="' + id + '"]').val();
                m = $('select[name="m"][id="' + id +'"]').val();
                offset = $('select[name="offset"][id="' + id +'"]').val();
            }
        }else{
                h = tracks[id].h,
                m = tracks[id].m,
            offset= tracks[id].offset;

        }
        next_trigger(h, m, offset, function(callback){
            $('[id="countdown"][name="' + id +'"]').html();
            if(offset > 0 && ( 24 >=  (parseInt(offset) + parseInt((new Date()).getHours()) ))){
                    $('[id="countdown"][name="' + id +'"]').html('(in <span name="cdd" id= "' + id + '"></span>)');
                    countdown_for(id, callback);
            }else{
                $('[id="countdown"][name="' + id +'"]').remove();
            }
       });
    } else {
        console.log('reset which track?');
        console.log(tracks);
        return false;
    }
}

 // collect the track data from the database

 var store = new Object();
 try {
    store = new Persist.Store(app);
     $(document).ready(function() {
        $('span#type').html(Persist.type);
    });
   load_db(store, db_key, function(this_data){
      $(document).ready(function() {
        $('textarea#db').val(this_data);
        $('div#tracks').addClass("blue");
      });
   });
 }catch(e){ console.log(e.message); }


 // wait for the API to be available
 $(document).bind($.sc.api.events.AuthSuccess, function(event) {
      $('.loading').remove();
      $('#tracks').removeAttr("class", "hidden");

  $('#logout').submit(function(e){
    e.preventDefault();
    api.logout();
    return false;
  });

  api.get("/users/" + user_id + "/groups", { limit: page_size }, function(data) {
     if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
     $.map( data, function(group){
        g.push(group.id);
     });
  });

// check the track list and update our store and then the page

    // NOTE we want to add pagination when there are too many tracks (is that too many in the database or in total?)
  api.get('/me/tracks', function(data){
     if(!jQuery.isArray(data)){ data=$.parseJSON(data); }
     $.map( data, function(track){
      if( track.id ){
        var id = track.id;
        t.push(id);
        var now = (new Date()).getTime();
        if( ! tracks[id] ){
            tracks[id] = { "time": now, "title": track.title, "permalink_url": track.permalink_url, "waveform_url": track.waveform_url };
        }else{
            tracks[id]["time"] = now;
            tracks[id]["permalink_url"] = track.permalink_url;
            tracks[id]["waveform_url"] = track.waveform_url;
            tracks[id]["title"] = track.title;
        }
        show_tracks(store, tracks);
      }
     });
        if(show_db){
            $('div#db').removeAttr("class", "hidden");
        }
        $('input, select').change(function(ed){
            var id = $(this).parent().attr('id');
            var name = $(this).attr('name');
            if ( ! id >= 0 ){ id = $(this).attr('id'); }
            if ( id >= 0 ){
              if ( $(this).attr('type') == 'checkbox' ){            
                update_track(store, db_key, id, name, ed.target.checked);
                if(ed.target.checked){
                    var h = $('select[name="h"][id="' + id + '"]').val();
                    var m = $('select[name="m"][id="' + id +'"]').val();
                    var offset = $('select[name="offset"][id="' + id +'"]').val();
                    next_trigger(h, m, offset, function(callback){
                        if(callback >= 0){
                           $('[name="cdh"][id="' +id+'"]').append('<span id="countdown" name="' +id+ '">(in <span name="cdd" id= "' +id+ '"></span>)</span>');
                            countdown_for(id, callback);
                        }
                    });
                }else{ 
                    $('[id="countdown"][name="' + id +'"]').remove();
                    reset_track(id, tracks);
                }
              }else{
                update_track(store, db_key, id, name, $(this).attr('value'));
              }              
            }
        });

      $('button[name="track_cycle"]').click(function(e){
         e.preventDefault();
         var this_track = $(this).attr('id');
         var this_tracks_bunch = g; //this is the default for now
         if( tracks[this_track].bunch ){
            this_tracks_bunch = tracks[this_track].bunch; // the groups that this track should be in 
         }
         track_cycle(this_track, this_tracks_bunch);
         return false;
      });

  });
  $('button#load_db').click(function(){ 
        load_db(store, db_key, function(this_data, e){
            if(this_data){
              if(e){
                $.each(this_data, function(k, v){
                    $('textarea#db').val(this_data);
                });
               }else{
                    parse(this_data, function(callback){
                        var str = callback.replace(/\\"/g, '"');
                        str = str.replace(/^"/, '');
                        str = str.replace(/"$/, '');
                        $('textarea#db').val(str);
                    });
               }
            }
        });
  });
  $('button#save_db').click(function(){ 
        save_db(store, db_key, $('textarea#db').val());
  });

});
})(jQuery);
