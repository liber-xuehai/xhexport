parseSlideUri = (uri) ->
	args = uri.split('/')
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

		if col.type in [6, 8]
			name = Element.Link(col.name, '/' + col.local_path)
		else if col.type == 5
			name = Element.Link(col.name, '#smartclassstu/slideViewer', parseSlideUri(col.local_path))
		else
			name = col.name
		
		# if col.type in [6, 8]
		# 	fileName = col.local_path.split('/')[-1..][0]
		# 	actions.push(Element.Button('文件名', 'window.Util.clipText(\'' + fileName + '\')'))
		
		if col.type is 5
			console.log(col)
			base64 = Util.Base64.encode(JSON.stringify(col))
			command = 'python xuehai.py export ykt ' + base64
			actions.push(Element.Button('导出命令', 'window.Util.clipText(\'' + command + '\')'))

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
	html: Element.Table(['#', '名称', '创建时间', '下载时间', '用户', '类型'], table)

Router.register '/smartclassstu/slideViewer', ({ params })->
	path = "/xuehai/#{params.school}/filebases/com.xh.smartclassstu/#{params.student}/ztktv4_resource/#{params.class}/ppt/#{params.file}/index.html"
	$iframe = null
	$window = null

	updateShape = ->
		$iframe.height($iframe.width() / 4 * 3)
	
	slideSimulateClick = (times) ->
		for _ in [1..times]
			if $window.K.tl and $window.K.tl["sp-1"] and -1 != $window.K.tl["sp-1"].bj
				$window.K.tl["sp-1"].bu()
			if $window.K.tl and $window.K.tl["sp-1"] and $window.K.tl["sp-1"].ak != $window.K.tl["sp-1"].au.length
				$window.K.tl["sp-1"].dG($window.K.tl["sp-1"])
			else
				$window.bE($window.aJ.ak + 1)
		return $window._XH.actionList[$window._XH.actionList.length - 1]

	slideJumpToPage = (page) ->
		$window.bE(page - 1)

	main = ->
		window.t = $window
		window.tm = main
		console.log('[slide-viewer] main', $window._XH.actionList)
		lastStatus = null
		while true
			currentStatus = slideSimulateClick(20).slice(0, -1)
			console.log('[slide-viewer]', lastStatus, currentStatus)
			if lastStatus and lastStatus[0] == currentStatus[0] and lastStatus[1] == currentStatus[1] and lastStatus[2] == currentStatus[2] and lastStatus[3] == currentStatus[3]
				break
			else
				lastStatus = currentStatus

	title: '幻灯片 ' + params.file
	html: "<iframe id=\"slide-iframe\" src=\"#{path}\" style=\"width:100%\">Your browser does not support iframes.</iframe><div id=\"slides\"></div>"
	onLoad: ->
		$iframe = $('#slide-iframe')
		$window = $iframe[0].contentWindow
		updateShape()
		identifier = setInterval () ->
			if $window.K and $window.K.tl and $window._XH and $window._XH.actionList and $window._XH.actionList.length == 1
				console.log('[slide-viewer] loaded')
				clearInterval(identifier)
				main()
		, 500
		console.log('slide iframe', $iframe)
	onWindowResize: ->
		updateShape()