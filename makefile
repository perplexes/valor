server:
	python -m SimpleHTTPServer

watch:
#	coffee --watch --map --bare --compile --output lib/ src/
	coffee --watch --bare --compile --output lib/ src/

client:
	watchify -v --debug -t coffeeify --extension=".coffee" src/Client.coffee -o Subspace.js