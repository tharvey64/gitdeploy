#!/bin/bash

name="$1"
sshURL="$2"

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/github_rsa
cd /var/www/gitwrapper
mkdir $name
cd $name

git clone $sshURL .
git checkout $name
virtual env
source env/bin/activate
pip3 install -r /var/www/gitwrapper/requirements.txt > /var/www/pipinstall.log
DJANGO_SETTINGS_MODULE=project.settings.prod
export DJANGO_SETTINGS_MODULE=project.settings.prod
cp /var/www/local_settings.py project/
echo "BRANCH = /"$name/"" >> project/local_settings.py

python3 manage.py loaddata /var/www/django.dump
python3 manage.py collectstatic --noinput
python3 manage.py migrate
chmod 777 .
chmod 777 db.sqlite3

echo '<VirtualHost *:80>' > /etc/apache2/sites-enabled/runner.conf
echo '    Alias /static /var/www/gitwrapper/$name/staticfiles' > /etc/apache2/sites-enabled/runner.conf
echo '    WSGIDaemonProcess $name python-path=/var/www/gitwrapper/$name:/var/www/gitwrapper/$name/env/lib/python3.4/site-packages' >> /etc/apache2/sites-enabled/runner.conf
echo '    WSGIProcessGroup $name' >> /etc/apache2/sites-enabled/runner.conf
echo '    WSGIScriptAlias / /var/www/gitwrapper/$name/project/wsgi.py' >> /etc/apache2/sites-enabled/runner.conf
echo '</VirtualHost>' >> /etc/apache2/sites-enabled/runner.conf


service apache2 restart

# copy and make data base
