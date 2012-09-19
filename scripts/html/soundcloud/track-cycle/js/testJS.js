(function($) {  
 
  //variables
    var debug = true;
    var user_id = 1;
    //var tracks = new Object();
      var tracks = { 
            1 : { reload: true, h: 2, m: 4, hotd: 6 }, 
            2 : { reload: true, h: 15, m: 57, hotd: 7 }, 
            3 : { reload: true, h: 23, m: 1, hotd: 8 }, 
            4 : { reload: false, h: 1, m: 53, hotd: 1 }, 
            5 : { reload: true, h: 2, m: 0, hotd: 12 }, 
            6 : { reload: true, h: 23, m: 0, hotd: 0 }, 
            7 : { reload: true, h: 0, m: 3, hotd: 0 }, 
            8 : { reload: true, h: 9, m: 42, hotd: 0 }, 
        };
    var t = [1,2,3,4,5,6,7,8];
  for (var m = 9;m<=24;m++){
        t.push(m);
        var date = new Date();
        var min = date.getMinutes() +1;
        var hur = date.getHours();
        tracks[m] = { reload: true, h: hur, m: min, hotd: (m -9) };
  }
     var hotd_html = '<select id="hotd_html" name="hotd">';
  var h_html = '<select id="h_html" name="h">';
  var m_html = '<select id="m_html" name="m">';
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


 //functions
 
 function show_tracks(store) {
      var user = {username : 'alexx Roche' };
      var this_data = tracks;
      setTimeout(function(){ 
      $('<span class="username">Welcome: <strong title="' + user_id + '">' + user.username + '</strong></a>').prependTo(container);
  //    $('#footer').removeAttr("class", "hidden");
      if( debug ){ 
        $('input#group_cycle').removeAttr("class", "orange");
        $('span.username').append('<br />You are in <span class="red">DEBUG</span> mode so nothing is going to be changed');
      }



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
            <td id="' + id + '" name="every">and every ' + hotd_html + ' hours</td>\
            <td id="' + id + '"><span id="countdown" name="' + id + '"></span></td>\
            <td id="' + id + '"><a href="' + link + '" title="' + id + '">' + title + '</a></td> \
            </tr></table></form></div>');
            $('select[id="h_html"]').removeAttr('id').attr('id' , id);
            $('select[id="m_html"]').removeAttr('id').attr('id' , id);
            $('select[id="hotd_html"]').removeAttr('id').attr('id' , id);

        }
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
        }
        if(this_data[id].h || this_data[id].m || this_data[id].hotd){
           $('select[id="' + id + '"][name="m"]').val(this_data[id].m);
           $('select[id="' + id +'"][name="h"]').val(this_data[id].h);
           $('select[id="' + id + '"][name="hotd"]').val(this_data[id].hotd);
        }
       if(this_data[id].reload){
       // add the countdown clock
        if(this_data[id].h || this_data[id].m){
           var m = 0+this_data[id].m;
           //console.log(start);
           next_trigger(this_data[id].h, m, this_data[id].hotd, function(callback){
                console.log('offset countdown (seconds): ', callback);
                $('[id="countdown"][name="' + id +'"]').html('(in <span name="cdd" id= "' + id + '"></span>)');
                //$('[name="every"][id="' + id +'"]').append('[' + ( parseInt( ( ( 24 - this_data[id].h ) / this_data[id].hotd ), 10) + 1) + ' reload/day]');
                $('[name="every"][id="' + id +'"]').append('[' + ( ( ( 24 - this_data[id].h ) / this_data[id].hotd ) | 1 ) + ' reload/day]');
                if(callback >= 0){
                    countdown_for(id, callback);
                }
           });
           // offset = next_trigger(this_data[id].h, this_data[id].m, this_data[id].hotd);
            
        } // end "only countdown if we have an hour and minute for this track"
       } // end "only add countdown for enabled tracks"
      }
    }
    // display the constructed page
    $('div').removeAttr("class", "hidden");
}, 900);
      setTimeout(function(){ $('.loading').remove(); }, 900);
 // let them know we are working
  if( ! $('.sc-authorize').length ){$('<span class="orange loading" title="Welcome!">Loading Notice::SoundCloud</span>').prependTo(container); }
  }

