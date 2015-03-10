web:
	node_modules/.bin/http-server -p 8000

# To compile the MP server
watch:
#	coffee --watch --map --bare --compile --output lib/ src/
	node_modules/.bin/coffee --watch --bare --compile --output lib/ src/

server:
	node lib/Server.js

client:
	node_modules/.bin/watchify -v --debug -t coffeeify --extension=".coffee" src/Client.coffee -o Subspace.js

all:
	SUDO_USER=root node_modules/.bin/nf start

setup:
	git submodule init
	git submodule update
	npm install

# OSX only
local_docker: setup
	# TODO: see if it's up already
	sudo boot2docker down
	sudo boot2docker init
	sudo boot2docker up
	$(sudo boot2docker shellinit)
	docker build -t "valor" .
	docker run -i -t -p 8000:8000 -p 8080:8080 valor
	open http://`sudo boot2docker ip`:8000

local_docker_expose:
	sudo boot2docker ssh -L 0.0.0.0:8000:localhost:8000 -L 0.0.0.0:8080:localhost:8080
