parseHomeworkUri = (uri) ->
	args = uri.split('/')
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
			linkedName = Element.Link(col.name, '#acldstu/homework', parseHomeworkUri(col.local_path))
		else if col.has_sheet
			linkedName = Element.Link(col.name, '#acldstu/homework-sheet/' + col.id)
		if col.remote_url
			linkedName += ' <sup>' + Element.Link('#', col.remote_url) + '</sup>'
		user_id = String(col.user_id)
		if col.user_extended and col.user_extended.length
			user_id += '(+' + col.user_extended.length + ')'
		table.push [
			++index,
			col.subject,
			linkedName,
			col.score.toFixed(),
			Util.Date.toShortDate(col.create_time),
			Util.Date.toShortDate(col.update_time),
			user_id,
		]

	title: '云作业'
	html: $ Element.Table ['#.thead-id', '学科', '名称', '分数', '创建时间.thead-time', '更新时间.thead-time', '用户'], table
		.attr 'id', 'acldstu-list'
		.attr 'class', 'datatable'
		.prop 'outerHTML'


Router.register '/acldstu/homework', ({ params }) ->
	path = "/xuehai/#{params.school}/filebases/com.xh.acldstu/#{params.student}/#{params.teacher}/#{params.file}"
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
	html: $ Element.Table ['#.thead-id', '类型', '内容'], table
		.attr 'id', 'acldstu-homework'
		.attr 'class', 'datatable'
		.prop 'outerHTML'
	onLoad:	($container) ->
		$container
			.find '.mathquill-embedded-latex'
			.each ->
				katex.render this.innerText, this, {displayMode: false, throwOnError: false}

Router.register '/acldstu/homework-sheet/*', (work_id) ->
	data = await Data.fetch '/data/acldstu/sheet/' + work_id + '.json'

	mainTable = []
	for col in data.scanTopics
		col.topicNo = col.topicNo + 1
		for topic in data.topicTitles
			if topic.topicNoSet.includes(col.topicNo - 1)
				col.type = topic.titleName
				break
		col.answer = col.answer
			.replace(/<<<<<<<我是填空题键盘输入类型的分隔符>>>>>>>/g, ' && ')
		if col.systemType != 1 
			mainTable.push([
				col.topicNo,
				col.answer,
				col.score / 10000,
				col.type,
			])
	if mainTable.length
		mainTableHTML = $(Element.Table(['#', '答案', '分值', '题型'], mainTable))
			.attr('id', 'acldstu-homework-sheet')
			.prop('outerHTML')
	else
		mainTableHTML = ''
	
	MCQTable = []
	for col in data.scanTopics
		if col.systemType == 1
			MCQTable.push([col.topicNo, col.answer, col.score / 10000])
	if MCQTable.length
		MCQTableHTML = '<table id="acldstu-homework-mcq"><tbody>'
		for i in [0...(MCQTable.length + 4) / 5]
			MCQTableHTML += '<tr>'
			for j in [0...Math.min(5, MCQTable.length - 5 * i)]
				MCQTableHTML += '<td>'+ MCQTable[i * 5 + j][0] + '</td>'
			MCQTableHTML += '</tr><tr>'
			for j in [0...Math.min(5, MCQTable.length - 5 * i)]
				MCQTableHTML += '<td>'+ MCQTable[i * 5 + j][1] + '</td>'
			MCQTableHTML += '</tr>'
		MCQTableHTML += '</tbody></table>'
	else
		MCQTableHTML = ''

	title: work_id + ' - 云作业'
	html: MCQTableHTML + (if MCQTableHTML && mainTableHTML then '<br>' else '')+ mainTableHTML