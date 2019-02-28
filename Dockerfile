
########################################################################
########################################################################
#
#       Faustservice (remote Faust compiler) in a docker
#                 (L. Champenois & Y. Orlarey)
#
########################################################################
########################################################################

FROM grame/faustready-ubuntu-1604:004

########################################################################
# Now we can clone and compile all the Faust related git repositories
########################################################################

RUN echo "CHANGE THIS NUMBER TO FORCE REGENERATION : 004"

ADD gradle-4.6-bin.zip /opt/gradle

COPY faustservice /faustservice
RUN  make -C faustservice

COPY faust /faust
RUN  make -C /faust; \
    make -C /faust install

########################################################################
# Tune image by forcing Gradle upgrade
########################################################################
ENV GRADLE_USER_HOME=/tmp/gradle

RUN echo "process=+;" > tmp.dsp; \
    faust2android tmp.dsp; \
    faust2smartkeyb -android tmp.dsp; \
    rm tmp.apk


########################################################################
# And starts Faustservice
########################################################################
EXPOSE 80
WORKDIR /faustservice
RUN cp ./bin/dockerOSX /usr/local/bin/; \ 
    rm -rf makefiles/osx; \
    mv makefiles/dockerosx makefiles/osx; \
    rm -rf makefiles/ros makefiles/unity/all makefiles/unity/osx

CMD ./faustweb --port 80 --sessions-dir /tmp/sessions



########################################################################
# HowTo run this docker image
########################################################################
# For local tests:
#-----------------
# docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sharedfaustfolder:/tmp/sharedfaustfolder -p 80:80 grame/faustservice:latest
#
# For production:
#----------------
# docker run -d --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sharedfaustfolder:/tmp/sharedfaustfolder -p 80:80 grame/faustservice:latest
#
# Old production:
#----------------
# docker run -d --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sharedfaustfolder:/tmp/sharedfaustfolder -p 80:80 grame/faustservice-ubuntu-1604-neuf-tuned:latest
