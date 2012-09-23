//= require "com.ticommunity"

/**
 * com.ticommunity.comm
 * http://jsrails.timeinc.net/j/com.ticommunity.comm.js
 */
(function(){
		var makeClass,
		    FlashDetect;

	//http://www.featureblend.com/license.txt
	FlashDetect=new function(){var self=this;self.installed=false;self.raw="";self.major=-1;self.minor=-1;self.revision=-1;self.revisionStr="";var activeXDetectRules=[{"name":"ShockwaveFlash.ShockwaveFlash.7","version":function(obj){return getActiveXVersion(obj);}},{"name":"ShockwaveFlash.ShockwaveFlash.6","version":function(obj){var version="6,0,21";try{obj.AllowScriptAccess="always";version=getActiveXVersion(obj);}catch(err){}
	return version;}},{"name":"ShockwaveFlash.ShockwaveFlash","version":function(obj){return getActiveXVersion(obj);}}];var getActiveXVersion=function(activeXObj){var version=-1;try{version=activeXObj.GetVariable("jQueryversion");}catch(err){}
	return version;};var getActiveXObject=function(name){var obj=-1;try{obj=new ActiveXObject(name);}catch(err){obj={activeXError:true};}
	return obj;};var parseActiveXVersion=function(str){var versionArray=str.split(",");return{"raw":str,"major":parseInt(versionArray[0].split(" ")[1],10),"minor":parseInt(versionArray[1],10),"revision":parseInt(versionArray[2],10),"revisionStr":versionArray[2]};};var parseStandardVersion=function(str){var descParts=str.split(/ +/);var majorMinor=descParts[2].split(/\./);var revisionStr=descParts[3];return{"raw":str,"major":parseInt(majorMinor[0],10),"minor":parseInt(majorMinor[1],10),"revisionStr":revisionStr,"revision":parseRevisionStrToInt(revisionStr)};};var parseRevisionStrToInt=function(str){return parseInt(str.replace(/[a-zA-Z]/g,""),10)||self.revision;};self.majorAtLeast=function(version){return self.major>=version;};self.minorAtLeast=function(version){return self.minor>=version;};self.revisionAtLeast=function(version){return self.revision>=version;};self.versionAtLeast=function(major){var properties=[self.major,self.minor,self.revision];var len=Math.min(properties.length,arguments.length);for(i=0;i<len;i++){if(properties[i]>=arguments[i]){if(i+1<len&&properties[i]==arguments[i]){continue;}else{return true;}}else{return false;}}};self.FlashDetect=function(){if(navigator.plugins&&navigator.plugins.length>0){var type='application/x-shockwave-flash';var mimeTypes=navigator.mimeTypes;if(mimeTypes&&mimeTypes[type]&&mimeTypes[type].enabledPlugin&&mimeTypes[type].enabledPlugin.description){var version=mimeTypes[type].enabledPlugin.description;var versionObj=parseStandardVersion(version);self.raw=versionObj.raw;self.major=versionObj.major;self.minor=versionObj.minor;self.revisionStr=versionObj.revisionStr;self.revision=versionObj.revision;self.installed=true;}}else if(navigator.appVersion.indexOf("Mac")==-1&&window.execScript){var version=-1;for(var i=0;i<activeXDetectRules.length&&version==-1;i++){var obj=getActiveXObject(activeXDetectRules[i].name);if(!obj.activeXError){self.installed=true;version=activeXDetectRules[i].version(obj);if(version!=-1){var versionObj=parseActiveXVersion(version);self.raw=versionObj.raw;self.major=versionObj.major;self.minor=versionObj.minor;self.revision=versionObj.revision;self.revisionStr=versionObj.revisionStr;}}}}}();};FlashDetect.JS_RELEASE="1.0.4";

	makeClass = function(){// John Resig (MIT Licensed) http://ejohn.org/blog/simple-class-instantiation/
		return function(args){
			if(this instanceof arguments.callee){
			if(typeof(this.init)==="function")
				this.init.apply(this,args.callee?args:arguments);
			}else{
				return new arguments.callee(arguments);
			}
		};
	}
	
	if(typeof(window.com)==="undefined"){window.com = {};}
	if(typeof(com.ticommunity)==="undefined"){com.ticommunity = makeClass();}
//	if(typeof(com.ticommunity.prototype)==="undefined"){com.ticommunity.prototype = {};}
	if(typeof(com.ticommunity.comm)==="undefined"){com.ticommunity.prototype.comm = makeClass();}
		
	com.ticommunity.prototype.comm.prototype = {

		init:function(options){
			com.ticommunity.comm = this;
			if (window.XDomainRequest) {
				//com.ticommunity.comm.request = com.ticommunity.comm.xdomain_request;
				com.ticommunity.comm.request = com.ticommunity.comm.flxhr_request;
			}else if(window.XMLHttpRequest){
				var temp_request = new XMLHttpRequest();
				if("withCredentials" in temp_request){
					com.ticommunity.comm.request = com.ticommunity.comm.xhr_request;
				}else if(FlashDetect.installed){
					com.ticommunity.comm.request = com.ticommunity.comm.flxhr_request;
				}else{
					com.ticommunity.comm.request = com.ticommunity.comm.request_with_iframe;
				}
				temp_request = null;
				delete temp_request;
			}else if(FlashDetect.installed){
				com.ticommunity.comm.request = com.ticommunity.comm.flxhr_request;
			}else{
				com.ticommunity.comm.request = com.ticommunity.comm.request_with_iframe;
			}
		},

		request: {},

		request_callback : function(response, callbacks, form){
			//console.log("got to CB");
			if(typeof(callbacks) === "object" && typeof(callbacks.success) === "function"){
				if(response.errors) {
					if(callbacks.failure){callbacks.failure(response, form);}
				}else if(typeof(response) === "object"){
					if(callbacks.success){callbacks.success(response, form);}
				} else if(response === " ") {
					if(callbacks.success) callbacks.success(response, form);
				}				
			}else if(typeof(callbacks) === "function"){
				callbacks(response);
			}
		},
		
		xdomain_request: function(type,url, data, callbacks, form){
			var form = (typeof(form) !=="undefined")?form: null;
			var xdr = new XDomainRequest();
			var response;
			data = com.ticommunity.obj_to_string(data);
			xdr.open(type, url);
			xdr.send(data);
			xdr.onload = function() {
				try { response = eval("(" + xdr.responseText + ")"); } catch(e) { response = {"errors": "Invalid Response Text"}; }
				com.ticommunity.comm.request_callback(response, callbacks, form);
			};
			xdr.onerror = function(){
				try { response = eval("(" + xdr.responseText + ")"); } catch(e) { response = {"errors" : "Server Error"}; }
				com.ticommunity.comm.request_callback(response, callbacks, form);
			};
		},

		xhr_request: function(type,url, data, callbacks, form){
			var form = (typeof(form) !=="undefined")?form: null;
			var xhr = new XMLHttpRequest();
			var response;
			
			data = com.ticommunity.comm.obj_to_string(data);
			xhr.open(type, url, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			xhr.setRequestHeader("Cache-Control", "no-cache");
			//xhr.setRequestHeader("Content-Length", data.length);
			xhr.setRequestHeader("X-TxId", com.ticommunity.comm.keyGen());
			//xhr.setRequestHeader("X_REQUESTED_WITH", "true");
			xhr.withCredentials = true;
			xhr.send(data);
			xhr.onreadystatechange = function(){
				if(xhr.readyState  == 4){
					if(xhr.status  == 200){
						try { response = eval("(" + xhr.responseText + ")"); } catch(e) { response = {"errors": "Invalid Response Text", "response": xhr.responseText}; }
						com.ticommunity.comm.request_callback(response, callbacks, form);
					}else{
						try { response = eval("(" + xhr.responseText + ")"); } catch(e) { response = {"errors": "Server Responded "+ xhr.status, "response": xhr.responseText}; }
						com.ticommunity.comm.request_callback(response, callbacks, form);
					}
				}
			};
		},

		flxhr_request: function(type ,url, data, callbacks, form){
			var form = (typeof(form) !=="undefined")?form: null;
			var xhr_callback = function(response){
				com.ticommunity.comm.request_callback(response, callbacks, form);
			};

			com.ticommunity.use_class("com.ticommunity.comm.flxhr_105",function(){
				com.ticommunity.comm.flxhr_105.xhr_connect(type,url,xhr_callback,data);
			});
		},

		request_with_iframe: function(type, url, data, callbacks,form){
			var form = (typeof(form) !=="undefined")?form: null;
			form.append('<input type="hidden" name="add_document_domain" value="true" />');
			if(callbacks.before) callbacks.before(form);
			var id = new Date().getTime();
			var iframe = '<iframe name="'+id+'" id="'+id+'" style="display:none;"></iframe>';
			jQuery(document.body).append(iframe);
			iframe = jQuery("#"+id+"");
			form.attr("accept-charset","utf-8").attr("target", id).attr("method", "post");
			iframe.load(function(){
				var response_string = iframe.contents().find("body").html();
				try { response = eval("(" + response_string + ")"); } catch(e) { response = {}; }
				com.ticommunity.comm.request_callback(response, callbacks, form);
				setTimeout(function(){ iframe.remove(); if(callbacks.cleanup) callbacks.cleanup();}, 200);
			});
		}, 

    obj_to_string: function(source_obj){
      var params = [];
      for(var key in source_obj){
        params.push(key + '='+ encodeURIComponent(source_obj[key])); 
      }
      return  (params.length > 0) ? params.join('&') : '';
    },

    keyGen: function(){
      var chr = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz",
        chrL = chr.length,
        len = 16,
        rStr = "",
        i,
        r;
      for(i=0;i<len;i++){
        r = Math.floor(Math.random()*chrL);
        rStr+=chr.charAt(r);
      }
      return rStr;
    }//,		
		
		// make_base_auth: function(user, password) {
		// 	var tok = user + ':' + password;
		// 	var hash = Base64.encode(tok);
		// 	return "Basic " + hash;
		// }
	}
})();
