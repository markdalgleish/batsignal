messages = new Meteor.Collection 'messages'

allMessages = messages.find {}

latestMessage = messages.find {}, { sort: { $natural: -1 }, limit: 1 }

messages.isValid = (message) -> typeof message is 'string' and message.length <= 70

messages.add = (message) -> if @isValid message then @insert message: message, isRead: false

messages.allow
  insert: (userId, doc) -> true
  update: (userId, doc, fields, modifier) -> true
  remove: (userId, doc) -> true

if Meteor.isServer
	Meteor.publish 'messages', -> latestMessage

if Meteor.isClient
	window.messages = messages
	window.latestMessage = latestMessage

	Meteor.subscribe 'messages'

	allMessages.observe added: (msg) -> if not msg.isRead then speak msg.message, speed: 140, pitch: 30, wordgap: 10

	getMessage = -> messages.findOne {}

	isRead = -> not getMessage() or getMessage().isRead

	addMessage = ->
		textbox = document.getElementById 'textbox'
		if isRead() and messages.add textbox.value then textbox.value = ''

	_.extend Template.main,
		messages: -> allMessages
		inputClassName: -> if isRead() then 'read' else 'unread'
		events:
			'click button': addMessage
			'keypress input': (e) -> addMessage() if e.which is 13

	_.extend Template.message,
		className: -> if @isRead then 'read' else 'unread'
		events: click: -> messages.update @_id, $set: isRead: true
