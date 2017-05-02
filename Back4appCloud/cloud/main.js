 /*Parse.Cloud.afterSave('ActiveSessions', function(request, response) {
	var activeSession = request.object;
    if (activeSession.get("receiverID")) {
		response.success();
	} else {
		var caller = activeSession.get('caller');
		var receiver = activeSession.get('receiver'); 
		var user = request.user;
		var query = new Parse.Query(Parse.Installation);
		if (caller.id === user.id) {
			var pusher = pushType(activeSession, query, caller, receiver);
			if pusher {  
        		response.success();
			}
    	} else {
			var pusher = pushType(activeSession, query, receiver, caller);
			if pusher {  
        		response.success();
			}
    	}
	}
});*/

Parse.Cloud.afterSave('ActiveSessions', function(request, response) {
	var activeSession = request.object;
    if (activeSession.get("receiverID")) {
		response.success();
	} else {
		var accepted = activeSession.get('Accepted');
		var caller = activeSession.get('caller');
		var receiver = activeSession.get('receiver'); 
		var callerTitle = activeSession.get('callerTitle')
		var user = request.user;
		var query = new Parse.Query(Parse.Installation);
		if (caller.id === user.id) {
	    	response.success();
			//receiver.increment('gameInvite');
			//receiver.save()
			query.equalTo('User',receiver);
			Parse.Push.send({where: query, data: {
					alert : callerTitle, 
					ObjID : receiver.id,
					badge: 'Increment',
					gameID: activeSession.id,
					type : 'gameInvite' 
    			}}, {
				useMasterKey: true,
				success: function() {     
        			response.success()
   	        }, error: function(error) {
					response.error('could not create publisher token for activeSession: ' + activeSession.id);
    		}});
    	} else {
	    	response.success();
			//caller.increment('gameInvite');
			//caller.save()
			query.equalTo('User',caller);
			Parse.Push.send({where: query, data: {
					alert : callerTitle,
					ObjID : caller.id,
					badge: 'Increment',
					gameID: activeSession.id,
					type : 'gameInvite' 
    			}}, {
				useMasterKey: true,
				success: function() {     
        			response.success()
   	        }, error: function(error) {
					response.error('could not create publisher token for activeSession: ' + activeSession.id);
    		}});
    	}
	}
});


/*var pushType = function(activeSession, query, sender, receiver) {
	var accepted = activeSession.get('Accepted');
	var callerTitle = activeSession.get('callerTitle');
	var type = 'gameInvite';
	query.equalTo('User',receiver);
	if accepted {
		type = 'accepted'
	}
	Parse.Push.send({where: query, data: {
		alert : callerTitle, 
		ObjID : receiver.id,
		badge: 'Increment',
		gameID: activeSession.id,
		type : type 
    }}, {
	useMasterKey: true,
	success: function() {     
        response.success()
   	}, error: function(error) {
		response.error('could not create publisher token for activeSession: ' + activeSession.id);
    }});
}*/

 Parse.Cloud.beforeSave('ActiveSessions', function(request, response) {
	var activeSession = request.object;
	if (activeSession.get("sessionID")) {
		response.success();
  	}
  	Parse.Cloud.httpRequest({
  		url: 'https://rpsava.herokuapp.com/session'
  	}).then(function(httpResponse) { 
	  	var sessionID = httpResponse.data["sessionId"].toString();
	  	var publisherToken = httpResponse.data["publisherToken"].toString();
	  	var subscriberToken = httpResponse.data["subscriberToken"].toString();
	  	activeSession.set("sessionID", sessionID);
	  	activeSession.set("publisherToken", publisherToken);
	  	activeSession.set("subscriberToken", subscriberToken);
	  	response.success();
  	},function(httpResponse) {
		response.error("Request failed with response code:" + httpResponse.status);
  	});
});

