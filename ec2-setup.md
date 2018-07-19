# Setting up the Example App on EC2

## Basic AWS set-up

### Start AWS EC2 instance

From the EC2 Management Console choose `Launch Instance`.
At the Choose AMI screen choose `Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-835b4efa`
or similar.
Choose whatever instance type is appropriate and launch it.
You will be prompted to create a new key pair for the AWS instance -- create one
and copy the `*.pem` file to local machine. This is the key-pair that will be used
to login to the default `ubuntu` user.

### Set up an AWS security group

Set up an AWS security group with with inbound and outbound permission for
SSH ( port `22`) and HTTP(S) ( ports `80` and `443`). Assign the instance created
in the previous step to this security group.

### Setup initial Admin User

```shell
#Log into EC2 instance as default user `ubuntu`.

sudo apt-get update
sudo apt-get upgrade
sudo adduser $USERNAME #Create a new user to replace default `ubuntu` user

#Type password and credentials for new user

sudo adduser $USERNAME sudo #Give new user sudo privileges
sudo su $USERNAME #Login into new user so that subsequent privileges will be set correctly.
mkdir .ssh
chmod 700 ./.ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
```

Copy public key for new user into `.ssh/authorized_keys`

The new user, `$USERNAME` should now be able to login using ssh. At this point it
is a good idea to remove the default user `ubuntu` with `userdel -r ubuntu`.

Note that all commands later in the tutorial are assumed to be performed by `$USERNAME`.

### Automatic set-up

The provided end-to-end provisioning script `app_setup.sh` included in the top level package directory is the easiest way to deploy the example app. It is designed to
run on a bare Ubuntu 16.04 instance, and will handle installing the retrieval tool
along with all web infrastructure dependencies.

To use the script simply copy `app_setup.sh` onto the bare system and
execute it as a user with `sudo` privileges. Once the script has completed
successfully the example app will be ready to receive API calls.

### Manual set-up

Although the provision script is the easiest way to get up-and-running it may
sometimes be necessary to install all, or part of the app
manually. The next section details the steps required to perform each piece of
the installation process.


### Install Dependencies

``` shell
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
```

### Install the Database Retrieval tool

``` shell
# Make directory for the QAS and set (temporary) permissions
# We mainly set these permissions now so that we do not have to run git with sudo
sudo mkdir /var/www/example_app
sudo chown $(whoami) /var/www/example_app
sudo chgrp $(whoami) /var/www/example_app

# clone app from GitHub into app directory
git clone -b dev https://github.com/bejphil/example_app.git /var/www/example_app/
# Install the rest of the requirements and the app itself
sudo python3 -m pip install /var/www/example_app/
```

### Set-up apache2

```shell
# Make directories for WSGI scripts and the QAS
sudo mkdir /var/www/wsgi_scripts

# Copy WSGI script for the app
sudo cp /var/www/app/apache2_files/app.wsgi /var/www/wsgi_scripts

# Make directory for apache2 logs
mkdir /var/www/app/logs

# Set permissions for the app directory
sudo chown -R www-data  /var/www
sudo chgrp -R www-data  /var/www
sudo chmod -R 755  /var/www
sudo chmod g+s  /var/www

# Set permissions for WSGI directory
sudo chmod -R 755 /var/www/wsgi_scripts

# Add app .conf file to apache2's sites-available
sudo cp /var/www/app/apache2_files/app.conf /etc/apache2/sites-available
# Disable default site
sudo a2dissite 000-default
# Enable Librarian QAS site
sudo a2ensite app
# Reload apache2
sudo service apache2 restart
```

The example app should now be set-up and ready to go.

### ( Optional ) Setup SSL certificates through Let's Encrypt

``` shell
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-apache
sudo certbot --apache -d $SITE_URL

#Select `example_app.conf` when prompted
sudo crontab -e

#Add the following line to crontab
15 3 * * * /usr/bin/certbot renew --quiet
#to enable automatic renewal of certificates.
```
