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
	node node_modules/foreman/nf.js start

setup:
	git submodule init
	git submodule update
	npm install

# OSX only
docker:
	sudo boot2docker init
	sudo boot2docker up
	$(sudo boot2docker shellinit)
	docker build -t "valor" .
	docker run valore -p 8000:8000 -p 8080:8080
	open http://`sudo boot2docker ip`:8000
