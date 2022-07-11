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
			@currentPage = await render(...args)
			console.log(@currentPage)
			$("#container").html(@currentPage.html)
			if @currentPage.title
				$('head>title').html(@currentPage.title + ' - OpenXueHai')
			else
				$('head>title').html('OpenXueHai')
			progressBar.set(92)
			if @currentPage.onLoad
				@currentPage.onLoad($('#container'))
			await Util.sleep(300)
			progressBar.end()

		if not found
			$('#container').html('404 Not Found')

window.onresize = ->
	if window.Router.currentPage and window.Router.currentPage.onWindowResize
		window.Router.currentPage.onWindowResize()