/*var activeSession = request.object;
    //var role = roleForUser(activeSession, request.user);
	if (activeSession.get("sessionID")) {
		response.success();
  	}
  	Parse.Cloud.httpRequest({
  		url: 'https://rpsava.herokuapp.com/session'
  	}).then(function(httpResponse) { 
	  	var sessionID = httpResponse.data["sessionId"].toString();
	  	var publisherToken = httpResponse.data["publisherToken"].toString();
	  	var subscriberToken = httpResponse.data["subscriberToken"].toString();
	  	activeSession.set("sessionID", sessionID);
	  	activeSession.set("publisherToken", publisherToken);
	  	activeSession.set("subscriberToken", subscriberToken);
	  	if (activeSession.get("receiverID")) {
			response.success();
		} else {
			var accepted = activeSession.get('Accepted');
			var caller = activeSession.get('caller');
			var receiver = activeSession.get('receiver'); 
			var callerTitle = activeSession.get('callerTitle')
			var user = request.user;
			var query = new Parse.Query(Parse.Installation);
			if (caller.id === user.id) {
				//receiver.increment('gameInvite');
				//receiver.save()
				if accepted {
					
				} else {
				query.equalTo('User',receiver);
				Parse.Push.send({where: query, data: {
					alert : callerTitle, 
					ObjID : receiver.id,
					badge: 'Increment',
					gameID: activeSession.id,
					type : 'gameInvite' 
    			}}, {
				useMasterKey: true,
				success: function() {     
        			response.success()
   	        	}, error: function(error) {
					response.error('could not create publisher token for activeSession: ' + activeSession.id);
    			}});
				//}
    		} else {
	    		if accepted {
					
				} else {
				}	
				//caller.increment('gameInvite');
				//caller.save()
				query.equalTo('User',caller);
				Parse.Push.send({where: query, data: {
					alert : callerTitle,
					ObjID : caller.id,
					badge: 'Increment',
					gameID: activeSession.id,
					type : 'gameInvite' 
    			}}, {
				useMasterKey: true,
				success: function() {     
        			response.success()
   	        	}, error: function(error) {
					response.error('could not create publisher token for activeSession: ' + activeSession.id);
    			}});
				
    		}
		}
  	},function(httpResponse) {
		response.error("Request failed with response code:" + httpResponse.status);
  	});*/
  	
    /*if (activeSession.get("receiverID")) {
		response.success();
	} else {
		var accepted = activeSession.get('Accepted');
		var caller = activeSession.get('caller');
		var receiver = activeSession.get('receiver'); 
		var callerTitle = activeSession.get('callerTitle')
		var user = request.user;
		var query = new Parse.Query(Parse.Installation);
		if (caller.id === user.id) {
	    	response.success();
			//receiver.increment('gameInvite');
			//receiver.save()
			query.equalTo('User',receiver);
			Parse.Push.send({where: query, data: {
					alert : callerTitle, 
					ObjID : receiver.id,
					badge: 'Increment',
					gameID: activeSession.id,
					type : 'gameInvite' 
    			}}, {
				useMasterKey: true,
				success: function() {     
        			response.success()
   	        }, error: function(error) {
					response.error('could not create publisher token for activeSession: ' + activeSession.id);
    		}});
    	} else {
	    	response.success();
			//caller.increment('gameInvite');
			//caller.save()
			query.equalTo('User',caller);
			Parse.Push.send({where: query, data: {
					alert : callerTitle,
					ObjID : caller.id,
					badge: 'Increment',
					gameID: activeSession.id,
					type : 'gameInvite' 
    			}}, {
				useMasterKey: true,
				success: function() {     
        			response.success()
   	        }, error: function(error) {
					response.error('could not create publisher token for activeSession: ' + activeSession.id);
    		}});
    	}
	}
	 */


Parse.Cloud.beforeSave('Notification', function(request, response) {
    var notify = request.object;
    var sentFrom = notify.get('SentFrom')
    var user = notify.get('User')
    var message = notify.get('Message')
    var query = new Parse.Query(Parse.Installation);
    if (notify.get("Accepted")) {
	sentFrom.increment('friendAccepted');
    	sentFrom.save()
    	query.equalTo('User',sentFrom);
    	Parse.Push.send({where: query, data: {
		alert : message,
        	ObjID : user.id,
        	inviteID : notify.id,
        	badge: 'Increment',
        	type : 'friendAccepted' 
    	}}, {
		useMasterKey: true,
  		success: function() {     
        	response.success()
		//notify.delete()
    	}, error: function(error) {
    		response.error('could not create publisher token for activeSession: ' + activeSession.id);
    	}});
    } else {
    	user.increment('friendInvite');
    	user.save()
    	query.equalTo('User',user);
    	Parse.Push.send({where: query, data: {
		alert : message,
        	ObjID : sentFrom.id,
        	inviteID : notify.id,
        	badge: 'Increment',
        	type : 'friendInvite' 
    	}}, {
		useMasterKey: true,
  		success: function() {     
        	response.success()
    	}, error: function(error) {
    		// Handle error
    		response.error('could not create publisher token for activeSession: ' + activeSession.id);
    	}}); 
    }
});
 