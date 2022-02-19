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
	dict = await Data.fetch '/data/acldstu/dictionary.json'
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
					'<p><strong>【' + dict.questionUserType[col.questionUserType] + '】</strong>' + e.answerContent + '</p>',
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