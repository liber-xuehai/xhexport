SessionTypeTransfer =
	SINGLE: '私聊'
	GROUP: '群组'
		
Router.register '/arespunc', ->
	data = await Data.fetch('/data/arespunc/session.json')
	table = Data.current = []

	session = []
	for id, val of data
		if val.last_update
			val.id = id
			session.push(val)
	session.sort((a, b) -> b.last_update - a.last_update)

	for col, index in session
		table.push([
			index + 1,
			SessionTypeTransfer[col.type],
			Element.Link(col.name, '#arespunc/' + col.id),
			Util.Date.toDate(col.last_update),
		])

	title: '响应'
	html: $ Element.Table ['#.thead-id', '类型', '名称', '更新时间.thead-fulltime'], table
		.attr 'id', 'arespunc-list'
		.attr 'class', 'datatable'
		.prop 'outerHTML'



Router.register '/arespunc/*', (session_id) ->
	data = await Data.fetch '/data/arespunc/message.json'
	table = Data.current = []
	index = 0

	for col in data
		if String(col.session_id) == session_id
			contentHtml = ''
			if col.type.endsWith('_TEXT')
				contentHtml = col.content
					.replace /\n/g, '<br>'
			else if col.type.endsWith('_IMAGE') or col.type.endsWith('_NOTE')
				content = JSON.parse col.content
				contentHtml = '<img src="' + content.serverimg_url + '" />'
			else
				content =	
					type: col.type
					content: col.content
				contentHtml = JSON.stringify content
			table.push [
				++index,
				col.sender,
				Util.Date.toShortDate(col.created_time),
				contentHtml,
			]

	title: session_id + ' - 响应'
	html: $ Element.Table ['#.thead-id', '发送人', '时间.thead-time', '内容'], table
		.attr 'id', 'arespunc-message-list'
		.attr 'class', 'datatable'
		.prop 'outerHTML'