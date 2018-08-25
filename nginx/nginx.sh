#!/bin/bash


ETC=/etc/nginx/sites-available/
conf_name=sec_nginx
git_root="$(pwd)/"
nginx_dir="$(pwd)/"
conf=${nginx_dir}${conf_name}
mw_dir="/var/www/html/files/MW-careful/"
files_dir="/var/www/html/files/"
iso_dir="/var/www/html/iso/"

if [ $USER != "root" ]; then
	echo "Execute script with root permissions"
	exit 1
fi
if [ $# != 2 ]; then
	echo "Call script using $0 <Path to git root>"
	exit 2
fi

git_root=$1

# copy config into /etc config directory
cp $conf $ETC

# Create link between sites available and sites enabled
ln -s ${ETC}${conf_name} /etc/nginx/sites-enabled/${conf_name}

# Create directories
mkdir -p $mw_dir
mkdir -p $iso_dir

# Change owner to labadmin:www-data
chown -R labadmin:www-data $files_dir
chown -R labadmin:www-data $iso_dir

# copy files into directories
cp ${nginx_dir}/files/* $files_dir
cp ${nginx_dir}/MW-careful/* $mw_dir

service nginx restart

exit 0
