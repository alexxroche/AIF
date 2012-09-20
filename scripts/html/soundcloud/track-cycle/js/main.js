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
       // console.log(user);
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
      // this_data = $.makeArray(this_data);
      //this_data = JSON.parse(this_data);
      callback(JSON.parse(str));
    }
}


 function del_track(g, t){
  // add sanity check code
    if( debug ){ console.log('DEBUG: del track ' + t + ' from group ' + g); return true; }
    api.delete('/groups/' + g + '/contributions/' + t , function(reply, e){
      if(e){
        alert("track del ERROR");
        }else{
         console.log('track', t, ' removed from group', g);
        }
    });
 }

 function add_track(g, t, i){
  // add sanity check code
    if( debug ){ console.log('DEBUG: add track ' + t + ' to group ' + g); return true; }
    api.put('/groups/' + g + '/contributions/' + t, function(reply, e){
        if(e){ console.log('err:' + e + ',reply:' + reply); alert('Failed to add track to group:' + e.message);}else{
            console.log('track ' + t + ' added to group ' + g);
        }
    });
 }

 // remove and add track t from all groups in this bunch b (or all groups)
 function track_cycle(t, b) {  //track, bunch 
    $('button[name="track_cycle"][id="' +t+ '"]').removeAttr("class", "orange").attr("class", "small green button");
    // console.log('track_cycle for ' + t);
    if ( ! b ){
        b = g ;
        console.log('track_cycle ALL groups');
    }
    $.each(g, function(ok, group){
        del_track(group, t, function(o, k){
            console.log('DEL DONE: ' + o + ',' + k);
            //console.log('track ' + t + ' removed, now to put it back,' + group + ', e:' + e);
             add_track(group, t, callback, function(e){
                 try{ alert(callback); }catch(e){ console.error(e); }
                 console.log('added track ' + t + ' BACK to group' + e);
            });
        });
    });
    // would have thought this should be in a function within del_track, but it seems not
    setTimeout(function(){ 
        $.each(g, function(ok, group){
            console.log('adding track ' + t + ' to group ' + group); 
            add_track(group, t);
        });
    }, 3000); // give the SC API time to update its DB
    // NOTE check that the track is back in the group
    //console.log('done track_cycle');
    setTimeout(function(){ $('button[name="track_cycle"][id="' +t+ '"]').removeAttr("class", "green").attr("class", "small orange button"); }, 3100);
    return true;
 }

