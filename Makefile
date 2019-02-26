build:
	docker build -t grame/faustservicecloud:latest .

test:
	docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sessions:/tmp/sessions -p 80:80 grame/faustservicecloud:latest

update: initsubmodules updatefaust updatefaustservice

initsubmodules:
	git submodule update --init --recursive

updatefaust:
	git -C faust checkout master-dev
	git -C faust pull
	
updatefaustservice:
	git -C faustservice checkout server
	git -C faustservice pull
