#!/bin/bash

# Bootstrapping steps. Here we create needed directories on the guest
echo "mkdirs..................................."
mkdir -p ~/.ssh
mkdir -p ~/.ansible
mkdir -p ~/.config
mkdir -p ~/.config/openstack
export http_proxy=http://10.0.2.2:11086
export https_proxy=http://10.0.2.2:11086

echo "set proxys..................................."
echo $https_proxy
git config --global http.proxy 10.0.2.2:11086
git config --global core.proxy 10.0.2.2:11086
git config --global https.proxy 10.0.2.2:11086

#install pip3 and ansible
echo "install pip3 and ansible..................................."
sudo apt-get -y update
sudo apt-get -y install python3
sudo apt-get -y install python3-pip
sudo -H pip3 install --upgrade ansible


#install openstacksdk
echo "install openstacksdk..................................."
sudo -H pip3 install --upgrade  openstacksdk    
sudo ansible-galaxy collection install openstack.cloud   

echo "install docker..................................." 
#install docker
sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
#export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add –
curl -fsSL -o tmpkey https://download.docker.com/linux/ubuntu/gpg
sudo apt-key add tmpkey
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" 
sudo apt-get -y update
sudo apt-get -y install docker-ce

echo "building docker images..................................." 
echo "building kafka-zk images..................................." 
# should check if it exist
wget -q -O /vagrant/kafka-zk/kafka_2.13-2.4.0.tgz http://www-us.apache.org/dist/kafka/2.4.0/kafka_2.13-2.4.0.tgz
tar xfz /vagrant/kafka-zk/kafka_2.13-2.4.0.tgz -C /vagrant/kafka-zk
sudo docker image build -t kafka-zk:1.0 /vagrant/kafka-zk  
sudo docker image save -o /vagrant/kafka-zk.image  kafka-zk:1.0
sudo gzip /vagrant/kafka-zk.image
#sudo docker image load -i kafka-zk.image  in chameleon vm
echo "building couchdb images..................................." 
curl -fsSL -o /vagrant/couchdb/tmpkey https://couchdb.apache.org/repo/bintray-pubkey.asc
cp /vagrant/couchdb/tmpkey /vagrant/kafka-zk-couchdb
sudo docker image build -t couchdb:1.0 --build-arg http_proxy=http://10.0.2.2:11086 --build-arg https_proxy=http://10.0.2.2:11086 /vagrant/couchdb
sudo docker image save -o /vagrant/couchdb.image  couchdb:1.0
sudo gzip /vagrant/couchdb.image
echo "building  kafka-zk-couchdb images..................................."
sudo docker image build -t kafka-zk-couchdb:1.0 --build-arg http_proxy=http://10.0.2.2:11086 --build-arg https_proxy=http://10.0.2.2:11086 /vagrant/kafka-zk-couchdb 
sudo docker image save -o /vagrant/kafka-zk-couchdb.image  kafka-zk-couchdb:1.0
sudo gzip /vagrant/kafka-zk-couchdb.image
