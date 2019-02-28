build: gradle-4.6-bin.zip
	docker build -t grame/faustservicecloud:latest .

gradle-4.6-bin.zip :
	wget https://services.gradle.org/distributions/gradle-4.6-bin.zip

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

help:
	@echo " 'update' : update faust and faustservice to the latest versions"
	@echo " 'build'  : builds the docker image"
	@echo " 'test'   : run the docker image"
