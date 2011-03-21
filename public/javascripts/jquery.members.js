(function($) {
    jQuery.fn.members = function(members){
	var target = this;
	$(target).bind("websocket::members",function(_, users){
	    var html = '';
	    $(users).each(function(_, user){
		html += '<div class="user"><img src="'+user.profile_image_url+'" />' + user.name + '</div>';
	    });
	    $(members).html(html);
	});
	return this;
    }
})(jQuery);
