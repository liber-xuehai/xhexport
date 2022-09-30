parseSlideUri = (uri) ->
	# args = uri.split('/')
	app: 'datacenter'
	# school: args[1]
	# student: args[4]
	# class: args[6]
	# file: args[8]

Router.register '/datacenter', ->
	data = await Data.fetch('/data/datacenter/resource.json')
	table = Data.current = []
	index = 0

	for col in data
		actions = []

		if col.type in [6, 8]
			name = Element.Link(col.name, '/' + col.local_path)
		# else if col.type == 5
		# 	name = Element.Link(col.name, '#slide', parseSlideUri(col.local_path))
		else
			name = col.name

		user_id = String(col.user_id)
		if col.user_extended and col.user_extended.length
			user_id += '(+' + col.user_extended.length + ')'
		table.push [
			++index,
			name,
			col.teacher_name,
			Util.Date.toShortDate(col.create_time),
			Util.Date.toShortDate(col.download_time),
			user_id,
			col.type,
		]

	title: '云课堂'
	html: $ Element.Table(['#.thead-id', '名称', '教师', '创建时间.thead-time', '下载时间.thead-time', '用户', '类型'], table)
		.attr 'id', 'datacenter-list'
		.attr 'class', 'datatable'
		.prop 'outerHTML'
