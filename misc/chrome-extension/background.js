$(function(){
    $.fn.desktopNotify({
	title:"AsakusaSatellite",
	text : "Background start"
    });
    var elem = $(".message-list")

    elem.webSocket({
	entry : localStorage['ws-root'] + "/user?api_key="+localStorage['api-key']
    });

    elem.bind('websocket::create', function(_, message){
	if(message.screen_name != "#{current_user.screen_name}") {
            $.fn.desktopNotify({
		picture: message.profile_image_url,
		title: message.name,
		text : (message.attachment != null ? message.attachment.filename : message.body)
            });
	}
    });
})