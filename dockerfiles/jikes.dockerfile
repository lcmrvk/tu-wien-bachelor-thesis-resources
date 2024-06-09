# Notes:
# - trying to compile Jikes while using jdk6 and jdk7 failed
#   - the reason may have been that he environment wasn't set up correctly
#   - since there was no apt-get install candidate for jdk6 and jdk7 and I had to
#     install them manually, it's likely that the enviroment setup was the cause
#     for failure
#   - jdk6 installed from https://www.oracle.com/java/technologies/javase-java-archive-javase6-downloads.html
#   - jdk7 installed from https://download.java.net/openjdk/jdk7u75/ri/jdk_ri-7u75-b13-linux-x64-18_dec_2014.tar.gz
# - the ant step that builds Jikes sometimes fails, the reported reason is that
#   it was 'unable to access file: corrupted zip file'
#   - rerunning the same exact step seems to solve the problem (this happened mutliple times)
# - the executable that is supposed be called to run Jikes is 'rvm'
# - the patchfile might need to be updated in the future if further links to
#   copy artifacts from are broken
# - Useful links:
#   - https://jikesrvm-researchers.www-124.southbury.usf.ibm.narkive.com/HkuhLany/rvm-research-regarding-benchmark-test-failed#post2
#   - https://www.cs.princeton.edu/courses/archive/fall97/cs461/jdkdocs/tooldocs/win32/classpath.html
#   - https://xtenlang.atlassian.net/browse/RVM-484

FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y \
    git \
    wget \
    gcc \
    gcc-multilib \
    g++ \
    g++-multilib \
    bison \
    automake \
    gettext \
    make \
    perl \
    ant \
    vim \
    zip \
    libgmp3-dev \
    openjdk-8-jdk \
    libtool

RUN mkdir -p /code/
WORKDIR /code

COPY resources/jikes/jikes3.1.4-ant-pgk-src.patch jikes3.1.4-ant-pgk-src.patch


RUN git clone https://github.com/JikesRVM/JikesRVM.git jikesrvm

RUN cd /code/jikesrvm \
    && git checkout 3.1.4 \
    && git apply ../jikes3.1.4-ant-pgk-src.patch \
    && ant \
    -Dtarget.name=x86_64-linux \
    -Dconfig.name=production \
    -Dgit.revision=aeb1e857fe451d1447c3342b64e5e54fbc8b0f70 \
    profiled-image \
    -Dhost.name=x86_64-linux

ENV LD_LIBRARY_PATH="/code/jikesrvm/dist/production_x86_64-linux:$LD_LIBRARY_PATH"
ENV PATH="/code/jikesrvm/dist/production_x86_64-linux:$PATH"

ENTRYPOINT [ "bash" ]
