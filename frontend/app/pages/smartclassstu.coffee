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