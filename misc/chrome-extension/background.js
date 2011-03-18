$(function(){
    if(!localStorage['api-root']){ return; }

    function api(path){
	return localStorage['api-root']+"/api/v1/user/rooms";
    }

    if(localStorage['last-id']){
	$.getJSON(api("/api/v1/user/rooms"),
		  { 'api_key' : localStorage['api-key'] },
		  function(json){
		      $(json.rooms).each(function(_, room){

		      });
		  });
    }

    $.fn.desktopNotify({
	title:"AsakusaSatellite",
	text : "Background start"
    });
    var elem = $(".message-list")

    elem.webSocket({
	entry : localStorage['ws-root'] + "/user?api_key="+localStorage['api-key']
    });

    elem.bind('websocket::create', function(_, message){
	localStorage['last-id'] = message.id;

	if(message.screen_name != "#{current_user.screen_name}") {
            $.fn.desktopNotify({
		picture: message.profile_image_url,
		title: message.name,
		text : (message.attachment != null ? message.attachment.filename : message.body)
            });
	}
    });
});