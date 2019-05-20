
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

RUN echo "CHANGE THIS NUMBER TO FORCE REGENERATION : 008"

RUN wget -q https://services.gradle.org/distributions/gradle-4.10.1-bin.zip \
    && unzip gradle-4.10.1-bin.zip -d /opt/gradle \
    && rm gradle-4.10.1-bin.zip

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
    rm -rf makefiles/ros makefiles/unity/Makefile.all makefiles/unity/Makefile.android makefiles/unity/Makefile.ios makefiles/unity/Makefile.osx

CMD ./faustweb --port 80 --sessions-dir /tmp/sessions --recover-cmd /faustservice/faustweb



########################################################################
# HowTo run this docker image
########################################################################
# For local tests:
#-----------------
# docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sessions:/tmp/sessions -p 80:80 grame/faustservicecloud:latest
#
# For production:
#-----------------
# docker run -d --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/sessions:/tmp/sessions -p 80:80 grame/faustservicecloud:latest
