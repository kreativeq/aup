#!/bin/sh
#
# This script file is run to provision a Vagrant VM for use in the
# trustpay/ruby implementation
#
# It is executed by vagrant, as root, from the /vagrant directory

sudo sudo apt-get -y install libmagick9-dev

sudo apt-get install -y postgresql-contrib-8.4

sudo sudo -u postgres psql -U postgres template1 --command="\i /usr/share/postgresql/8.4/contrib/uuid-ossp.sql"


sudo sudo -u postgres psql -U postgres template1 --command="create user aup password 'password' createdb createuser;"

#cd /vagrant
#sudo -u vagrant sh -c "(source /home/vagrant/.rvm/scripts/rvm && bundle install)"

echo "done"

exit 0
