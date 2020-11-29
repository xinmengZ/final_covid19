echo "building consumer image..................................."
cp consumer/consumer.py /vagrant/consumer
sudo docker image build -t consumer:1.0 /vagrant/consumer
sudo docker image save -o /vagrant/consumer.image  consumer:1.0
sudo gzip /vagrant/consumer.image
