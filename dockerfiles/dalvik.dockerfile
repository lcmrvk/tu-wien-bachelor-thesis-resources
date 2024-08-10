FROM ubuntu:14.04

# Notes:
# - to convert a .jar file into a dex file run
#   - dx --dex --output=something.dex something.jar
# - to run a workload in SpecJVM2008 run
#   - dalvikvm -cp specjvm2008.dex spec.harness.Launch -ict scimark.monte_carlo

# Useful links:

# - https://source.android.com/docs/setup/download
# - https://source.android.com/docs/setup/build/building
# - https://cs.android.com/android/platform/superproject/main/+/main:


RUN dpkg --add-architecture i386

RUN apt update
RUN apt install -y vim \
    wget \
    git \
    python \
    make \
    build-essential \
    g++-multilib \
    bison \
    xsltproc \
    zip \
    unzip \
    gperf \
    libxml2-utils \
    flex \
    libfl-dev \
    libswitch-perl \
    libc6:i386 \
    libgcc1:i386 \
    libstdc++6:i386 \
    libz1:i386

RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

RUN git config --global color.ui false

WORKDIR /opt/
COPY resources/dalvik/jdk-6u45-linux-i586.bin /opt/
RUN chmod +x ./jdk-6u45-linux-i586.bin
RUN ./jdk-6u45-linux-i586.bin

RUN update-alternatives --install /usr/bin/java java /opt/jdk1.6.0_45/bin/java 5000
RUN update-alternatives --install /usr/bin/javac javac /opt/jdk1.6.0_45/bin/javac 5000
RUN update-alternatives --install /usr/bin/javap javap /opt/jdk1.6.0_45/bin/javap 5000
RUN update-alternatives --install /usr/bin/jar jar /opt/jdk1.6.0_45/bin/jar 5000
RUN update-alternatives --install /usr/bin/javadoc javadoc /opt/jdk1.6.0_45/bin/javadoc 5000

WORKDIR /home

RUN wget https://storage.googleapis.com/git-repo-downloads/repo-1
RUN python ./repo-1 init --depth=1 -b android-4.1.1_r1 -u https://android.googlesource.com/platform/manifest

# Ocasionally some repos are missed, so re-execute a few times
RUN python ./repo-1 sync -c -j8
RUN python ./repo-1 sync -c -j8
RUN python ./repo-1 sync -c -j8
RUN python ./repo-1 sync -c -j8
RUN python ./repo-1 sync -c -j8

RUN /bin/bash -c "source build/envsetup.sh && lunch full_x86-eng && make -j8 TARGET_ARCH=x86 TARGET_ARCH_VARIANT=x86 framework services dexdump dexopt libdvm dalvikvm"

RUN mkdir /system
RUN ln -s /home/out/target/product/generic_x86/system/framework /system/framework

ENV BOOTCLASSPATH="/system/framework/core.jar:/system/framework/core-junit.jar:/system/framework/bouncycastle.jar:/system/framework/ext.jar:/system/framework/framework.jar:/system/framework/android.policy.jar:/system/framework/services.jar:/system/framework/apache-xml.jar"
ENV LD_LIBRARY_PATH="/home/out/host/linux-x86/obj/lib"

RUN mkdir -p /tmp/data/dalvik-cache/
ENV ANDROID_DATA="/tmp/data"
ENV ANDROID_ROOT="/home"

RUN ln -s /home/out/host/linux-x86/usr/ /home/usr
RUN ln -s /home/out/host/linux-x86/bin /home/bin

RUN echo "source /home/build/envsetup.sh" >> "/root/.bashrc"
RUN echo "lunch full_x86-eng" >> "/root/.bashrc"

ENTRYPOINT [ "bash" ]
