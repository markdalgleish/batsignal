messages = new Meteor.Collection 'messages'

messages.isValid = (message) -> typeof message is 'string' and message.length < 50

messages.add = (message) -> if @isValid message then @insert message: message, isRead: false

if Meteor.is_server
	Meteor.publish 'messages', ->
		messages.find {},
			sort: $natural: -1
			limit: 1
else
	Meteor.subscribe 'messages'

	messages.find({}).observe added: (msg) -> speak msg.message, speed: 140, amplitude: 200, pitch: 30, wordgap: 10
	
	getMessage = -> messages.findOne {}

	isRead = -> not getMessage() or getMessage().isRead

	addMessage = ->
		textbox = document.getElementById 'textbox'
		if isRead() and messages.add textbox.value then textbox.value = ''

	_.extend Template.main,
		messages: -> messages.find {}
		inputClassName: -> if isRead() then 'read' else 'unread'
		events:
			'click button': addMessage
			'keypress input': (e) -> addMessage() if e.which is 13

	_.extend Template.message,
		className: -> if @isRead then 'read' else 'unread'
		events: click: -> messages.update this, $set: isRead: true