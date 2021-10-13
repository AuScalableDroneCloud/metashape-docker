#Ubuntu 18.04 with cuda, vullkan
FROM nvidia/vulkan:1.1.121

# Install pip for python3, mesa deb for metashape, nodejs
RUN apt-get update && \
    apt-get install -y python3-pip curl libglu1-mesa libgl1-mesa-glx libxi6 libsm6 libfontconfig libxrender1 libqt5x11extras5 && \
    curl https://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add - && \
    curl -L http://packages.lunarg.com/vulkan/lunarg-vulkan-bionic.list --output /etc/apt/sources.list.d/lunarg-vulkan-bionic.list && \
    apt-get update && \
    apt-get install -y vulkan-sdk && \
    rm -rf /var/lib/apt/lists/*

# add metashape user and switch to it
RUN adduser --disabled-password --gecos '' metashape
USER metashape

ENV METASHAPE_VER=1_7_5 \
    METASHAPE_WHEEL=Metashape-1.7.5-cp35.cp36.cp37.cp38-abi3-linux_x86_64.whl

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

COPY monash.lic /home/metashape/metashape-pro/

CMD ["/home/metashape/metashape-pro/metashape", "--node", "--host", "metashape.default.svc.cluster.local", "--root", "/mnt/dronedrive", "--capability", "any", "--platform", "offscreen", "--gpu_mask", "1", "--cpu_enable", "0"]

