parseSlideUri = (uri) ->
	args = uri.split('/')
	console.log(args)
	app: 'datacenter'
	school: args[1]
	id1: args[6]
	id2: args[7]
	id3: args[9]

Router.register '/datacenter', ->
	data = await Data.fetch('/data/datacenter/resource.json')
	table = Data.current = []
	index = 0

	for col in data
		if col.local_path
			if col.type == 5
				name = Element.Link(col.name, '#slide', parseSlideUri(col.local_path))
			else
				name = Element.Link(col.name, '/' + col.local_path)
		else
			name = col.name

		user_id = String(col.user_id)
		if col.user_extended and col.user_extended.length
			user_id += '(+' + col.user_extended.length + ')'

		table.push [
			++index,
			if col.teacher_name.startsWith('teacher') then col.teacher_name.slice(7) else col.teacher_name,
			name,
			Util.Date.toShortDate(col.create_time),
			Util.Date.toShortDate(col.download_time),
			user_id,
			col.type,
		]

	title: '云课堂'
	html: $ Element.Table(['#.thead-id', '教师', '名称', '创建时间.thead-time', '下载时间.thead-time', '用户', '类型'], table)
		.attr 'id', 'datacenter-list'
		.attr 'class', 'datatable'
		.prop 'outerHTML'
