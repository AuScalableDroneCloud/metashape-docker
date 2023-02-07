#Ubuntu 20.04 with cuda 11.4, vullkan 1.3
#https://gitlab.com/nvidia/container-images/vulkan/-/blob/master/docker/Dockerfile.ubuntu
FROM nvidia/vulkan:1.3-470

# Install pip for python3, mesa deb for metashape, nodejs
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb && \
    rm /etc/apt/sources.list.d/cuda.list && \
    rm /etc/apt/sources.list.d/nvidia-ml.list && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get update && \
    apt-get install -y python3-pip curl libglu1-mesa libgl1-mesa-glx libxi6 libsm6 libfontconfig libxrender1 libqt5x11extras5 && \
    rm -rf /var/lib/apt/lists/*

# add metashape user and switch to it
RUN adduser --disabled-password --gecos '' metashape
USER metashape

ENV METASHAPE_VER=1_8_4 \
    METASHAPE_WHEEL=Metashape-1.8.4-cp35.cp36.cp37.cp38-abi3-linux_x86_64.whl

# set The workdir
WORKDIR /home/metashape

#Install metashape desktop and python headless
RUN curl -L https://s3-eu-west-1.amazonaws.com/download.agisoft.com/metashape-pro_${METASHAPE_VER}_amd64.tar.gz --output metashape.tar.gz && \
    tar zxf metashape.tar.gz && \
    rm metashape.tar.gz

RUN curl -LOJ https://s3-eu-west-1.amazonaws.com/download.agisoft.com/${METASHAPE_WHEEL} && \
    python3 -m pip install --user ${METASHAPE_WHEEL} && \
    rm -f ${METASHAPE_WHEEL}

ENV agisoft_LICENSE="/home/metashape/metashape-pro/" \
    QT_QPA_PLATFORM="offscreen"

ENV METASHAPE_SERVER "metashape.default.svc.cluster.local"
ENV METASHAPE_ROOT "/mnt/dronedrive"

#Create .lic file with server address and launch
CMD cd /home/metashape/metashape-pro/; echo "HOST $METASHAPE_SERVER any 5053" > server.lic ; cat server.lic; ./metashape --node --host $METASHAPE_SERVER --root $METASHAPE_ROOT --capability any --platform offscreen --gpu_mask 1 --cpu_enable 0

