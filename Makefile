build:
	docker build -t grame/faustservicecloud:latest .

test:
	docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sharedfaustfolder:/tmp/sharedfaustfolder -p 80:80 grame/faustservicecloud:latest

update:
	git submodule update --init --recursive

updatefaust:
	git -C faust checkout master-dev
	git -C faust pull
	
updatefaustservice:
	git -C faustservice checkout server
	git -C faustservice pull
