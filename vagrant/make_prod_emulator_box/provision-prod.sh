#!/bin/sh
#
# This script file is run to provision a Vagrant VM for use in the
# trustpay/ruby implementation
#
# It is executed by vagrant, as root, from the /vagrant directory

sudo apt-get -y install build-essential git-core curl
sudo apt-get -y install openssl libreadline6 libreadline6-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
sudo  apt-get -y install zlib1g zlib1g-dev
sudo apt-get -y install nodejs # for JS compiler
sudo apt-get install -y build-essential zlib1g-dev apache2 apache2-threaded-dev libcurl4-openssl-dev
sudo apt-get -y install postgresql-contrib-8.4


sudo adduser trustpay --disabled-password --gecos ""
sudo usermod -G www-data trustpay

#-----------------------------------------------------------------------

cat > /tmp/provision-trustpay.sh << EOF
#!/bin/bash
#
# This script is run as user trustpay, to set up the trustpay
# environment.
# It is called by provision-prod.sh

curl -L get.rvm.io | bash -s stable

echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> /home/trustpay/.bashrc
. /home/trustpay/.bashrc
. /home/trustpay/.rvm/scripts/rvm

# http_proxy=http://10.2.2.117:3128
rvm  install 1.9.3
rvm  use 1.9.3
rvm  --default use 1.9.3-p194
gem install rails -v 3.2.3

gem install passenger # Note: does not work if installed without docs

# Do not bother with apache2 module, we can run standalone for testing.
# passenger-install-apache2-module 

mkdir -p /home/trustpay/.ssh
cat /vagrant/trustpay.at.trustpay.biz.pub >> /home/trustpay/.ssh/authorized_keys

exit 0

EOF
su trustpay --login -c "bash /tmp/provision-trustpay.sh" 

#-----------------------------------------------------------------------

#bash -c 'echo "   LoadModule passenger_module /home/trustpay/.rvm/gems/ruby-1.9.3-p194/gems/passenger-3.0.15/ext/apache2/mod_passenger.so" > /etc/apache2/conf.d/passenger'
#bash -c 'echo "   PassengerRoot /home/trustpay/.rvm/gems/ruby-1.9.3-p194/gems/passenger-3.0.15" >> /etc/apache2/conf.d/passenger'
#bash -c 'echo "   PassengerRuby /home/trustpay/.rvm/wrappers/ruby-1.9.3-p194/ruby" >> /etc/apache2/conf.d/passenger'

/etc/init.d/apache2 restart

sudo sudo -u postgres psql -U postgres template1 --command="\i /usr/share/postgresql/8.4/contrib/uuid-ossp.sql"

sudo sudo -u postgres psql -U postgres template1 --command="create user trustpay password 'password' createdb createuser;"

sudo sudo -u postgres psql template1 --command="drop database trustpay_ops_production;"
sudo sudo -u postgres createdb --owner trustpay trustpay_ops_production

sudo sudo -u postgres psql template1 --command="drop database trustpay_conf_production;"
sudo sudo -u postgres createdb --owner trustpay trustpay_conf_production

sudo sudo -u postgres psql template1 --command="drop database trustpay_null_production;"
sudo sudo -u postgres createdb --owner trustpay trustpay_null_production

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

