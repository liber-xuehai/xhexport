window.Util =
	Date:
		format: (clock, pattern) ->
			date = new Date(clock)
			o =
				"M+": date.getMonth() + 1,
				"d+": date.getDate(),
				"h+": date.getHours(),
				"m+": date.getMinutes(),
				"s+": date.getSeconds(),
				"q+": Math.floor((date.getMonth() + 3) / 3),
				"S": date.getMilliseconds(),
			if /(y+)/.test pattern
				pattern = pattern.replace RegExp.$1, (date.getFullYear() + "").substr 4 - RegExp.$1.length
			for [k, v] in Object.entries o
				if new RegExp("(" + k + ")").test pattern
					pattern = pattern.replace RegExp.$1, if RegExp.$1.length == 1 then v else ("00" + v).substr ("" + v).length
			pattern

		toDate: (clock) ->
			Util.Date.format clock, 'yyyy/MM/dd hh:mm:ss'

		toShortDate: (clock) ->
			Util.Date.format clock, 'yy/MM/dd hh:mm'

		toChineseDate: (clock) ->
			Util.Date.format clock, 'yyyy年M月d日 hh:mm:ss'


	Base64:
		encode: (string) ->
			window.btoa unescape encodeURIComponent string
		decode: (string) -> 
			decodeURIComponent escape window.atob string


	sleep: (ms) -> 
		new Promise (resolve, _) => setTimeout resolve, ms;

	unique: (array) ->
		if not Array.isArray(array)
			throw new Error('Util.unique: is not array like object')
		array = array.sort()
		result = [array[0]]
		for i in [1...array.length]
			if array[i] != array[i - 1]
				result.push(array[i])
		return result

	clipText: (text) ->
		if navigator.clipboard
			navigator.clipboard.writeText text
		else
			textarea = document.createElement 'textarea'
			document.body.appendChild textarea
			textarea.style.position = 'fixed'
			textarea.style.clip = 'rect(0 0 0 0)'
			textarea.style.top = '10px'
			textarea.value = text
			textarea.select()
			document.execCommand 'copy', true
			document.body.removeChild textarea
