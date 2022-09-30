parseSlideUri = (uri) ->
	args = uri.split('/')
	app: 'smartclassstu'
	school: args[1]
	student: args[4]
	class: args[6]
	file: args[8]

Router.register '/smartclassstu', ->
	data = await Data.fetch('/data/smartclassstu/resource.json')
	table = Data.current = []
	index = 0

	for col in data
		actions = []

		if col.type in [1, 6, 8]
			name = Element.Link(col.name, '/' + col.local_path)
		else if col.type == 5
			name = Element.Link(col.name, '#slide', parseSlideUri(col.local_path))
		else
			name = col.name

		# if col.type in [6, 8]
		# 	fileName = col.local_path.split('/')[-1..][0]
		# 	actions.push(Element.Button('文件名', 'window.Util.clipText(\'' + fileName + '\')'))
		
		# if col.type is 5
		# 	base64 = Util.Base64.encode(JSON.stringify(col))
		# 	command = 'python xuehai.py export ykt ' + base64
		# 	actions.push(Element.Button('CLI::Export', 'window.Util.clipText(\'' + command + '\')'))

		user_id = String(col.user_id)
		if col.user_extended and col.user_extended.length
			user_id += '(+' + col.user_extended.length + ')'
		table.push [
			++index,
			name,
			Util.Date.toShortDate(col.create_time),
			Util.Date.toShortDate(col.download_time),
			user_id,
			'(' + col.type + ')&nbsp;&nbsp;' + actions.join(' ')
		]

	title: '云课堂'
	html: $ Element.Table(['#.thead-id', '名称', '创建时间.thead-time', '下载时间.thead-time', '用户', '类型'], table)
		.attr 'id', 'smartclassstu-list'
		.attr 'class', 'datatable'
		.prop 'outerHTML'
