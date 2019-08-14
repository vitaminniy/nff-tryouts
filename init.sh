#!/bin/sh

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y git build-essential linux-headers-`uname -r` make libnuma-dev libmnl-dev libibverbs-dev libreadline-dev libpcap-dev vim

# enable hugetables
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled

# configure hugetables
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
sudo mkdir /mnt/huge
sudo mount -t hugetlbfs nodev /mnt/huge

# install go 1.12.8
mkdir go

wget https://dl.google.com/go/go1.12.8.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.12.8.linux-amd64.tar.gz
rm go1.12.8.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin

# install lua 5.3.5
wget http://www.lua.org/ftp/lua-5.3.5.tar.gz
tar -xzf lua-5.3.5.tar.gz
rm lua-5.3.5.tar.gz
cd lua-5.3.5
sudo make linux
sudo make install
cd ..
rm -rf lua-5.3.5

# install and build github.com/intel-go/nff-go (nff-go, dpdk and pktgen)
git clone --recurse-submodules http://github.com/intel-go/nff-go

cd nff-go
go mod download

export NFF_GO_NO_MLX_DRIVERS=1 # disable Mellanox drivers 

make

# install kernel drivers
sudo modprobe uio
sudo insmod dpdk/dpdk/build/kmod/igb_uio.ko

# bind adapter to driver
sudo ip link set dev eth1 down
sudo dpdk/dpdk/usertools/dpdk-devbind.py --bind=igb_uio eth1

export CGO_LDFLAGS_ALLOW=".*"