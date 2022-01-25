FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
ENV VAI_ROOT=/opt/vitis_ai
ENV VAI_HOME=/vitis_ai_home
ARG VERSION
ENV VERSION=$VERSION


# xilinx build folders
RUN chmod 1777 /tmp \
    && mkdir /scratch \
    && chmod 1777 /scratch

RUN apt-get update -y > /dev/null \
    && apt-get install -y --no-install-recommends \
    apt-transport-https \
    autoconf \
    automake \
    bc \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    g++ \
    gdb \
    git \
    gnupg \
    locales \
    libboost-all-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libjson-c-dev \
    libjsoncpp-dev \
    libssl-dev \
    libtool \
    libunwind-dev \
    make \
    openssh-client \
    openssl \
    software-properties-common \
    sudo \
    tree \
    unzip \
    vim \
    nano \
    wget \
    yasm \
    zstd \
    ffmpeg \
    > /dev/null

# Tools for building vitis-ai-library in the docker container
RUN apt-get install -y \
    libavcodec-dev \
    libavformat-dev \
    libeigen3-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgtest-dev \
    libgtk-3-dev \
    libgtk2.0-dev \
    libhdf5-dev \
    libjpeg-dev \
    libopenexr-dev \
    libpng-dev \
    libswscale-dev \
    libtiff-dev \
    libwebp-dev \
    opencl-clhpp-headers \
    opencl-headers \
    pocl-opencl-icd \
    rpm \
    > /dev/null

# gcc8 and 9
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get install -y gcc-8 g++-8 gcc-9 g++-9 > /dev/null \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-8 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-8 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-7

