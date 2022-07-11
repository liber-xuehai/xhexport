parseHomework = (url) ->
	args = url.split('/')
	school: args[1]
	student: args[4]
	teacher: args[5]
	file: args[6]

Router.register '/acldstu', ->
	data = await Data.fetch '/data/acldstu/homework.json'
	table = Data.current = []
	index = 0

	for col in data
		linkedName = col.name
		if col.local_path
			linkedName = Element.Link(col.name, '#acldstu/homework', parseHomework(col.local_path))
		user_id = String col.user_id
		if col.user_extended and col.user_extended.length
			user_id += '(+' + col.user_extended.length + ')'
		table.push [
			++index,
			col.subject,
			linkedName,
			col.score.toFixed(),
			Util.Date.toShortDate(col.create_time),
			Util.Date.toShortDate(col.update_time),
			user_id
		]

	title: '云作业'
	html: $ Element.Table ['#', '学科', '名称', '分数', '创建时间', '更新时间', '用户'], table
		.attr 'id', 'acldstu-list'
		.prop 'outerHTML'


Router.register '/acldstu/homework', ({ params }) ->
	path = "/xuehai/#{params.school}/filebases/com.xh.acldstu/#{params.student}/#{params.teacher}/#{params.file}"
	console.log(path)
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