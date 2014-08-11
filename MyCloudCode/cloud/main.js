
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

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
