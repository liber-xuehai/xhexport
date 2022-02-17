router = new Router

router.register '/index', ->
	'Index Page'

router.register '/smartclassstu', ->
	data = await Data.fetch '/smartclassstu/resource.json'
	table = Data.current = []

	index = 0
	for col in data
		actions = ''

		if col.type is 6 or col.type is 8
			filepath = if col.type is 6 then col.local_path else col.remote_url
			filename = filepath.split('/')[-1..][0]
			actions += Element.Button '复制文件名', 'window.Util.clipText(\'' + filename + '\')'
		
		if col.type is 5
			plain = JSON.stringify col
			base64 = Util.Base64.encode plain
			command = 'python export.py ykt ' + base64
			actions += Element.Button '导出PPT', 'window.Util.clipText(\'' + command + '\')'

		table.push [
			++index,
			col.name,
			col.create_time,
			col.download_time,
			col.type,
			actions
		]

	Element.Table ['#', '名称','创建时间','下载时间','类型','动作'], table

router.reload()
