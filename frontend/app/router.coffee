window.Router = new class
	constructor: ->
		window.onhashchange = => @reload()
		@hashMap = {}

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
			result = await render(...args)
			console.log(result)
			$("#container").html(result.html)
			if result.title
				$('title').html(result.title + ' - OpenXueHai')
			else
				$('title').html('OpenXueHai')
			progressBar.set(92)
			if result.onLoad
				result.onLoad($('#container'))
			await Util.sleep(300)
			progressBar.end()

		if not found
			$('#container').html('404 Not Found')
