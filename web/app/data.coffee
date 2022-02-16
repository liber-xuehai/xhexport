window.Data =
	current: null

	fetch: (path) ->
		path = '/data' + path
		new Promise (resolve, reject) =>
			$.get(path).then(resolve).catch(reject)