# cmake
RUN cd /tmp && wget -q -O cmake.sh https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh \
    && echo y | /bin/bash ./cmake.sh --prefix=/usr/local --exclude-subdir > /dev/null \
    && cmake --version \
    && rm -fr /tmp/*

# glog 0.4.0
RUN cd /tmp && wget -q -O glog.0.4.0.tar.gz https://codeload.github.com/google/glog/tar.gz/v0.4.0 \
    && tar -xf glog.0.4.0.tar.gz \
    && cd glog-0.4.0 \
    && ./autogen.sh > /dev/null \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON .. > /dev/null \
    && make -j > /dev/null \
    && make install > /dev/null \
    && rm -fr /tmp/*

# gflags 2.2.2
RUN cd /tmp; wget -q -O gflags.tar.gz https://github.com/gflags/gflags/archive/v2.2.2.tar.gz \
    && tar xvf gflags.tar.gz \
    && cd gflags-2.2.2 \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON .. \
    && make -j \
    && make install \
    && rm -fr /tmp/*

# libjson
RUN cd /tmp; wget -q http://launchpadlibrarian.net/436533799/libjson-c4_0.13.1+dfsg-4_amd64.deb \
    && dpkg -i ./libjson-c4_0.13.1+dfsg-4_amd64.deb \
    && rm -fr /tmp/*

# gosu 1.12
RUN curl -sSkLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu

# Install XRT and XRM
RUN cd /tmp \
    && wget -q -O xrt.deb https://www.xilinx.com/bin/public/openDownload?filename=xrt_202110.2.11.648_18.04-amd64-xrt.deb \
    && wget -q -O xrm.deb https://www.xilinx.com/bin/public/openDownload?filename=xrm_202110.1.2.1539_18.04-x86_64.deb \
    && apt-get install -y ./xrt.deb ./xrm.deb > /dev/null \
    && rm -fr /tmp/*

# Install VART
RUN cd /tmp \
    && wget -q -O libunilog.deb https://www.xilinx.com/bin/public/openDownload?filename=libunilog_1.4.1-r82_amd64.deb \
    && wget -q -O libtarget-factory.deb https://www.xilinx.com/bin/public/openDownload?filename=libtarget-factory_1.4.1-r85_amd64.deb \
    && wget -q -O libxir.deb https://www.xilinx.com/bin/public/openDownload?filename=libxir_1.4.1-r91_amd64.deb \
    && wget -q -O libvart.deb https://www.xilinx.com/bin/public/openDownload?filename=libvart_1.4.1-r130_amd64.deb \
    && wget -q -O libvitis_ai_library.deb https://www.xilinx.com/bin/public/openDownload?filename=libvitis_ai_library_1.4.1-r114_amd64.deb \
    && wget -q -O librt-engine.deb https://www.xilinx.com/bin/public/openDownload?filename=librt-engine_1.4.1-r195_amd64.deb \
    && wget -q -O aks.deb https://www.xilinx.com/bin/public/openDownload?filename=aks_1.4.1-r78_amd64.deb \
    && apt-get install -y --no-install-recommends /tmp/*.deb > /dev/null \
    && rm -rf /tmp/* \
    && ldconfig

COPY docker/bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
RUN groupadd vitis-ai-group \
    && useradd --shell /bin/bash -c '' -m -g vitis-ai-group vitis-ai-user \
    && passwd -d vitis-ai-user \
    && usermod -aG sudo vitis-ai-user \
    && echo 'ALL ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo 'Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vitis_ai/conda/bin"' >> /etc/sudoers \
    && echo ". $VAI_ROOT/conda/etc/profile.d/conda.sh" >> ~vitis-ai-user/.bashrc \
    && echo "conda activate base" >> ~vitis-ai-user/.bashrc \
    && echo "export VERSION=${VERSION}" >> ~vitis-ai-user/.bashrc \
    && cat ~vitis-ai-user/.bashrc >> /root/.bashrc \
    && echo $VERSION > /etc/VERSION.txt \
    && echo 'export PS1="\[\e[91m\]Vitis-AI\[\e[m\] \w > "' >> ~vitis-ai-user/.bashrc \
    && mkdir -p ${VAI_ROOT} \
    && chown -R vitis-ai-user:vitis-ai-group ${VAI_ROOT} \
    && mkdir /etc/conda \
    && touch /etc/conda/condarc \
    && chmod 777 /etc/conda/condarc \
    && mkdir -p ${VAI_ROOT}/scripts \
    && chmod 775 ${VAI_ROOT}/scripts

# Set up Anaconda
USER vitis-ai-user
RUN cd /tmp && wget -q -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && /bin/bash ./miniconda.sh -b -p $VAI_ROOT/conda > /dev/null \
    && echo "channels:" >> /etc/conda/condarc \
    && echo "  - defaults" >> /etc/conda/condarc \
    && echo "  - conda-forge" >> /etc/conda/condarc \
    && echo "  - file:///scratch/conda-channel" >> /etc/conda/condarc \
    && sudo ln -s $VAI_ROOT/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && rm -fr $VAI_ROOT/conda/pkgs/* \
    && rm -fr /tmp/*

# Create conda envs
RUN cd /scratch/ && wget -q -O conda-channel.tar.gz https://www.xilinx.com/bin/public/openDownload?filename=conda-channel_1.4.1.978-01.tar.gz \
    && tar -xzf conda-channel.tar.gz \
    && . $VAI_ROOT/conda/etc/profile.d/conda.sh \
    && conda install -q conda-build \
    && conda create -n pytorch python=3.6 -y \
        && conda activate pytorch \
        # install pytorch 1.4.0 first since xilinx packages require python 1.4.0
        && conda install -q pytorch==1.4.0 torchvision==0.5.0 cpuonly -c pytorch \
        && conda install -q vaic vart rt-engine orderedset \
        && pip install ck \
        # copy architecture signatures
        && mkdir -p $VAI_ROOT/compiler \
        && sudo cp -r $CONDA_PREFIX/lib/python3.6/site-packages/vaic/arch $VAI_ROOT/compiler/arch \
        # install pytorch 1.7
        && pip uninstall -y torch torchvision \
        && pip install torch==1.7.1+cpu torchvision==0.8.2+cpu -f https://download.pytorch.org/whl/torch_stable.html \
        && pip cache purge \
        && conda deactivate \
    && rm -fr $VAI_ROOT/conda/pkgs/* \
    && rm -rf /scratch/*

# build pytorch_nndct
COPY docker/vai_q_pytorch.zip /scratch
RUN cd /scratch && unzip vai_q_pytorch.zip \
    && cd vai_q_pytorch/ \
    && . $VAI_ROOT/conda/etc/profile.d/conda.sh \
    && conda activate pytorch \
    && pip install -r requirements.txt \
    && cd pytorch_binding \
    && python setup.py bdist_wheel -d ./ \
    && pip install ./pytorch_nndct*.whl \
    && pip cache purge \
    && conda deactivate \
    && rm -fr $VAI_ROOT/conda/pkgs/* \
    && sudo rm -rf /scratch/*

USER root

RUN apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /scratch/*

ADD docker/banner.sh /etc/

