#------------------------------------------------------------
#----To build: podman build -t vampire:version_number_here .

FROM ubuntu-arc

#----Clone repository
RUN git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/vprover/vampire.git
#----Set working directory to cloned sources directory
WORKDIR vampire

#----Build Z3 
RUN mkdir -p z3/build \
    && cd z3/build \
    && cmake .. -DZ3_BUILD_LIBZ3_SHARED=FALSE -DZ3_SINGLE_THREADED=1 -DCMAKE_BUILD_TYPE=Release \
    && make

#----Build Vampire
WORKDIR /vampire
RUN mkdir -p build \
    && cd build \
    && cmake /vampire -DBUILD_SHARED_LIBS=0 \
    && make \
    && cp vampire /artifacts/vampire \
    && cd / \
    && rm -rf build vampire

#----Build Vampire HO
RUN git clone --branch ahmed-new-hol --depth 1 --recurse-submodules --shallow-submodules https://github.com/vprover/vampire.git
WORKDIR /vampire
RUN mkdir -p build \
    && cd build \
    && cmake /vampire -DCMAKE_BUILD_HOL=On -DCMAKE_DISABLE_FIND_PACKAGE_Z3=ON \
    && make vampire \
    && cp bin/vampire* /artifacts/vampire-ho \
    && cd / \
    && rm -rf build vampire

#----Add run_system script 
ADD run_system /artifacts/

#------------------------------------------------------------
