createCallbackButton = (text, callback) ->
	e = document.createElement('button')
	e.innerHTML = text
	e.onclick = callback
	return e

Router.register '/dict', ->
	data = await Data.fetch('/data/dict/fav.json')
	table = Data.current = []
	index = 0

	window.openXuehai = window.openXuehai || {}
	window.openXuehai.dict = window.openXuehai.dict || {}
	window.openXuehai.dict.words = data.words

	for col in data.words
		if col.deleted
			continue

		table.push [
			++index,
			col.words,
			col.explains.join('<br>'),
			Util.Date.toDate(col.modifiedTime),
		]
	
	exportWords = ->
		words = openXuehai.dict.words
			.filter (col) -> not col.deleted
			.map (col) -> col.words
			.join '\n'
		Util.clipText(words)
		alert('已复制到剪贴板！')

	title: '词典'
	style: '
		#dict-actions { margin-bottom: 10px; }
	'
	html: '<div id="dict-actions"></div>' +
		$ Element.Table(['#.thead-id', '单词', '释义', '收藏时间.thead-fulltime'], table)
			.attr 'id', 'dict-list'
			.attr 'class', 'datatable'
			.prop 'outerHTML'
	onLoad: ->
		$actions = $('#dict-actions')
		$actions.append(createCallbackButton('Export', exportWords))
