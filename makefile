server:
	python -m SimpleHTTPServer

watch:
	coffee --watch --map --bare --compile --output lib/ src/
