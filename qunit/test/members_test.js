module("members module");

(function(){
    var target = $('<div />');
    var members = $('<div />');
    target.members(members,
		   {initi});
    test('membersが追加される', function() {
	target.trigger("websocket::members", [[
	    { "id": 1,
	      "name" : "mizuno",
	      "screen_name" : "mzp",
	      "profile_image_url" : "image.png" },
	    { "id": 2,
	      "name" : "another",
	      "screen_name" : "nzp",
	      "profile_image_url" : "image.png" } ]]);
	equals($("div.user",members).length, 2);
    });

    test('membersがリセットされる', function() {
	target.trigger("websocket::members", [[
	    { "id": 1,
	      "name" : "mizuno",
	      "screen_name" : "mzp",
	      "profile_image_url" : "image.png" },
	    { "id": 3,
	      "name" : "another",
	      "screen_name" : "nzp",
	      "profile_image_url" : "image.png" } ]]);
	equals($("div.user",members).length, 2);
    });

})();