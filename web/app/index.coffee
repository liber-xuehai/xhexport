Router.register '/index', ->
	html: 'Index Page'


Router.register '/smartclassstu', ->
	data = await Data.fetch '/data/smartclassstu/resource.json'
	table = Data.current = []
	index = 0

	for col in data
		actions = []

		if col.type is 6 or col.type is 8
			fileName = col.local_path.split('/')[-1..][0]
			actions.push Element.NewPageLinkButton '打开', '/' + col.local_path
			actions.push Element.Button '文件名', 'window.Util.clipText(\'' + fileName + '\')'
		
		if col.type is 5
			plain = JSON.stringify col
			base64 = Util.Base64.encode plain
			command = 'python export.py ykt ' + base64
			actions.push Element.Button '导出指令', 'window.Util.clipText(\'' + command + '\')'

		table.push [
			++index,
			col.name,
			Util.Date.toShortDate(col.create_time),
			Util.Date.toShortDate(col.download_time),
			col.type,
			actions.join ' '
		]

	title: '云课堂'
	html: Element.Table ['#', '名称', '创建时间', '下载时间', '类型', '动作'], table


Router.register '/arespunc', ->
	data = await Data.fetch '/data/arespunc/session.json'
	table = Data.current = []

	session = []
	for id, val of data
		if val.last_update
			val.id = id
			session.push val
	session.sort (a, b) ->
		b.last_update - a.last_update

	for col, index in session
		table.push [
			index + 1,
			col.type,
			Element.Link(col.name, '#arespunc/' + col.id),
			Util.Date.toDate(col.last_update),
		]

	title: '云作业'
	html: Element.Table ['#', '类型', '名称', '更新时间'], table


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

	title: session_id + ' - 云作业'
	html: $ Element.Table ['#', '发送人', '发送时间', '内容'], table
		.attr 'id', 'arespunc-message-list'
		.prop 'outerHTML'


Router.register '/acldstu', ->
	data = await Data.fetch '/data/acldstu/homework.json'
	table = Data.current = []
	index = 0

	for col in data
		linkedName = col.name
		if col.local_path
			linkedName = Element.Link col.name, '#acldstu/' + col.local_path.replace /\//g, ','
		table.push [
			++index,
			col.subject,
			linkedName,
			col.score.toFixed(),
			Util.Date.toShortDate(col.create_time),
			Util.Date.toShortDate(col.update_time),
		]

	title: '云作业'
	html: Element.Table ['#', '学科', '名称', '分数', '创建时间', '更新时间'], table


Router.register '/acldstu/*', (path) ->
	path = ('/' + path).replace /\,/g,  '/'
	data = JSON.parse await Data.fetch path
	table = Data.current = []
	index = 0

	answer = new class then constructor: ->
		for e in data.questionAnswers
			if @[e.questionId] is undefined
				@[e.questionId] = []
			@[e.questionId].push e
		this

	for col in data.questionPoolContentInfos
		table.push [
			++index,
			'题目',
			col.stemContent,
		]
		if col.explainContent
			table.push [
				++index,
				'解析',
				col.explainContent,
			]
		if col.questionId in Object.keys answer
			for e in answer[col.questionId]
				table.push [
					++index,
					'答案',
					'<p>' + e.answerContent + '</p>',
					# JSON.stringify answer[col.questionId],
				]
	
	title: path.split('/')[-1..][0] + ' - 云作业'
	html: $ Element.Table ['#', '类型', '内容'], table
		.attr 'id', 'acldstu-homework'
		.prop 'outerHTML'
	onLoad:	($container) ->
		$container
			.find '.mathquill-embedded-latex'
			.each ->
				katex.render this.innerText, this, {displayMode: false, throwOnError: false}


Router.reload()