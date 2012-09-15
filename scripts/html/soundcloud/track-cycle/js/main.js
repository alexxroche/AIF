(function($) {
// (global)  variables
  var soundCloudApiKey = 'cfd1c03433dca45c16f2f9ecb0ae5a2b'; //Notice
  //var soundCloudApiKey = '542bdb53829b5b7cf02988d566c708de'; //dev_Notice
  var app = 'Notice_SoundCloud';
  var db_key = 'my_lxr_data'; //could just user scAPIkey + app
  var debug = true;
  var page_size = 50; //the default
  var tracks = new Object(); // associative array of track data (we only really need id,title,URI)
  var t = []; //array of track IDs
  var g = []; //array of group IDs
  var hotd_html = '<select name="hotd">';
  var h_html = '<select name="h">';
  var m_html = '<select name="m">';
  for (var h = 0;h<=24;h++) {
            hotd_html = hotd_html + '<option>' + h + ' </option>';
            h_html = h_html + '<option>' + h + ' </option>';
            m_html = m_html + '<option>' + h + ' </option>';
  }   
  for (var m = 25;m<=59;m++)
            m_html = m_html + '<option>' + m + ' </option>';
  hotd_html = hotd_html + '</select>';
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

 // let them know we are working
  if( ! $('.sc-authorize').length ){$('<span class="orange loading" title="Welcome!">Loading Notice::SoundCloud</span>').prependTo(container); }

 //functions

 function del_track(g, t, i){
  // add sanity check code
    if( debug ){ return true; }
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
    if( debug ){ return true; }
    api.put('/groups/' + g + '/contributions/' + t, function(reply, e){
        if(e){ console.log('err:' + e + ',reply:' + reply); alert('Failed to add track to group:' + e.message);}else{
            console.log('track ' + t + ' added to group ' + g);
        }
    });
 }

 // remove and add track t from all groups in this bunch b (or all groups)
 function track_cycle(t, b) {
    if ( ! b ){
        b = g ;
    }
    return true;
 }

 function show_tracks() {
  if ( t.length >= 1 ){
    for (var i = 0;i<t.length;i++) {
      var id = t[i];
      var title = tracks[id].title ? tracks[id].title : 'Track: ' + id;
      var link = tracks[id].permalink_url;
      var wave = tracks[id].waveform_url;
      if( ! $('div#track[name="' + id + '"]').length ) {
            $('div#tracks').append('<div id="track" name="' + id + '"><form><table><tr> \
            <td id="' + id + '">Reload:<input name="reload" type="checkbox" /></td>\
            <td id="' + id + '">at:' + h_html + ':' + m_html + '</td>\
            <td id="' + id + '">and every ' + hotd_html + ' hours</td>\
            <td id="' + id + '"><a href="' + link + '">' + title + '</a></td> \
            <td id="' + id + '"><span id="countdown" name="' + id + '"></span></td>\
            <td id="buttons" class="right"><span id="buttons" class="right"></span></td>\
            </tr></table></form></div>');
      }
    }
   }
  }


//store data

 function save_db(db, key, val) {
  // Note that the value must be a string.  If you want to save structured
  // data like arrays or hashes, you should serialize it using Array.join or JSON.
     db.set(key, val, function(i, e){ 
        if(val){
            if(val.length){
                console.log('saved:' + val.length); 
            }else{
                console.log('db insert:');
                console.log(val); 
            }
        }else{
            console.log('sin:' + i + ', e:' + e);
        }
     });
 }

 function load_db(db, key, callback){
    db.get(key, function(ok, val) {
      if (ok){
        //console.log('db found:' + val.length);
        console.log('db select:');
        console.log(val.length);
        callback(val);
      }else{
        console.err('db missing');
      }
    });
  }


// add track data to databse

function update_track(db, key, tid, k, v){
     load_db(db, key, function(this_data){
          if(this_data){
            // now we need to update this_data
            // probably best to turn it inso JSON and then change it
           // if(!jQuery.isArray(this_data)){ 
                    //this_data=$.makeArray(this_data); 
                console.log('L128:'+$.type(this_data));
           // }
                console.log('L143 setting:'+tid + ', ' + k + ': ' + v);
                if( this_data[tid]){
                    this_data[tid][k] = v;
                }else{
                    this_data[tid] = { k: v };
                }
            //var html = this_data.replace(/</g, "&lt;").replace(/>/g, "&gt;");

                console.log('L134:' +this_data);
                save_db(db, key, this_data, function(){
                    $('textarea#db').val(this_data);
                });
          }else{
                console.log('*snif* no data:' + data);
          }
        });

} 

 // collect the track data from the database
 var store = new Object();
 var found_DB = false;
 try {
    store = new Persist.Store(app);
     $(document).ready(function() {
        $('span#type').html(Persist.type);
    });
    found_DB = true;
 }catch(e){ console.log(e.message); }
 // load up the page (if we have data
 if(found_DB){
    //console.log('found DB!');
   // $('span#type').html(Persist.type);
    show_tracks(function(){
        $('div#tracks').addClass("blue");
    });
 }


 // wait for the API to be available
 $(document).bind($.sc.api.events.AuthSuccess, function(event) {
      $('.loading').remove();
      $('#tracks').removeAttr("class", "hidden");

 //$(this).change(function(ed) { alert('you touched a ' + $(this).get(0).tagName ); });
 //$(this).change(function(ed) { alert('you touched a ' + $.type(ed)  + ':' + ed); console.log(ed); });

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

  api.get('/me/tracks', function(data){
     //if ( ! jQuery.isArray(data) ) { data = $.parseJSON(data); data = $.makeArray(data); }
     if(!jQuery.isArray(data)){ data=$.makeArray($.parseJSON(data)); }
     $.map( data, function(track){
      if( track.id ){
        var id = track.id;
        var title = track.title;
        var link = track.permalink_url;
        t.push(id); //this lets us know the size of tracks{}
     // we could just store everything that the API gives us, but 
     // with the limited size of some stores we should limit ourselves
        //console.log(id + ': ' + title);
        var now = (new Date()).getTime();

        // check data in DB for this row

        tracks[id] = { "time": now, "title": track.title, "permalink_url": track.permalink_url, "waveform_url": track.waveform_url };
       // console.log('L209, tracks:' + tracks);

// check that the DB is up to date 
        show_tracks();
      }
     });
        $('div#db').removeAttr("class", "hidden");
        if($.browser.mozilla){
            //$('textarea#db').html(tracks.toSource());
            console.log(tracks.toSource());
        }else{
            $('textarea#db').val( decodeURIComponent(jQuery.param(tracks)) );
            var arrayNow = $.makeArray( tracks );
           //$('textarea#db').val( $.each(arrayNow) );
          // $('textarea#db').val( jQuery.param(arrayNow) );
            $.each(tracks, function(key, value) { 
                //console.log('L225:' + key + ': ' + value);
                //console.log('L226:' +  tracks[key].title);
            });
            //console.log(tracks);
        }

   // watch for changes

        // hmmm NOTE trying to bind watching
        $('#tracks').bind('DOMSubtreeModified', function(e) {
          if (e.target.html.length > 0) {
            console.log('eeee:' + e);
          }else{
            console.log('fffffff:' + e);
          }
        });
        $('input, select').change(function(ed){
              var this_id = $(this).parent().attr('id');
              var name = $(this).attr('name');
  //        if ( $(this).parent().attr('id') ){
          if ( this_id >= 0 ){
              //console.log('L243:' +  tracks[$(this).parent().attr('id')].title);
              //console.log('L243:' +  tracks[this_id].title);

        // get the existing value from the database with load_db NOTE (not written yet)
              if ( $(this).attr('type') == 'checkbox' ){            
                update_track(store, db_key, $(this).parent().attr('id'), $(this).attr('name'), ed.target.checked);
 if(debug = 'REM'){
                var value = '';
                if ( ed.target.checked ){
                  value = 1; //'checked';
                }else{
                  value = 0; // 'unchecked';
                }
                if(value.length){
                 //   console.log( '{' + $(this).parent().attr('id') + ': { ' + $(this).attr('name') + ': ' + value + '}}');                  
                   if( tracks[this_id] ){
                    //console.log(' setting  ' + this_id + ' ' + name + ': ' + value);
                    
                    if(value == 'checked'){
                       tracks[this_id][name] = 1;
                    }else{
                       tracks[this_id][name] = 0;
                    }
                   // console.log(this_id + ': ');
                   // console.log(name + ': ' + tracks[this_id][name]);
                    //console.log(tracks);
                   // save_db(store, db_key, tracks);
                       // var html = tracks.replace(/</g, "&lt;").replace(/>/g, "&gt;");
                        $('textarea#db').val(tracks[this_id]);
                   }else{
                     console.warn(this_id + ' does not exist yet');
                     tracks[this_id] = { "$(this).attr('name')": "$value" };
                     save_db(store, db_key, tracks);
                     $.each(tracks, function(key, value) { 
                        if(key == this_id){
                            var txt = tracks[this_id];
                            $('textarea#db').val(txt);
                        }
                      });
                   }
                }else{  
                    if($.browser.mozilla){
                        console.log('no value for:' + ed.toSource());
                    }else{
                        console.log('no value for:');
                        console.log(ed);
                    }
                }
   }
              }else{
                console.log( '{' + $(this).parent().attr('id') + ': { ' + $(this).attr('name') + ': ' + $(this).attr('value') + '}}');                  
                update_track(store, db_key, $(this).parent().attr('id'), $(this).attr('name'), $(this).attr('value'));
              }              
          }else{
            console.log(ed);
          }
        });



  });
  $('button#load_db').click(function(){ 
        load_db(store, db_key, function(this_data){
            if(this_data){
                //console.log('db select:' + this_data );
                console.log('db select:');
                console.log(this_data);
                $('textarea#db').val(this_data);
            }
        });
    });
  $('button#save_db').click(function(){ 
     console.log('you pressed the save button' + $('textarea#db').val());
        save_db(store, db_key, $('textarea#db').val());
      //setTimeout(function(){ $('textarea#db').val(''); }, 1500);
    });

  $('#track_cycle').submit(function(e){
     e.preventDefault();
     var this_track = this.data('#track');  
     var this_tracks_bunch = this.data('#groups'); // the groups that this track should be in 
     track_cycle(this_track, this_tracks_bunch);
     return false;
  });

 });
})(jQuery);
