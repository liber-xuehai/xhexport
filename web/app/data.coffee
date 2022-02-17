window.Data =
	current: null

	fetch: (path) ->
		new Promise (resolve, reject) =>
			$.get(path).then(resolve).catch(reject)