window.Element =
	parse: (element, plain) ->
		if not plain.includes('.')
			return '<' + element + '>' + plain + '</' + element + '>'
		match = plain.split('.')
		'<' + element + ' class="' + match.slice(1).join(' ') + '">' + match[0] + '</' + element + '>'

	Table: (thead, tbody) ->
		html = '<table><thead><tr>'
		for row in thead
			html += Element.parse('th', row)
		html += '</tr></thead><tbody>'
		for col in tbody
			html += '<tr>'
			for row in col
				html += '<td>' + row + '</td>'
			html += '</tr>'
		html += '</tbody></table>'

	Link: (text, href, params = {}) ->
		if Object.keys(params).length
			href += '?' + Object.entries(params).map((x) => (x[0] + '=' + x[1])).join('&')
		'<a href="' + href + '"' + '>' + text + '</a>'

	LinkButton: (text, href) ->
		'<a class="button" href="' + href + '"' + '>' + text + '</a>'

	Button: (text, onclick='') ->
		'<button class="button" onclick="' + onclick.replace('"', '&quot;') + '">' + text + '</button>'
	
	NewPageLinkButton: (text, href) ->
		'<a class="button" href="' + href + '"' + ' target="_blank">' + text + '</a>'