#!/bin/bash

# End-to-end set-up script template

# Install basic build requirements.
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-dev
sudo apt-get install -y python3-pip
sudo python3 -m pip install --upgrade pip
sudo apt-get install -y gcc build-essential

# Install HTTP Server
sudo apt-get install -y apache2 apache2-dev
# Install the python 3 version of mod-WSGI for apache2
sudo apt-get install libapache2-mod-wsgi-py3

# Make directory for the QAS and set (temporary) permissions
# We mainly set these permissions now so that we do not have to run git with sudo
sudo mkdir /var/www/example_app
sudo chown $(whoami) /var/www/example_app
sudo chgrp $(whoami) /var/www/example_app

# clone QAS app into example_app directory
git clone -b dev https://github.com/bejphil/example_app.git /var/www/example_app/
# Install the rest of the requirements and the QAS itself
sudo python3 -m pip install /var/www/example_app/

# Make directories for WSGI scripts and the QAS
sudo mkdir /var/www/wsgi_scripts

# Copy WSGI script for the QAS
sudo cp /var/www/example_app/apache2_files/example_app.wsgi /var/www/wsgi_scripts

# Make directory for apache2 logs
mkdir /var/www/example_app/logs

# Set permissions for QAS directory
sudo chown -R www-data  /var/www
sudo chgrp -R www-data  /var/www
sudo chmod -R 755  /var/www
sudo chmod g+s  /var/www

# Set permissions for WSGI directory
sudo chmod -R 755 /var/www/wsgi_scripts

# Add QAS .conf file to apache2's sites-available
sudo cp /var/www/example_app/apache2_files/app.conf /etc/apache2/sites-available
# Disable default site
sudo a2dissite 000-default
# Enable Librarian QAS site
sudo a2ensite app
# Reload apache2
sudo service apache2 restart
