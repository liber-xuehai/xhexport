window.Router = new class
	constructor: ->
		window.onhashchange = => @reload()
		@hashMap = {}
		@currentPage = null

	register: (route, render) ->
		@hashMap[route] = render

	reload: ->
		if window.location.hash == ''
			window.location.hash = '#index'
			return @reload()
		url = new URL('http://localhost/' + window.location.hash.slice(1))
		if not url.search
			params = {}
		else
			params = JSON.parse('{"' + decodeURI(url.search.slice(1)).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}')
		location = url.pathname.split('/').slice(1)
		found = false
		console.log('[router]', location, params, @hashMap)

		for routeHash, render of @hashMap
			route = routeHash.split('/').slice(1)
			if route.length isnt location.length
				continue
			args = []
			for i in [0...route.length]
				if route[i] == '*'
					args.push(location[i])
				else if route[i] != location[i]
					args = false
					break
			if args is false
				continue
			args.push({ params })

			found = true
			progressBar = progressJs('#progressBar').start()
			progressBar.set(16)
			progressBar.autoIncrease(4, 200)
			Data.current = null

			# render
			@currentPage = await render(...args)
			console.log(@currentPage)
			
			# style
			if not @currentPage.style
				@currentPage.style = ''
			$('#scoped-style').html(@currentPage.style)
			# title
			if @currentPage.title
				$('head>title').html(@currentPage.title + ' - OpenXueHai')
			else
				$('head>title').html('OpenXueHai')
			# body
			$("#container").html(@currentPage.html)
			
			progressBar.set(92)
			if @currentPage.onLoad
				@currentPage.onLoad($('#container'))
			await Util.sleep(300)
			progressBar.end()

		if not found
			$('#container').html('404 Not Found')


window.onresize = ->
	document.getElementById('container').style['margin-top'] = (document.getElementById('header').offsetHeight + 10) + 'px';
	if window.Router.currentPage and window.Router.currentPage.onWindowResize
		window.Router.currentPage.onWindowResize()
window.onresize()
document.addEventListener 'DOMContentLoaded', window.onresize

document.addEventListener 'copy', (event) ->
	if window.Router.currentPage and window.Router.currentPage.onClipCopy
		window.Router.currentPage.onClipCopy(event)
document.addEventListener 'paste', (event) ->
	if window.Router.currentPage and window.Router.currentPage.onClipPaste
		window.Router.currentPage.onClipPaste(event)
