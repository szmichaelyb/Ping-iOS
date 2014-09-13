$(document).ready(function(e) {
    var pathname = $(location).attr('href');
    var resURL = pathname.split("/");     
	    if (pathname != null) {
        var resURL = pathname.split("/");
        var postFind = (resURL.indexOf("#posts") > - 1);
        if (postFind == false) {
            $("#main-site-contaner").show();
			 $("#user-data-start").hide();
        } else {
            $('#user-data-start').show();
			$('#home,#about,#features_1,#features_3,#footer,.arrows_box first,.first,.second,.third').hide();
            var userIdIndex = resURL.length - 1
            var userId = resURL[userIdIndex];
            $('meta').remove();
            $('head').append('<meta name="apple-itunes-app" content="app-id=898275446, affiliate-data=myAffiliateData, app-argument=http://www.gocandidapp.com/#posts/' + userId + '"> ');
            $.ajax({
                url: 'https://api.parse.com/1/classes/Selfies/' + userId,
                beforeSend: function(xhr) {
                    xhr.setRequestHeader("X-Parse-Application-Id", 'oLAYrU2fvZm5MTwA8z7kdtyVsJC4rSY4NiAh6yAp');
                    xhr.setRequestHeader("X-Parse-REST-API-Key", '0d9TgCbXtJWBlBAvDDG2KN0hLXdKWcdsML0EYciv');
                },
                success: function(selfieData) {
                    var caption = selfieData.caption
                    var selfie = selfieData.selfie.url
                    var ownerObjectId = selfieData.owner.objectId
                    $("#user-images").html('<img src="' + selfie + '" class="photo"/>');
                    $("#get-request-of-caption").text(caption);

                    $.ajax({
                        url: 'https://api.parse.com/1/users/' + ownerObjectId,
                        beforeSend: function(xhr) {
                            xhr.setRequestHeader("X-Parse-Application-Id", 'oLAYrU2fvZm5MTwA8z7kdtyVsJC4rSY4NiAh6yAp');
                            xhr.setRequestHeader("X-Parse-REST-API-Key", '0d9TgCbXtJWBlBAvDDG2KN0hLXdKWcdsML0EYciv');
                        },
                        success: function(userProfileData) {
                            var userName = userProfileData.name;
                            var userProfilePic = userProfileData.picture.url;
                            $('#user-name').text(userName)
                            $('#user-profile-pic').html('<img src="' + userProfilePic + '"/>')
                           
						    $.ajax({
                                url: 'https://api.parse.com/1/classes/Activity/',
                                beforeSend: function(xhr) {
                                    xhr.setRequestHeader("X-Parse-Application-Id", 'oLAYrU2fvZm5MTwA8z7kdtyVsJC4rSY4NiAh6yAp');
                                    xhr.setRequestHeader("X-Parse-REST-API-Key", '0d9TgCbXtJWBlBAvDDG2KN0hLXdKWcdsML0EYciv');
                                },
                                data: {
                                    "where": {
                                        "selfie": {
                                            "__type": "Pointer",
                                            "className": "Selfies",
                                            "objectId": userId
                                        },
                                        "type": "like"
                                    },
                                    "count": 1
                                },
								success: function(userData) {
								$("#total-like").text(userData.count);
                                }
                            })

                        }
                    });


                }
            });

        }
    } else {
        $("#main-site-contaner").show();
    }


});