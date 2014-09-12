$(document).ready(function(e) {	
var pathname =  $(location).attr('href');
var resURL = pathname.split("/"); 
console.log(resURL)

if(pathname!= null){
var resURL = pathname.split("/"); 
var postFind = (resURL.indexOf("#posts") > -1);
if(postFind==false){
	$("#main-site-contaner").show();
	}
else{
 $('#user-data-start').show();	
 var userIdIndex=resURL.length-1
var userId=resURL[userIdIndex];
console.log(pathname);
console.log(userIdIndex);
console.log(userId);
$.ajax({
    url: "key.php",
    dataType: 'json',
    success: function(data){
	  $.ajax({
  url: 'https://api.parse.com/1/classes/Selfies/'+userId,
  beforeSend: function(xhr) {
    xhr.setRequestHeader("X-Parse-Application-Id", data['id']);
	xhr.setRequestHeader("X-Parse-REST-API-Key", data['key']);
  },
  success: function(selfieData) {
	  var caption=selfieData.caption
	  var selfie=selfieData.selfie.url
	  var ownerObjectId=selfieData.owner.objectId
	  $("#user-images").html('<img src="'+selfie+'" class="photo"/>');
	  $("#get-request-of-caption").text(caption);
	  
		$.ajax({
		url: 'https://api.parse.com/1/users/'+ownerObjectId,
		beforeSend: function(xhr) {
		xhr.setRequestHeader("X-Parse-Application-Id", data['id']);
		xhr.setRequestHeader("X-Parse-REST-API-Key", data['key']);
		},
		success: function(userProfileData) {
		var userName=userProfileData.name;
		var userProfilePic=userProfileData.picture.url;
		$('#user-name').text(userName)
		$('#user-profile-pic').html('<img src="'+userProfilePic+'"/>')
		
		
		$.ajax({
		url: 'https://api.parse.com/1/classes/Activity/',
		beforeSend: function(xhr) {
		xhr.setRequestHeader("X-Parse-Application-Id", data['id']);
		xhr.setRequestHeader("X-Parse-REST-API-Key", data['key']);
		},
		success: function(userData) {
           $("#total-like").text(userData.results.length);
		}
		})
		
		}
    });	  

  }
}); 
    }
 });
 
  }
  }else{
	 $("#main-site-contaner").show(); 
	  }
  
  
}); 
  

