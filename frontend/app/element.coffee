window.Element =
	Table: (thead, tbody) ->
		html = '<table><thead><tr>'
		for row in thead
			html += '<th>' + row + '</th>'
		html += '</tr></thead><tbody>'
		for col in tbody
			html += '<tr>'
			for row in col
				html += '<td>' + row + '</td>'
			html += '</tr>'
		html += '</tbody></table>'

	Link: (text, href, params = {}) ->
		if params != {}
			href += '?' + Object.entries(params).map((x) => (x[0] + '=' + x[1])).join('&')
		'<a href="' + href + '"' + '>' + text + '</a>'

	LinkButton: (text, href) ->
		'<a class="button" href="' + href + '"' + '>' + text + '</a>'

	NewPageLinkButton: (text, href) ->
		'<a class="button" href="' + href + '"' + ' target="_blank">' + text + '</a>'

	Button: (text, onclick='') ->
		'<button class="button" onclick="' + onclick.replace('"', '&quot;') + '">' + text + '</button>'