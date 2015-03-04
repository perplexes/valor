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
	sudo boot2docker down

	sudo VBoxManage modifyvm "boot2docker-vm" --natpf1 delete tcp-port8000;
	sudo VBoxManage modifyvm "boot2docker-vm" --natpf1 delete udp-port8000;
	sudo VBoxManage modifyvm "boot2docker-vm" --natpf1 delete tcp-port8080;
	sudo VBoxManage modifyvm "boot2docker-vm" --natpf1 delete udp-port8080;

	sudo boot2docker init
	sudo boot2docker up
	$(sudo boot2docker shellinit)
	docker build -t "valor" .
	docker run -i -t -p 8000:8000 -p 8080:8080 valor
	open http://`sudo boot2docker ip`:8000
