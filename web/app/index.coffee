Router.register '/index', ->
	'Index Page'


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
	
	html = $ Element.Table ['#', '类型', '内容'], table
		.addClass 'acldstu-homework'
		.prop 'outerHTML'
	html += '
		<style>
			table.acldstu-homework>tbody>tr>td:nth-child(1){min-width:25px;text-align:center}
			table.acldstu-homework>tbody>tr>td:nth-child(2){min-width:30px;text-align:center}
			table.acldstu-homework>tbody>tr>td:nth-child(3)>p:first-child{margin-block-start:.5em;}
			table.acldstu-homework>tbody>tr>td:nth-child(3)>p:last-child{margin-block-end:.5em;}
			table.acldstu-homework img{max-width:100%}
		</style>
	'

	title: path.split('/')[-1..][0] + ' - 云作业'
	html: html
	onLoad:	($container) ->
		$container
			.find '.mathquill-embedded-latex'
			.each ->
				katex.render this.innerText, this, {displayMode: false, throwOnError: false}


Router.reload()