
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
var _ = require("underscore");

Parse.Cloud.beforeSave("Selfies", function(request, response) {
    var post = request.object;
 
    var toLowerCase = function(w) { return w.toLowerCase(); };
 
    var words = post.get("caption").split(/\b/);
    words = _.map(words, toLowerCase);
    var stopWords = ["the", "in", "and"]
    words = _.filter(words, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
 
    var hashtags = post.get("caption").match(/#.+?\b/g);
    hashtags = _.map(hashtags, toLowerCase);
 
    post.set("words", words);
    post.set("hashtags", hashtags);
    response.success();
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
Parse.Cloud.afterDelete(Parse.User, function(request){
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
	Mandrill.initialize('BSEMYtGxtM8LySaUgQsFUA');

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
	},{
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

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
