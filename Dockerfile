FROM public.ecr.aws/lambda/nodejs:18

WORKDIR /madronus/build

ARG VIPS_VERSION=8.14.2
ENV VIPS_VERSION=$VIPS_VERSION
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig

RUN yum -y update && \
    yum -y groupinstall "Development Tools" && \
    yum -y install python3 libjpeg-turbo-devel libpng-devel libpng glib2-devel expat-devel nasm \
    gobject-introspection-devel && \
    pip3 install cmake meson && \
    npm i -g node-gyp

# Install libwep since image repo version is too low 
RUN git clone https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

RUN git clone https://bitbucket.org/multicoreware/x265_git.git && \
    cd x265_git && \
    cmake source && \
    make && \
    make install

RUN curl -L https://github.com/strukturag/libde265/releases/download/v1.0.11/libde265-1.0.11.tar.gz | \
    tar zx && \
    cd libde265-1.0.11 && \
    ./autogen.sh && \
    ./configure && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install


RUN curl -L https://github.com/strukturag/libheif/releases/download/v1.16.1/libheif-1.16.1.tar.gz | \
    tar zx && \
    cd libheif-1.16.1 && \
    mkdir build && \
    cd build && \
    cmake --preset=release .. && \
    make && \
    make install

RUN curl -L https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip -o ninja-linux.zip && \
    unzip ninja-linux.zip && \
    mv ninja /usr/local/bin

RUN curl -L https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz | \
    tar -xJ && \
    cd vips-${VIPS_VERSION} && \
    meson setup build && \
    cd build && \
    meson compile && \
    meson test && \
    meson install


WORKDIR ${LAMBDA_TASK_ROOT}

# Copy function code
COPY package.json .
RUN npm install --verbose --foreground-scripts
RUN pwd
COPY . .

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
# the lambda nodejs image requires this or the container will not startup
CMD [ "index.handler" ]

# building instructions
# docker build -t --progress plain sharp:test .
# need to debug? this will run all steps without cache
# docker build --progress plain --no-cache -t sharp:test .
# you can also comment out all steps except from the first step and run
# these manually on container so that you don't need to run everything over 
# and over again and can play around in the container

# running instructions
# docker rm -f stupid-container && docker run -d --name stupid-container sharp:test && docker exec -it stupid-container npm test

# one-liner to build and run 
# docker build --progress plain -t sharp:test . && docker rm -f stupid-container && docker run -d --name stupid-container sharp:test && docker exec -it stupid-container npm test
