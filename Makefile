build: 
	docker build -t grame/faustservicecloud:experimental .

test:
	docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sessions:/tmp/sessions -p 80:80 grame/faustservicecloud:experimental

debug:
	docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sessions:/tmp/sessions -p 80:80 grame/faustservicecloud:experimental /bin/bash

update: initsubmodules updatefaust updatefaustservice

initsubmodules:
	git submodule update --init --recursive

updatefaust:
	git -C faust checkout master-dev
	git -C faust pull
	
updatefaustservice:
	git -C faustservice checkout withExperimentalStopUrl
	git -C faustservice pull

help:
	@echo " 'update' : update faust and faustservice to the latest versions"
	@echo " 'build'  : builds the docker image"
	@echo " 'test'   : run the docker image"
	@echo " 'debug'  : run the docker image in bash mode"
