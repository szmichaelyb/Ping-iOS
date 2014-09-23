// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
var _ = require("underscore");

Parse.Cloud.beforeSave("Selfies", function(request, response) {
    var post = request.object;

    var toLowerCase = function(w) {
        return w.toLowerCase();
    };

    var words = post.get("caption").split(/\b/);
    words = _.map(words, toLowerCase);
    var stopWords = ["the", "in", "and"]
    words = _.filter(words, function(w) {
        return w.match(/^\w+$/) && !_.contains(stopWords, w);
    });

    var hashtags = post.get("caption").match(/#.+?\b/g);
    hashtags = _.map(hashtags, toLowerCase);

    post.set("words", words);
    post.set("hashtags", hashtags);
    response.success();
});

Parse.Cloud.afterSave("Selfies", function(request) {

    //Send Push to User when their work is featured.
    var isFeatured = request.object.get("featured");
    if (isFeatured) {
        query = new Parse.Query(Parse.Installation);
        query.equalTo("owner", request.object.get("owner"));
        Parse.Push.send({
            where: query,
            data: {
                alert: "Woohoo!!! Your post has been featured. Keep creating GoCandids."
            }
        }, {
            success: function() {
                console.log("Success");
            },
            error: function(error) {
                console.error("Error");
            }
        });
    }
});

//Delete activities when a post is deleted
Parse.Cloud.afterDelete("Selfies", function(request) {
    query = new Parse.Query("Activity");
    query.equalTo("selfie", request.object);
    query.find({
        success: function(activities) {
            Parse.Cloud.useMasterKey();
            Parse.Object.destroyAll(activities, {
                success: function() {
                    console.log("Activities deleted successfully");
                },
                error: function(error) {
                    console.error("Error deleting related activities " + error.code + ": " + error.message);
                }
            });
        },
        error: function(error) {
            console.error("Error finding related activities " + error.code + ": " + error.message);
        }
    });
});

//Delete activity and selfies for user on user delete
Parse.Cloud.afterDelete(Parse.User, function(request) {
    fromQuery = new Parse.Query("Activity");
    fromQuery.equalTo("fromUser", request.object);

    toQuery = new Parse.Query("Activity");
    toQuery.equalTo("toUser", request.object);

    mainQuery = Parse.Query.or(fromQuery, toQuery);
    mainQuery.find({
        success: function(activities) {
            Parse.Cloud.useMasterKey();
            Parse.Object.destroyAll(activities, {
                success: function() {
                    console.log("activities deleted successfully");
                },
                error: function(error) {
                    console.error("Error deleting related activities " + error.code + ": " + error.message);
                }
            });
        },
        error: function(error) {
            console.error("Error finding related activities " + error.code + ": " + error.message);
        }
    });

    selfieQuery = new Parse.Query("Selfies");
    selfieQuery.equalTo("owner", request.object);

    selfieQuery.find({
        success: function(selfies) {
            Parse.Cloud.useMasterKey();
            Parse.Object.destroyAll(selfies, {
                success: function() {
                    console.log("selfies deleted successfully");
                },
                error: function(error) {
                    console.error("Error deleting related selfies " + error.code + ": " + error.message);
                }
            });
        },
        error: function(error) {
            console.error("Error finding related selfies " + error.code + ": " + error.message);
        }
    });
});

Parse.Cloud.define("sendMail", function(request, response) {
    var Mandrill = require('mandrill');
    Mandrill.initialize('3LDybsLqpFf6yZhCQs0KIg');

    Mandrill.sendEmail({
        message: {
            text: request.params.text,
            subject: request.params.subject,
            from_email: request.params.fromEmail,
            from_name: request.params.fromName,
            to: [{
                email: request.params.toEmail,
                name: request.params.toName
            }]
        },
        async: true
    }, {
        success: function(httpResponse) {
            console.log(httpResponse);
            response.success("Email sent!");
        },
        error: function(httpResponse) {
            console.error(httpResponse);
            response.error("Uh oh, something went wrong");
        }
    });
});

Parse.Cloud.define("editUser", function(request, response) {

    Parse.Cloud.useMasterKey();

    var userId = request.params.userId;
    var colName = request.params.colName;
    var colText = request.params.colText;

    var user = new Parse.Query(Parse.User);
    user.equalTo("objectId", userId);
    user.first({
        success: function(object) {
            object.set(colName, colText);

            object.save().then(function(object) {
                response.success(object);
            }, function(error) {
                response.error(error)
            });

        },
        error: function(error) {}
    });

});

Parse.Cloud.define("sendWelcomeEmail", function(request, response) {
	console.log("Sending welcome email");
    Parse.Cloud.httpRequest({

        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        url: 'https://mandrillapp.com/api/1.0/messages/send-template.json',
        body: {
            "key": "3LDybsLqpFf6yZhCQs0KIg",
            "template_name": "new-user-registration-email",
            "template_content": [{
                "name": "name",
                "content": "example content"
            }],
            "message": {
                "to": [{
                    "email": request.params.toEmail,
                    "name": request.params.name
                }]
            }
        },
        success: function(httpResponse) {
            console.log("Email send response: " + httpResponse);
            response.success();
        },
        error: function(httpResponse) {
            console.error("Email send Error: " + httpResponse);
            response.error("Error sending welcome email " + httpResponse.message);
        }
    });
});

Parse.Cloud.define("subscribeToList", function(request, response) {
	console.log("subscribing to list");
    Parse.Cloud.httpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        url: 'https://us8.api.mailchimp.com/2.0/lists/subscribe.json',
        body: {
            "apikey": "246b9d9c2e7a8c0298ef330c1785e926-us8",
            "id": "d652f9d2a7",
            "double_optin": false,
            "email": {
                "email": request.params.email
            },
            "send_welcome": false
        },
        success: function(httpResponse) {
            console.log("Added to list response: " + httpResponse);
				response.success();
        },
        error: function(httpResponse) {
            console.error("Added to list Error: " + httpResponse.message);
			response.error("Error Subscribing to list" + httpResponse.message);
        }
    });
});

//Schedule job
Parse.Cloud.job("notification", function(request, status) {
    Parse.Cloud.useMasterKey();
    Parse.Push.send({
        channels: ["channel"],
        data: {
            alert: "test"
        }
    }, {
        success: function() {
            status.success("Push sent to all users");
        },
        error: function(error) {
            status.error("Error sending pushes: " + error.code + ": " + error.message);
        }
    });
});

Parse.Cloud.define("hello", function(request, response) {
    response.success("Hello world!");
});