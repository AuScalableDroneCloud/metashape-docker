#Example from: https://www.agisoft.com/forum/index.php?topic=12255.0
#TODO: activate license and deactivate on shutdown
#      mount shared drive and use for nodes

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
RUN adduser metashape
USER metashape

ENV METASHAPE_VER=1_7_1 \
    METASHAPE_WHEEL=Metashape-1.7.1-cp35.cp36.cp37.cp38-abi3-linux_x86_64.whl

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

# expose ports for licensing (only for floating lic)
#EXPOSE 5053 5147

