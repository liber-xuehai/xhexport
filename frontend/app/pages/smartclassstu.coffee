parseSlideUri = (uri) ->
	args = uri.split('/')
	school: args[1]
	student: args[4]
	class: args[6]
	file: args[8]

createCallbackElement = (text, callback) ->
	e = document.createElement('button')
	e.innerHTML = text
	e.onclick = callback
	return e

asyncFetchBase64 = (url) ->
	fetch(url)
		.then (response) => response.blob()
		.then (blob) => new Promise (resolve, reject) =>
			reader = new FileReader()
			reader.onloadend = () => resolve(reader.result)
			reader.onerror = reject
			reader.readAsDataURL(blob)

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
	html: $ Element.Table(['#', '名称', '创建时间', '下载时间', '用户', '类型'], table)
		.attr 'id', 'smartclassstu-list'
		.prop 'outerHTML'

Router.register '/smartclassstu/slideViewer', ({ params })->
	$slides = null
	$iframe = null
	$window = null
	width = 720
	height = 540
	counter = 0
	lastClipboard = null

	path = if params.src then params.src else "/xuehai/#{params.school}/filebases/com.xh.smartclassstu/#{params.student}/ztktv4_resource/#{params.class}/ppt/#{params.file}/index.html"
	pathDir = path.slice(0, -11)
	# if not pathDir.startsWith(location.origin)
	# 	pathDir = location.origin + pathDir

	updateShape = ->
		$iframe.height($iframe.width() / width * height)
		if $slides and $slides.children().length
			contentWidth = $slides.width() - 2
			contentScale = contentWidth / width
			contentHeight = contentScale * height
			$slides.children().width(width)
			$slides.children().height(height)
			$slides.children().css('zoom', contentScale)

	checkLoaded = ->
		if not counter
			$('#viewer-loading').hide()
		console.log('[slide-viewer] checkLoaded', "counter=#{counter}")
	
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

	exportAsHtml = ->
		'
			<!DOCTYPE html>
			<html lang="zh-Hans">
				<head>
					<meta charset="utf-8">
					<meta name="viewport" content="initial-scale=1, width=device-width">
					<title>' + document.title + '</title>
				</head>
				<style>
					* { box-sizing: border-box; }
					body { margin: 0px !important; }
					::-webkit-scrollbar { width: 5px; height: 5px; }
					::-webkit-scrollbar-thumb { border-radius: 1em; background-color: rgba(50, 50, 50, .3); }
					::-webkit-scrollbar-track { border-radius: 1em; background-color: rgba(50, 50, 50, .1); }
					#slides>article { page-break-after: always; border: none !important; }
					#slides>article:not(:first-child) { border-top: 1px solid black !important; }
					@media print { #slides>article:not(:first-child) { border-top: none !important; } }
				</style>
				<script>
					function reshape() {
						let contentWidth = window.innerWidth;
						let contentScale = contentWidth / window.slideWidth;
						let contentHeight = contentScale * window.slideHeight;
						Array.from(document.getElementById("slides").children).forEach(function (element) {
							element.style.width = contentWidth;
							element.style.height = contentHeight;
							element.style.zoom = contentScale;
						})
					}
					window.slideWidth = ' + width + ';
					window.slideHeight = ' + height + ';
					document.onload = reshape;
					window.onresize = reshape;
					let identifier = setInterval(function () { 
						if (document.getElementById("slides").children.length) {
							clearInterval(identifier);
							reshape();
						}
					}, 250);
				</script>
				<style>' + $('#scoped-style').html() + '</style>
				<body>' + $('#slides')[0].outerHTML + '</body>
			</html>
		'
		
	actionExportAsHtml = ->
		blob = new Blob([exportAsHtml()], {type: 'text/html;charset=utf-8'})
		link = URL.createObjectURL(blob)
		window.open(link, 'target', '')
	
	actionDownloadAsHtml = ->
		blob = new Blob([exportAsHtml()], {type: 'text/html;charset=utf-8'})
		element = document.createElement('a')
		url = window.URL.createObjectURL(blob)
		filename = document.title + '.html'
		element.href = url
		element.download = filename
		element.click()
		window.URL.revokeObjectURL(url)
	
	actionPrintToPdf = ->
		console.log('[slide-viewer]', pdf)
		printJS
			printable: 'slides'
			type: 'html'

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

		fonts = []
		for page in [1..totalPage]
			slideJumpToPage(page)
			html = $window.document.querySelector("#root>#main>#s#{page - 1}").innerHTML
			# html = html.replace(/ src="(.*?)"/g, ' src="' + pathDir + '/$1"')
			$slides.append("<article id=\"slide-page-#{page}\">#{html}</article>")
			if html.match(/fnt\d+/)
				fonts = Util.unique([...fonts, ...html.match(/fnt\d+/g)])

		for i in [0...fonts.length]
			counter += 1
			makeCallback = (i) ->    # 警惕 Javascript 闭包陷阱！！！
				(base64) ->
					cssCode = "@font-face { font-family: #{fonts[i]}; src: url(#{base64}) format('woff'); }\n"
					$('#scoped-style').html($('#scoped-style').html() + cssCode)
					counter -= 1
					checkLoaded()
			asyncFetchBase64("#{pathDir}/data/#{fonts[i]}.woff").then(makeCallback(i))
		
		walkBy = (element) ->
			# console.log(element.tagName, element)
			if not element
				return false
			if element.src
				url = new URL(element.src)
				element.src = pathDir + url.pathname
				console.log(element.src, url)
				if element.tagName == 'IMG'
					element.setAttribute('draggable', 'false')
					counter += 1
					console.log(element.src)
					asyncFetchBase64(element.src).then (base64) ->
						element.src = base64
						counter -= 1
						checkLoaded()
			if element.tagName == 'CANVAS' and element.style.visibility == 'hidden'
				return element.remove()
			# if element.style.height == '0px' and element.style.width == '0px'
			# 	return element.remove()
			for child in element.children
				walkBy(child)
			return true
		for page in [1..totalPage]
			walkBy(document.getElementById("slide-page-#{page}"))

		$('#viewer-action').append(createCallbackElement('Export as HTML', actionExportAsHtml))
		$('#viewer-action').append(createCallbackElement('Download as HTML', actionDownloadAsHtml))
		$('#viewer-action').append(createCallbackElement('Print to PDF', actionPrintToPdf))

		updateShape()
		checkLoaded()
	
	title: '幻灯片 ' + params.file
	html: "
		<div id=\"slide-viewer\">
			<div id=\"viewer-loading\">Slide is loading...</div>
			<div id=\"viewer-action\"></div>
			<div id=\"slides\"></div>
			<iframe id=\"slide-iframe\" src=\"#{path}\">Your browser does not support iframes.</iframe>
		</div>
	"
	style: "
		#slides>article { position: relative; overflow: hidden; border: 1px solid black; }
		#slides>article:not(:first-child) { border-top: none; }
		#slide-viewer { max-width: 802px; margin: auto; }
		#slide-iframe { display: none; width: 100%; }
		#viewer-action { margin-bottom: 5px; }
		#viewer-loading { margin-bottom: 5px; }
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
	onClipCopy: (event) ->
		text = document.getSelection().toString()
		if text and text != lastClipboard
			event.preventDefault()
			convertedText = ''
			for line in text.split(/\n{2,}/)
				if line[0].match(/\s/) and convertedText != ''
					convertedText += '\n\n'
				convertedText += line.trim()
				# console.log([line, convertedText], line.startsWith(' '), line[0].match(/\s/))
			event.clipboardData.setData('text/plain', convertedText);
			lastClipboard = convertedText
	onWindowResize: ->
		updateShape()