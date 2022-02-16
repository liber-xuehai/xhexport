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

	Button: (text, onclick='') ->
		'<button onclick="' + onclick.replace('"', '&quot;') + '">' + text + '</button>'
