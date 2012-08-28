messages = new Meteor.Collection 'messages'

messages.add = (message) ->
	if typeof message is 'string'
		@insert message: message, isRead: false

if Meteor.is_server
	Meteor.publish 'messages', ->
		messages.find {},
			sort: $natural: -1
			limit: 1
else
	Meteor.subscribe 'messages'

	getMessage = -> messages.findOne {}

	isRead = -> not getMessage() or getMessage().isRead

	addMessage = ->
		textbox = document.getElementById 'textbox'
		if isRead() and messages.add textbox.value then textbox.value = ''

	Template.main.messages = -> messages.find {}

	Template.main.inputClassName = -> if isRead() then 'read' else 'unread'

	Template.main.events =
		'click button': addMessage
		'keypress input': (e) -> addMessage() if e.which is 13

	Template.message.className = -> if @isRead then 'read' else 'unread'

	Template.message.events = click: -> messages.update this, $set: isRead: true