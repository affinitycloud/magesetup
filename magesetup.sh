#!/bin/bash

# A simple bash script to Setup and Install Magento 2.
# Add more options as necessary.

read -p 'Please enter the name of your site (lowercase, one word): ' site

# Check if the user entered a site name
if [[ -z "$site" ]]; then
	echo 'You did not enter a site name. This is required.'
	exit
fi

read -p 'Please enter site root, e.g. /home/vagrant/Code on local VM: ' siteroot

# Check if the user entered a site root
if [[ -z "$siteroot" ]]; then
	echo 'You did not enter a site root. This is required.'
	exit
fi

read -p 'Please enter an Nginx config path, e.g. /etc/nginx: ' configpath

# Check if the user entered a config path
if [[ -z "$configpath" ]]; then
	echo 'You did not enter a config path. This is required.'
	exit
fi

# Build site path
sitepath="$siteroot/$site"

# Check if site directory already exists
if [[ -d "$sitepath" ]]; then
	echo 'Site already exists!'
	exit
fi

# Make site directory 
mkdir $sitepath

# Clone the Magento 2 EE Private Git repository
echo '######################################'
echo '##### CLONING THE MAGENTO 2 REPO #####'
echo '######################################'
read -p 'Please enter the name of the Magento 2 repository, for example vendor/repo: ' repo

while [[ $repo == '' ]]
do
    echo "The repository name is required!"
    read -p "Please enter the name of the Magento 2 repository, for example vendor/repo: " repo
done

git clone git@github.com:$repo.git $sitepath

# Setup install options
read -p 'Please enter domain name, e.g. example.com: ' domainname

while [[ $domainname == '' ]]
do
    echo "Domain name is required!"
    read -p "Please enter your domain name, e.g. example.com: " domainname
done

baseurl="http://$domainname/"

read -p 'Please enter your first name: ' firstname

while [[ $firstname == '' ]]
do
    echo "First name is required!"
    read -p "Please enter your first name: " firstname
done

read -p 'Please enter your last name: ' lastname

while [[ $lastname == '' ]]
do
    echo "Last name is required!"
    read -p "Please enter your last name: " lastname
done

read -p 'Please enter your admin email: ' email

while [[ $email == '' ]]
do
    echo "Admin email is required!"
    read -p "Please enter your admin email: " email
done

read -p 'Please enter your admin username: ' username

while [[ $username == '' ]]
do
    echo "Admin username is required!"
    read -p "Please enter your admin username: " username
done

read -p 'Please enter your admin password: ' password

while [[ $password == '' ]]
do
    echo "Admin password is required!"
    read -p "Please enter your admin password: " password
done

read -p 'Please enter the database host, usually 127.0.0.1 or localhost: ' dbhost

# Uncomment if required
# while [[ $dbhost == '' ]]
# do
#     echo "Database host is required!"
#     read -p "Please enter the database host: " dbhost
# done

if [ -z "$dbhost" ]; then
	dbhost='localhost'
fi

read -p 'Please enter the database name: ' dbname

while [[ $dbname == '' ]]
do
    echo 'Databse name is required!'
    read -p 'Please enter the database name: ' dbname
done

read -p 'Please enter the database user: ' dbuser

while [[ $dbuser == '' ]]
do
    echo 'A databsse user is required!'
    read -p 'Please enter the database user: ' dbuser
done

read -p 'Please enter the database user password: ' dbpassword

# Uncomment if password is a requirement
# while [[ $dbpassword == '' ]]
# do
#     echo 'A databsse password is required!'
#     read -p 'Please enter the database password: ' dbpassword
# done

read -p 'Please enter the store language: ' language

while [[ $language == '' ]]
do
    echo 'A store language is required!'
    read -p 'Please enter the store language: ' language
done

read -p 'Please enter the store currency: ' currency

while [[ $currency == '' ]]
do
    echo 'A store currency is required!'
    read -p 'Please enter the store currency: ' currency
done

read -p 'Please enter the server/store timzone, for example Europe/London: ' timezone

while [[ $timezone == '' ]]
do
    echo 'A timezone is required!'
    read -p 'Please enter the timezone: ' timezone
done

read -p 'Please enter the admin URI: ' adminuri

if [ -z "$adminuri" ]; then
    adminprefix='admin_'
    randomstring=`cat /dev/urandom | tr -dc a-za-z0-9 | fold -w 6 | head -n 1`
    randomstring="${randomstring:0:6}"
    adminuri="$adminprefix$randomstring"
fi

# Uncomment if a requirement
# while [[ $adminuri == '' ]]
# do
#     echo "An admin URI is required!"
#     read -p "Please enter the admin URI: " adminuri
# done

# Set Magento permissions
echo '#######################################'
echo '##### SETTING MAGENTO PERMISSIONS #####'
echo '#######################################'
find "$sitepath" -type d -exec chmod 770 {} \; && find "$sitepath" -type f -exec chmod 660 {} \; && chmod u+x "$sitepath/bin/magento"

# Install Magento
echo '################################'
echo '##### INSTALLING MAGENTO 2 #####'
echo '################################'
options=(
	--base-url="$baseurl"
	--admin-firstname="$firstname"
	--admin-lastname="$lastname"
	--admin-email="$email"
	--admin-user="$username"
	--admin-password="$password"
	--db-host="$dbhost"
	--db-name="$dbname"
	--db-user="$dbuser"
	--db-password="$dbpassword"
	--language="$language"
	--currency="$currency"
	--timezone="$timezone"
	--backend-frontname="$adminuri"
)

"$sitepath/bin/magento" setup:install ${options[*]}

# Create NGINX Virtual Host & Symlink Sites Available to Sites Enabled
# MAKE SURE THE fastcgi_backend VARIABLE IS SET IN /etc/nginx/nginx.conf
echo "#######################################"
echo "##### CREATING NGINX CONFIG FILE #####"
echo "#######################################"
sudo bash -c "cat > '$configpath/sites-available/$site' <<EOF
server {
    listen 80;
    server_name $domainname;
    set \\\$MAGE_ROOT $sitepath;
    set \\\$MAGE_MODE developer;
    include $sitepath/nginx.conf.sample;
}
EOF"
sudo ln -s $configpath/sites-available/$site $configpath/sites-enabled/$site

sudo service nginx restart