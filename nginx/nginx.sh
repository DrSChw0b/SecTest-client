#!/bin/bash


ETC=/etc/nginx/
sites_av=${ETC}sites-available/
sites_en=${ETC}sites-enabled/
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
if [ $# != 1 ]; then
	echo "Call script using $0 <Path to git root>"
	exit 2
fi

git_root=$1
echo "git root: $git_root"

# copy config into /etc config directory
cp $conf $sites_av

# clean up sites enabled directory 
links=$(ls -al ${sites_en} | grep -e "^l" | grep -v $conf_name )
if [ ! -z "$links" ]; then
	echo "# The following links have been removed $(date):" >> ${sites_en}${conf_name}_enable-sites-change.log
	echo $links | sed 's|^\(.*\)|# \1|' >> ${sites_en}${conf_name}_enable-sites-change.log
	for file in $( ls $sites_en | grep -v $conf_name ); do
		if [ ! -z "$(echo $links | grep $file )" ]; then
			#echo "File $file is a link"
			rm ${sites_en}$file
		else
			echo "File $file is a document"
			mv ${sites_en}$file ${sites_en}${file}.disbled
		fi	
	done
fi

if [ ! -f ${sites_en}${conf_name} ] ; then
        # Create link between sites available and sites enabled
        ln -s ${sites_av}${conf_name} ${sites_en}${conf_name}
fi


# Create directories
if [ ! -d $mw_dir ] ; then
	mkdir -p $mw_dir
fi
if [ ! -d $iso_dir ] ; then
	mkdir -p $iso_dir
fi

# Change owner to labadmin:www-data
chown -R labadmin:www-data $files_dir
chown -R labadmin:www-data $iso_dir

# copy files into directories
cp ${nginx_dir}/files/* $files_dir
cp ${nginx_dir}/MW-careful/* $mw_dir

service nginx restart

exit 0