function next_trigger(h, m, period, callback){
   // var now = (new Date()).getTime();
  // we have to know what time it is now
    var date = new Date();
    var hour = date.getHours();
    var minute = date.getMinutes();
    var now = hour + ':' + minute;
    var anchor = '';
    if(h <= 9){ anchor += 0+h }else{ anchor += h; }
    if(m <= 9){ anchor += ':' + 0+m }else{ anchor += ':' + m; }
    console.log(anchor + ', ' + now);
    //var anchor = (new Date(year, month, day, start)).getTime();
    var wait = (((0+h+period)*3600) + (0+m)*60);

// NTS we have a BUG: if the next "every" is after midnight then we should show the countdown as being
// NTS   ( 24 - now.hour ) + h )

    if( h >= hour ){
        // we have not got to the first time of the day
        if(m > minute){
         console.log('we have not got to ' + h + ':' + m + ' anchor yet');
            callback( ((h - (hour + 1)) *3600) + (((m+60) - minute) * 60));
        }else{
         console.log('we have JUST passed ' + h + ':' + m + ' now it is ' + hour + ':' + minute);
            callback( (((h + period) - hour  ) *3600) + ((m - minute) * 60) );
        }
        return 
    }else if( hour > h && period > 0){
        console.log('Pst ' + h + ':' + m + ', but by how many ' + period +'\'s ?');
        // we have past the anchor and need to know how many periods past
        // before we can calculate
        while(hour > h){
           // console.log('h:' + h + ', hour: ' + hour + ', gap: ', period);
            h = h + period;
        }
        //var hsl = hour > h? hour - h : h - hour;
        var hsl = h - hour;
        var msl = minute > m? (m+60) - minute : m - minute;
        console.log('we have to wait ' + hsl + ':' + msl + ' until cycle'); 
        wait = (( hsl * 3600 ) + ( msl * 60) );
        callback(wait);
    }else if(period > 0){
        // TRIGGER IT NOW!
        console.log('trigger: ' + now + ', ' + anchor);
        //$('#countdown[name="' + id +'"]').html(callback);
        return 1;
    }
// NTS you are HERE!
  // how are we going to watch a random number of tracks and keep a record of their countdown?

  // we have to know, for each track, (that is enabled) when to start and how many hours to wait.
  //    [ We should display how many times a day that track is going to be reloaded ]
  //
  // we have to calculate how far away the next reload is
  // we have to display it
  // we have to catch t == 0 and trigger a reload
  //
  //  we have to monitor all tracks even if we start to display using pagination
  //
   // console.log('we are trying to countdown');
}

// countdown
function countdown_for(id, offset) {
    var future = offset ? offset*1000 : 6*60*60*1000,
        ts = (new Date()).getTime() + future;
    if( $('[name="cdd"][id="' + id + '"]').length){
      $('[name="cdd"][id="' + id + '"]').countdown({
        timestamp   : ts,
        callback    : function(days, hours, minutes){

            if((new Date()) > ts){
                //ts = (new Date()).getTime() + future; //nope
                console.log('resetting ' + future);
                ts = (new Date()).getTime() + future*1000; //nope
                //ts = next_trigger(id, offset);
                //ts = (new Date()).getTime() + 2*1000;
               //alert('time to cycle:' + id + ' (' + offset + ')');
               console.warn('time to cycle:' + id + ' (' + offset + ')[' + future + ']');
                var r = group_cycle('do');
                if(r){
                    console.log('auto cycle triggered');
                    //alert('autoCycle done:' + r);
                    //window.location.reload(true);
                // NTS reset the countdown (to now + offset) or remove it if (now + offset) > 24:00:00
                    reset_track(id);
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

 function reset_track(id){
    var this_data = tracks;
    var m = 0+this_data[id].m;
    next_trigger(this_data[id].h, m, this_data[id].hotd, function(callback){
        console.log('offset countdown (seconds): ', callback);
        $('[id="countdown"][name="' + id +'"]').html();
        // only reset if that is enabled AND hotd < 24 - now.hour
        if(this_data[id].hotd > 0 && ( 24 >=  (this_data[id].hotd + (new Date()).getHours() ))){
                $('[id="countdown"][name="' + id +'"]').html('(in <span name="cdd" id= "' + id + '"></span>)');
        // NOTE we /could/ have a countdown of the number of resets left today? 
                countdown_for(id, callback);
        }else{
            $('[id="countdown"][name="' + id +'"]').remove();
        }
    });
 }

 function group_cycle(){ return true; }

 $(document).ready(function() {
    show_tracks();
 });

})(jQuery);