// dummy function until we migrate to the real track_cycle
 function group_cycle(){ return true; }

 function show_tracks(store) {
  if ( t.length >= 1 ){
    for (var i = 0;i<t.length;i++) {
      var id = t[i];
      if(!tracks[id]){
       // if($.browser.mozilla){
            console.log('track ' + id + ' is not in the tracks DB');
            console.log($.type(tracks));
            console.log(tracks);
            continue;
       // }
      }
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
                }else{
                    console.log(typeof this_data);
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
                        //console.log('track:' + id + ' IS NOW checked');
                    }else{
                        console.log('track:' + id + ' isn\'t on the page yet');
                    }
                }
   // WHAT DOES THIS DO? AND WHY IS IT HERE?
    /*
                if(this_data[id].h && this_data[id].m){
                    var start = this_data[id].h + ', ' + this_data[id].m;
                    console.log(start);
                    var now = next_trigger(start, this_data[id].offset, function(callback){
                        $('#countdown[name="' + id +'"]').html(callback);
                    });
                }
    */
              }
              if(this_data[id].h || this_data[id].m || this_data[id].offset){
                $('select[id="' + id + '"][name="m"]').val(this_data[id].m);
                $('select[id="' + id +'"][name="h"]').val(this_data[id].h);
                $('select[id="' + id + '"][name="offset"]').val(this_data[id].offset);
              }
       if(this_data[id].reload){
        if(this_data[id].h || this_data[id].m){
         // add the countdown clock
           //console.log('next_trigger:' + this_data[id].h + 'h'+ this_data[id].m + ', ' + this_data[id].offset);
           next_trigger(this_data[id].h, this_data[id].m, this_data[id].offset, function(callback){
                if(callback >= 0){
                   // console.log('Page loaded: ' + h + ':' + m + ', ' + callback);
                   // console.log('offset countdown (minutes): ', callback);
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
     db.set(key, theString, function(callback, e){ 
      if(debug) { 
        if(val){
            if(val.length){
                console.log('saved:' + val.length); 
            }else{
                console.log('db insert:');
                console.log(val); 
            }
            callback(val);
        }else{
            console.log('DROP DB:' + e);
        }
      } // end debug
     });
 }

 function load_db(db, key, callback){
    db.get(key, function(ok, val) {
      if (ok){
        //console.log('db SELECT: ' +ok);
        if(val){
          //  console.log('db found:' + val.length);
          //  console.log(val);
        }else{
           console.log('db select:'); console.log(val);
        }
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
                     //this_data= $.makeArray($.parseJSON(this_data));
                     this_data=$.parseJSON(this_data);
                }catch(e){ 
                    console.log('failed in update_track to JSON:' + e.message); 
                    console.log('probably duff data');
                    console.log(this_data);
                    //try to scrub the data or wipe the DB NOTE: {needs to be written }
                }
               //console.log('L128:'+$.type(this_data));
               //console.log(this_data);
            }
            if( this_data[tid] ){
                   // console.log('track ' + tid + ' exists in DB!');
                    this_data[tid][k] = v;
            }else{
                if($.browser.mozilla){
                    //this_data = JSON.stringify(this_data);
                    //this_data = $.makeArray(this_data);
                }
                    console.log('no entry for: '+tid);
                    console.log('trying to update this_data');
                    console.log(this_data);
                    this_data[tid] = new Object();
                    this_data[tid][k] = v;
                    var now = (new Date()).getTime();
                    this_data[tid]['now'] = now;
            }

                save_db(db, key, this_data, function(k, v){
                    if($.browser.mozilla){
                        $('textarea#db').val(this_data.toSource());
                    }else{
                        $('textarea#db').val(JSON.stringify(this_data));
                    }
                    //$('textarea#db').val(k);
                });
        if(debug){
                if($.browser.mozilla){
                    $('textarea#db').val(this_data.toSource());
                }else{
                    $('textarea#db').val(JSON.stringify(this_data));
                }
        }

          }else{
              //  console.log('shiny new db:' + tid + ', ' + k + ': ' + v);
                var newDB = new Object();
                var now = (new Date()).getTime();
                newDB[tid] = new Object();
                newDB[tid][k] = v;
                newDB[tid]['when'] = now;
                console.log('saving new DB');
                console.log(newDB);
                save_db(db, key, newDB, function(l, m){
                    //$('textarea#db').val('[' + tid + '] ' + k + ': ' v);
                    $('textarea#db').val(l);
                });
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
         //console.log('we have NOT got to ' + h + ':' + m + ' anchor yet ' + hour + 'h' + minute);
            //console.log('setting wait to: ' + ( ((h - hour) *60) + (m - minute)) + ', ' + h + ' ' + hour + ' m:' + minute);
            //callback( ((h - (hour + 1)) *3600) + (((m+60) - minute) * 60));  //this is for seconds ... why the + 1?
            //console.log('travisle: ' + h + ':' + m + ', ' +  period + ' @ '+hour+'h'+minute);
            callback( ((h - hour ) *60) + (m - minute));
        }else{
            //callback( (((h + period) - hour  ) *3600) + ((m - minute) * 60) ); //this is for seconds
            //console.log('working with: ' + h + ':' + m + ', ' +  period + ' @ '+hour+'h'+minute);
            if( ( h - hour ) <= 0 ){
                console.log('JUST this hour passed ' + h + ':' + m + ' now it is ' + hour + ':' + minute);
                callback( (period*60) - (minute - m) );
            }else if((h - hour) <= period){
                console.log('just next hour' + h + ':' + m + ' now it is ' + hour + ':' + minute);
                callback( (h - hour) *60 - (minute - m));
            }else{
                console.log('justice will wait - the hour is a long way off' + h + ':' + m + ' now it is ' + hour + ':' + minute);
                callback( (((h - hour) + period ) *60) - (minute - m) );
            }
        }
    }else if( hour > h && period > 0){
        console.log('Pst ' + h + ':' + m + ', but by how many ' + period +'\'s ?');
        // we have past the anchor and need to know how many periods past
        // before we can calculate
        while(hour > h){
           // console.log('h:' + h + ', hour: ' + hour + ', gap: ', period);
            h = parseInt(h) + parseInt(period);
        }
        //var hsl = hour > h? hour - h : h - hour;
        //console.log('h: ' + h + ', hour: ' + hour);
        var hsl = h - hour;
        //console.log('msl: ' + ( m + 60 ) + ', minute: ' + parseInt(minute));
        //m = parseInt(m) + 60;
        //console.log('m: ' + m + ', minute: ' + minute);
        var msl = minute > m ? ( parseInt(m) +60 ) - parseInt(minute) : ( parseInt(m) ) - (parseInt(minute));
        //var msl = minute > m ? 60 - (minute - m) : m - minute;
        console.log('we have to wait ' + hsl + ':' + msl + ' until cycle'); 
        // wait = (( hsl * 3600 ) + ( msl * 60) );  //this is for seconds
        wait = ( ( hsl * 60 ) + msl);
        callback(wait);
    }else if(period > 0){
        // TRIGGER IT NOW!
        console.log('trigger: ' + now + ', ' + anchor);
        //$('#countdown[name="' + id +'"]').html(callback);
        // return 1; //is this better?
        callback(period); //this is NOT right, maybe
        return true;
    }else{
        callback(0); // not sure this is right
        return false;
    }
  // we have to know, for each track, (that is enabled) when to start and how many hours to wait.
  //  we have to monitor all tracks even if we start to display using pagination
  // we are going to have to have a global $.sort(reload{ id: timestamp}) and then just back-off until reload[0][0]
}

// countdown
function countdown_for(id, offset) {
    //var future = offset ? offset*1000 : 24*60*60*1000, // this is for seconds
    var future = offset ? offset*60*1000 : 24*60*60*1000,
        ts = (new Date()).getTime() + future;
    if( $('[name="cdd"][id="' + id + '"]').length){
      $('[name="cdd"][id="' + id + '"]').countdown({
        timestamp   : ts,
        callback    : function(days, hours, minutes){

            if((new Date()) > ts){
                //console.log('resetting ' + future);
                //ts = (new Date()).getTime() + future*1000; // this is for seconds
                // NTS we should check to see if we need to reset or just give up on this track for the day
                ts = (new Date()).getTime() + future*60*1000; 
                console.warn('time to cycle:' + id + ' (' + offset + ')[' + future + ']');
                var this_tracks_bunch = g; //this is the default for now
                if( tracks[id].bunch ){
                    console.warn('track HAS a bunch!');
                    this_tracks_bunch = tracks[id].bunch; // the groups that this track should be in 
                }else{
                  /*
                    console.error('track all groups:');
                    try {
                        console.error(tracks[id]);
                    }catch(e){ console.warn(e); }
                  */
                }
                var r = track_cycle(id, this_tracks_bunch);
                //var r = group_cycle('do');
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
    //var m = 0+this_data[id].m; // not sure we need this
    //console.log('in reset, this_Data: ');
    //console.log(this_data);
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
                //console.log('reset got it from the DB!');
            });
            if( ! h && ! m && ! offset){
                h = $('select[name="h"][id="' + id + '"]').val();
                m = $('select[name="m"][id="' + id +'"]').val();
                offset = $('select[name="offset"][id="' + id +'"]').val();
                console.log('reset got it from THE PAGE!');
            }
        }else{
                h = tracks[id].h,
                m = tracks[id].m,
            offset= tracks[id].offset;

        }
        console.log('GOOD reset NEWS: ' + h + ':' + m + ', ' + offset);
        //next_trigger(this_data[id].h, this_data[id].m, this_data[id].offset, function(callback){
        next_trigger(h, m, offset, function(callback){
            console.log('offset countdown (seconds): ', callback);
            $('[id="countdown"][name="' + id +'"]').html();
            // only reset if that is enabled or remove it if (now + offset) > 24:00:00
            //if(this_data[id].offset > 0 && ( 24 >=  (this_data[id].offset + (new Date()).getHours() ))){
            if(offset > 0 && ( 24 >=  (parseInt(offset) + parseInt((new Date()).getHours()) ))){
                console.warn('PUTTING THE COUNTDOWN BACK');
                    $('[id="countdown"][name="' + id +'"]').html('(in <span name="cdd" id= "' + id + '"></span>)');
                    countdown_for(id, callback);
            }else{
                if( ! offset > 0  ){
                    console.log('offset is too small for a reset: ' + offset);
                }else{
                    console.log('offset + now.hour < 24' + (parseInt(offset) + parseInt((new Date()).getHours()) ));
                }
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
   // load up the page (if we have data
   //console.log('found DB!');
   load_db(store, db_key, function(this_data){
       // $.each(this_data, function(k, v){ //console.log('found in DB: ' + k + '=' + v); // tracks[k] = v; });
       // console.log(this_data);
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
    console.log('loged out');
    return false;
  });

// http://developers.soundcloud.com/docs/api/guide#pagination
 // going to have to step through pages while(api.get("/users/" + user_ud + "/groups", { limit: page_size, offset: page }, function(data) { return data.length;}) == page_size 
   
  api.get("/users/" + user_id + "/groups", { limit: page_size }, function(data) {
     if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
     $.map( data, function(group){
        g.push(group.id);
     });
  });


// check the track list and update our store and then the page

    // NOTE we want to add pagination when there are too many tracks (is that too many in the database or in total?)
  api.get('/me/tracks', function(data){
     //if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
     //if(!jQuery.isArray(data)){ data=$.makeArray($.parseJSON(data)); }
     if(!jQuery.isArray(data)){ data=$.parseJSON(data); }
     $.map( data, function(track){
      if( track.id ){
        var id = track.id;
        t.push(id); //this lets us know the size of tracks{}
     // we could just store everything that the API gives us, but 
     // with the limited size of some stores we should limit ourselves
        //console.log(id + ': ' + title);
        var now = (new Date()).getTime();

        //tracks[id] = { "time": now, "title": track.title, "permalink_url": track.permalink_url, "waveform_url": track.waveform_url };
        if( ! tracks[id] ){
            tracks[id] = { "time": now, "title": track.title, "permalink_url": track.permalink_url, "waveform_url": track.waveform_url };
        }else{
            tracks[id]["time"] = now;
            tracks[id]["permalink_url"] = track.permalink_url;
            tracks[id]["waveform_url"] = track.waveform_url;
            tracks[id]["title"] = track.title;
        }
       // console.log('L209, tracks:' + tracks);
        show_tracks(store, tracks);
      }
     });
        if(show_db){
            $('div#db').removeAttr("class", "hidden");
        }
/*
        if($.browser.mozilla){
            $('textarea#db').html(tracks.toSource());
            if($.type(tracks) == 'object'){
                try {
                    tracks = $.makeArray( tracks );
                    console.log(tracks.length);
                }catch(e){
                    console.log('failed to array tracks:' + e.message);
                }
            }else{
                console.log('tracks is still an: ' + $.type(tracks));
                console.log(tracks.toSource());
             $.each(tracks, function(key, value) { 
                if($.type(value)){
                    $.each(value, function(ki, vel) { 
                        console.log(ki + ': ' + vel);
                    });
                }else{
                    console.log(key + '= ' + value);
                }
             });
            }
        }else{
           // $('textarea#db').val( decodeURIComponent(jQuery.param(tracks)) );
            var arrayNow = $.makeArray( tracks );
           //$('textarea#db').val( $.each(arrayNow) );
          // $('textarea#db').val( jQuery.param(arrayNow) );
            $.each(tracks, function(key, value) { 
                //console.log('L225:' + key + ': ' + value);
                //console.log('L226:' +  tracks[key].title);
            });
            //console.log(tracks);
        }
*/

   // watch for changes

/*
        // hmmm NOTE trying to bind watching
        $('#tracks').bind('DOMSubtreeModified', function(e) {
          if (e.target.innerHTML && e.target.id){
           var this_name = 'You ';
            if( e.target.name){ this_name = e.target.name; }
            //else if( e.target.parent.name){ this_name = e.target.name; }
          //  var this_name = e.target.name ? e.target.name : e.target.parent.name;
            console.log(this_name + ' pressed for ' + e.target.id + ', ' + e.target.innerHTML);
          }else{
           // console.log('target event:'); console.log(e);
          }
        });
*/
        $('input, select').change(function(ed){
            var id = $(this).parent().attr('id');
            var name = $(this).attr('name');
            if ( ! id >= 0 ){ id = $(this).attr('id'); }
            if ( id >= 0 ){
              if ( $(this).attr('type') == 'checkbox' ){            
                update_track(store, db_key, id, name, ed.target.checked);
                if(ed.target.checked){
                    // show_track(id); // this should be cut from show_tracks into its own function
                    var h = $('select[name="h"][id="' + id + '"]').val();
                    var m = $('select[name="m"][id="' + id +'"]').val();
                    var offset = $('select[name="offset"][id="' + id +'"]').val();
                    console.warn('putting back:' + h + 'h' + m + ', every ' + offset + ' hours');
                    next_trigger(h, m, offset, function(callback){
                       // $('[name="every"][id="' + id +'"]').append('[' + ( ( ( 24 - tracks[id].h ) / tracks[id].offset ) | 1 ) + ' reload/day]');
                        console.warn('nt callback:' + callback);
                        if(callback >= 0){
                            $('[name="cdh"][id="' + id +'"]').append('<span id="countdown" name="' + id + '">(in <span name="cdd" id= "' + id + '"></span>)</span>');
                            countdown_for(id, callback);
                        }
                    });
                }else{ 
                    $('[id="countdown"][name="' + id +'"]').remove();
                    reset_track(id, tracks);
                }
              }else{
               // console.log( '{' + $(this).parent().attr('id') + ': { ' + $(this).attr('name') + ': ' + $(this).attr('value') + '}}');                  
                update_track(store, db_key, id, name, $(this).attr('value'));
              }              
            }else{
                console.log('L269 no id:' );
                console.log(ed);
            }
        });

      $('button[name="track_cycle"]').click(function(e){
         e.preventDefault();
         var this_track = $(this).attr('id');
         //console.log('trying to cyclec track' + this_track);
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
                //console.log('db select:' + this_data );
              //  console.log('db select:');
              //  console.log(this_data);
              //  console.log(e);
              if(e){
                $.each(this_data, function(k, v){
                    $('textarea#db').val(this_data);
                });
               }else{
                    parse(this_data, function(callback){
                        var str = callback.replace(/\\"/g, '"');
                        str = str.replace(/^"/, '');
                        str = str.replace(/"$/, '');
                        //$('textarea#db').val(callback.replace(/\\"/g, '"'));
                        $('textarea#db').val(str);
                    });
               }
            }else{
                console.log('LOAD pressed' + this_data + ', e:' + e);
            }
        });
    });
  $('button#save_db').click(function(){ 
     //console.log('you pressed the save button' + $('textarea#db').val());
        save_db(store, db_key, $('textarea#db').val());
      //setTimeout(function(){ $('textarea#db').val(''); }, 1500);
    });

});
})(jQuery);
