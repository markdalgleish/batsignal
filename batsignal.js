var messages = new Meteor.Collection('messages');

messages.add = function(message) {
	if (typeof message === 'string') {
		this.insert({message: message, isRead: false});
		return true;
	}
	return false;
};

if (Meteor.is_server) {
	Meteor.publish('messages', function() {
		return messages.find({}, {sort: {$natural: -1}, limit: 1});
	});
}

if (Meteor.is_client) {
	Meteor.subscribe('messages');

	var submit = function() {
		var textbox = document.getElementById('text');
		if (messages.add(textbox.value)) textbox.value = '';
	};

	var getMessage = function() {
		return messages.findOne({});
	};
	
	Template.main.messages = function() {
		return messages.find({});
	};

	Template.main.inputClassName = function() {
		return !getMessage() || getMessage().isRead ? 'read' : 'unread';
	};

	Template.main.events = {
		'click button': submit,
		'keypress input': function(e) {
			e.which === 13 && submit();
		}
	};

	Template.message.className = function() {
		return this.isRead ? 'read' : 'unread';
	};

	Template.message.events = {
		'click' : function() {
			messages.update(this, {$set: {isRead: true}});
		}
	};
}