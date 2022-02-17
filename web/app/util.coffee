window.Util =
	Base64:
		encode: (string) ->
			window.btoa unescape encodeURIComponent string
		decode: (string) -> 
			decodeURIComponent escape window.atob string

	sleep: (ms) -> 
		new Promise (resolve, _) => setTimeout resolve, ms;

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
