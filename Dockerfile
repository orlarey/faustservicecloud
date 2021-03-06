
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
# the environment below is used by the osx cross compiler
ENV UNATTENDED=1
ENV FORCERECOMPILE=002
ENV CLANG_VERSION=7.0.0
ENV MACOSX_DEPLOYMENT_TARGET=10.11
ENV PATH="${PATH}:/osxcross/bin:/osxcross/compiler/target/bin"
########################################################################


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
# Install OSX cross compilation
########################################################################
RUN		apt-get update
RUN 	mkdir osxcross
WORKDIR /osxcross
RUN 	git clone --depth 1 https://github.com/tpoechtrager/osxcross.git compiler
WORKDIR /osxcross/compiler
RUN 	sh tools/get_dependencies.sh
COPY   	faust-crossosx/MacOSX10.11.sdk.tar.xz tarballs/
RUN 	./build.sh

RUN echo "CHANGE THIS NUMBER TO FORCE CROSS OSX REGENERATION : 003"
WORKDIR /osxcross
COPY   	faust-crossosx/Qt5.9.1	/osxcross/Qt5.9.1 
COPY   	faust-crossosx/sdks 	/osxcross/sdks
COPY   	faust-crossosx/scripts	/osxcross/scripts
COPY   	faust-crossosx/tests 	/osxcross/tests
RUN		ln -s Qt5.9.1 Qt && \
    sh scripts/install.sh && \
    ln -s /usr/include/boost compiler/target/SDK/MacOSX10.11.sdk/usr/include/


########################################################################
# And starts Faustservice
########################################################################
EXPOSE 80
WORKDIR /faustservice
RUN cp ./bin/dockerOSX /usr/local/bin/; \ 
    rm -rf makefiles/osx; \
    mv makefiles/crossosx makefiles/osx; \
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
