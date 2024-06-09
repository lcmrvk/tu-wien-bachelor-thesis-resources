# Original code from https://github.com/Jozott00/cacao-jvm-dev-setup/blob/master/dockerfile
# with changes done by https://github.com/lcmrvk

# Notes:
# - creating images in SPECJVM2008 doesn't work because:
#   - graphics libraries are missing (solved by installing libgtk2.0-dev, xvfb)
#   - even with the above though a different error is caused when images are
#     requested to be compressed, GNU Classpath methods throws a UnsupportedOperationException
#       - when run like 'Xvfb :1& ; DISPLAY=:1 cacao -jar SPECjvm2008.jar ...' the above issue
#         dissapears, however others pop up
#   - despite the above, the raw data is written to an xml file and the SPECJVM2008
#     jar file can be used to only create the images out of that recorded data
#
# - configure GNU Classpath with:
#   - ./configure --disable-plugin --disable-gconf-peer --disable-gjdoc CFLAGS="-Wno-error=stringop-truncation"
# - Compile GNU Classpath with with
#   - make CFLAGS='-Wno-deprecated-declarations -Wno-cast-function-type'
# - ulimit -f <n> has to be executed to avoid getting an OutOfMemory exception
#   - for some benchmarks a value of at least 100000 was required
# - the parameter -Xmx worked well with up to 768m, 1g already threw a OutOfMemory exception
# - Useful links:
#   - https://gist.github.com/deeso/b3b32922686ec3d96827
#   - https://savannah.gnu.org/git/?group=classpath
#   - https://www.gnu.org/software/classpath/

FROM ubuntu:18.04

RUN apt update \
    && apt-get install -y \
    git \
    wget \
    unzip \
    libtool \
    autoconf \
    automake \
    build-essential \
    gettext \
    binutils-dev \
    libiberty-dev \
    fastjar \
    zlib1g-dev \
    software-properties-common \
    apt-transport-https \
    locales \
    vim \
    gdb \
    doxygen

# gcc 9
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get -y install gcc-9 g++-9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9 \
    && update-alternatives --config gcc

# zulu7-jdk
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ARG ZULU_REPO_VER=1.0.0-2
RUN locale-gen en_US.UTF-8 \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9 \
    && wget https://cdn.azul.com/zulu/bin/zulu-repo_${ZULU_REPO_VER}_all.deb \
    && apt-get -y install ./zulu-repo_${ZULU_REPO_VER}_all.deb \
    && apt-get update \
    && apt-get -y install zulu7-jdk zulu7-src

ENV JAVA_HOME=/usr/lib/jvm/zulu7-ca-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /usr/share/java

RUN wget -O junit4.jar https://repo1.maven.org/maven2/junit/junit/4.12/junit-4.12.jar
RUN wget -O hamcrest.jar https://repo1.maven.org/maven2/org/hamcrest/hamcrest-all/1.3/hamcrest-all-1.3.jar
RUN wget http://ufpr.dl.sourceforge.net/project/jasmin/jasmin/jasmin-2.4/jasmin-2.4.zip \
    && unzip jasmin-2.4.zip jasmin-2.4/jasmin.jar \
    && mv jasmin-2.4/jasmin.jar jasmin-sable.jar \
    && rm -rf jasmin-2.4 jasmin-2.4.zip

RUN mkdir -p /code/
WORKDIR /code/

RUN wget -O - ftp://ftp.gnu.org/gnu/classpath/classpath-0.99.tar.gz | tar -xz
RUN cd classpath-0.99 \
    && sh autogen.sh \
    && ./configure --disable-plugin --disable-gtk-peer --disable-gconf-peer --disable-gjdoc CFLAGS="-Wno-error=stringop-truncation" \
    && make install CFLAGS='-Wno-deprecated-declarations -Wno-cast-function-type'

RUN git clone https://bitbucket.org/cacaovm/cacao.git
RUN cd /code/cacao \
    && bash autogen.sh \
    && mkdir -p /code/cacao-build \
    && cd /code/cacao-build \
    && bash ../cacao/configure \
    --enable-debug \
    --enable-logging \
    --with-java-runtime-library=gnuclasspath \
    --with-java-runtime-library-prefix=/usr/local/classpath \
    --with-junit-jar=/usr/share/java/junit4.jar:/usr/share/java/hamcrest.jar \
    && make \
    && make check \
    && make install

ENV LD_LIBRARY_PATH="/code/cacao-build/src/cacao/.libs:$LD_LIBRARY_PATH"
ENV PATH="/code/cacao-build/src/cacao:$PATH"

ENTRYPOINT [ "bash" ]
