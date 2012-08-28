var Messages = new Meteor.Collection('messages');

Messages.add = function(message) {
	if (typeof message === 'string') {
		this.insert({message: message, isRead: false});
		return true;
	}
	return false;
};

if (Meteor.is_server) {
	Meteor.publish('messages', function() {
		return Messages.find({}, {sort: {$natural: -1}, limit: 1});
	});
}

if (Meteor.is_client) {
	Meteor.subscribe('messages');

	var submit = function() {
		var textbox = document.getElementById('text');
		if (Messages.add(textbox.value)) textbox.value = '';
	};

	var getMessage = function() {
		return Messages.findOne({});
	}
	
	Template.main.messages = function() {
		return Messages.find({});
	};

	Template.main.inputClassName = function() {
		return getMessage() && getMessage().isRead ? 'read' : 'unread';
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
			Messages.update(this, {$set: {isRead: true}});
		}
	};
}