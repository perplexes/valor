web:
	node_modules/http-server/bin/http-server -p 8000

# To compile the MP server
watch:
#	coffee --watch --map --bare --compile --output lib/ src/
	node_modules/coffee-script/bin/coffee --watch --bare --compile --output lib/ src/

server:
	node lib/Server.js

client:
	node node_modules/watchify/bin/cmd.js -v --debug -t coffeeify --extension=".coffee" src/Client.coffee -o Subspace.js

all:
	node_modules/norman/bin/norman