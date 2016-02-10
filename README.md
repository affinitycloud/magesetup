# MageSetup
Magento 2 setup and install script that creates a new Magento instance (via a GitHub repository containing clean Magento files), receives required user input, installs Magento 2, sets permissions and then creates an Nginx config file.

## Usage

> **Note**: Please make sure that you have added the fastcgi_backend parameter as your upstream using the required PHP-FPM version to your nginx.conf file, usually located at /etc/nginx/nginx.conf.

```
upstream fastcgi_backend {
    server unix:/var/run/php/php7.0-fpm.sock;
}
```

Ensure you have created the database required by the install before running the script.

Clone the repository on to your server where you want to run it.

`git clone git@github.com:affinitycloud/magesetup.git`

Make the `magesetup.sh` script executable.

`chmod +x magesetup/magesetup.sh`

Run the script and follow the prompts.

`bash magesetup/magesetup.sh`

## Configuration

The script will run through the entire process, accepting user input for the following:

### Server Specific Config

- site - Your Nginx site name
- siteroot - The site root of your Magento install on your server, e.g. /home/user
- configpath - The path to your Nginx config files, e.g. /etc/nginx
- repo - Your GitHub repository containing the Magento 2 core files
- domainname - The domain name of your store, e.g. example.com

### Magento 2 Installation Specific Config

- firstname
- lastname
- email
- username
- password
- dbhost - Defaults to localhost
- dbname
- dbuser
- dbpassword - Defaults to an empty string
- language
- currency
- timezone

The Magento 2 base url is automatically generated based on the domain name entered previously.