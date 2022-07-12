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
	path = if params.src then params.src else "/xuehai/#{params.school}/filebases/com.xh.smartclassstu/#{params.student}/ztktv4_resource/#{params.class}/ppt/#{params.file}/index.html"
	pathDir = path.slice(0, -11)
	console.log(pathDir)
	$slides = null
	$iframe = null
	$window = null
	width = 720
	height = 540

	updateShape = ->
		$iframe.height($iframe.width() / width * height)
		if $slides and $slides.children().length
			contentWidth = $slides.width() - 2
			contentScale = contentWidth / width
			contentHeight = contentScale * height
			$slides.children().width(width)
			$slides.children().height(height)
			$slides.children().css('zoom', contentScale)
	
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
		console.log('[slide-viewer] main', $window._XH.actionList)

		width = parseInt($window.document.getElementById('main').style.width.slice(0, -2))
		height = parseInt($window.document.getElementById('main').style.height.slice(0, -2))
		
		lastStatus = null
		while true
			currentStatus = slideSimulateClick(20).slice(0, -1)
			console.log('[slide-viewer]', lastStatus, currentStatus)
			if lastStatus and lastStatus[0] == currentStatus[0] and lastStatus[1] == currentStatus[1] and lastStatus[2] == currentStatus[2] and lastStatus[3] == currentStatus[3]
				break
			else
				lastStatus = currentStatus
		totalPage = lastStatus[0]

		familySet = []
		for page in [1..totalPage]
			slideJumpToPage(page)
			html = $window.document.querySelector("#root>#main>#s#{page - 1}").innerHTML
			html = html.replace(/ src="(.*?)"/g, ' src="' + pathDir + '/$1"')
			$slides.append("<article id=\"slide-page-#{page}\">#{html}</article>")
			if html.match(/fnt\d+/)
				familySet = Util.unique([...familySet, ...html.match(/fnt\d+/g)])
				console.log(familySet, ...html.match(/fnt\d+/g))

		fontStyle = ''
		for family in familySet
			fontStyle += "@font-face { font-family: #{family}; src: url(#{pathDir}/data/#{family}.woff); }\n"
		# console.log('[slide-viewer]', 'font-style', familySet, fontStyle)
		$('#scoped-style').html($('#scoped-style').html() + fontStyle)

		updateShape()
		$('#slides-loading').hide()

	title: '幻灯片 ' + params.file
	html: "
		<div id=\"slide-viewer\">
			<div id=\"slides-loading\">Slide is loading...</div>
			<div id=\"slides\"></div>
			<iframe id=\"slide-iframe\" src=\"#{path}\" style=\"width:100%\">Your browser does not support iframes.</iframe>
		</div>
	"
	style: "
		#slide-viewer { max-width: 802px; margin: auto; }
		#slide-iframe { display: none; }
		#slides>article { position: relative; overflow: hidden; border: 1px solid black; }
		#slides>article:not(:first-child) { border-top: none; }
		/* default style */
		#slides {
			-webkit-text-size-adjust: auto;
			font-family: \"Helvetica Neue\", Helvetica, Arial, simsun, sans-serif;
			line-height: 150%;
			font-size: 16px;
		}
		#slides img { position: absolute; left: 0px; right: 0px; }
		#slides span { border-style: solid; position: absolute; white-space: nowrap; border: 0; -webkit-text-size-adjust: auto; }
		#slides div, #slides iframe, #slides svg, #slides embed, #slides .sub { position: absolute; }
		#slides .bul { font-family: fnt0; }
		#slides video { object-fit: fill; }
		#slides .sub1 { position: static; }
		#slides .statitle { position: relative; }
		/* #slides .uf { background: url(ud.gif) repeat-x 100% 100%; } ? what's this */
		/* (and rich media style is not supported yet) */
		/* fonts */
	" 
	onLoad: ->
		$slides = $('#slides')
		$iframe = $('#slide-iframe')
		$window = $iframe[0].contentWindow
		updateShape()
		identifier = setInterval(() ->
			if $window.K and $window.K.tl and $window._XH and $window._XH.actionList and $window._XH.actionList.length == 1
				console.log('[slide-viewer] loaded')
				clearInterval(identifier)
				main()
		, 500)
		console.log('slide iframe', $iframe)
	onWindowResize: ->
		updateShape()