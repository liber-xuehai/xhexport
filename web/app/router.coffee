window.Router = class
	constructor: ->
		window.onhashchange = => @reload()
		@hashMap = {}

	register: (route, render) ->
		@hashMap[route] = render

	reload: ->
		if window.location.hash == ''
			window.location.hash = '#index'
			return @reload()
		location = window.location.hash.slice(1).split('/')
		found = false
		console.log '[router]', 'page', location, @hashMap

		for routeHash, render of @hashMap
			route = routeHash.split('/').slice(1)

			if route.length isnt location.length
				continue
			args = []
			for i in [0...route.length]
				if route[i] == '*'
					args.push location[i]
				else if route[i] != location[i]
					args = false
			if args is false
				continue

			found = true
			progressBar = progressJs('#progressBar').start()
			progressBar.set 16
			progressBar.autoIncrease 4, 120
			Data.current = null
			html = await render()
			$("#container").html html
			progressBar.set 96
			await Util.sleep(300)
			progressBar.end()

		if not found
			$('#container').html '404 Not Found'
