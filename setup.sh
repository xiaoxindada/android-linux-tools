#!/bin/bash

LOCALDIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
cd $LOCALDIR

# Whether uses mirror for pip
USE_MIRROR_FOR_PIP=true
# Python pip mirror link
PIP_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/

dependency_install() {
    sudo apt install -y p7zip curl wget unace unrar zip unzip p7zip-full p7zip-rar squashfs-tools aria2 selinux-utils
}

python_install() {
    echo "Install python pip and python3 pip3..."
    sudo apt-get --purge remove -y python3-pip
    sudo apt install python aptitude -y
    sudo aptitude install python-dev -y
    sudo add-apt-repository universe
    sudo python get-pip.py
    sudo apt install python3 python3-pip -y
}

pip_module_install() {
    if [[ "$USE_MIRROR_FOR_PIP" == "true" ]]; then
        sudo pip install backports.lzma pycryptodome pycrypto -i $PIP_MIRROR
        sudo pip3 install backports.lzma pycryptodome pycrypto -i $PIP_MIRROR
    elif [[ "$USE_MIRROR_FOR_PIP" == "false" ]]; then
        sudo pip install backports.lzma pycryptodome pycrypto
        sudo pip3 install backports.lzma pycryptodome pycrypto
    fi

    if [[ "$USE_MIRROR_FOR_PIP" == "true" ]]; then
        for requirements_list in $(find $LOCALDIR -type f | grep "requirements.txt"); do
            sudo pip install -r $requirements_list -i $PIP_MIRROR
            sudo pip3 install -r $requirements_list -i $PIP_MIRROR
        done
    elif [[ "$USE_MIRROR_FOR_PIP" == "false" ]]; then
        for requirements_list in $(find $LOCALDIR -type f | grep "requirements.txt"); do
            sudo pip install -r $requirements_list
            sudo pip3 install -r $requirements_list
        done
    fi
}
