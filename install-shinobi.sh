#!/bin/tcsh
echo "Installing updates..."
pkg update -f
pkg upgrade -y
echo "Installing packages..."
pkg install -y nano ffmpeg libav x264 x265 mysql56-server node npm
echo "Enabling mysql..."
sysrc mysql_enable=yes
service mysql-server start
#Create symlink to fix missing libdl.so.1 dependency, needed later for npm commands.
ln -sf /lib/libc.so.7 /usr/lib/libdl.so.1
echo "Cloning the official Shinobi Community Edition gitlab repo..."
git clone "https://gitlab.com/Shinobi-Systems/ShinobiCE"
cd ./ShinobiCE
echo "Adding Shinobi user to database..."
mysql -h localhost -u root -e "source sql/user.sql"
echo "Shinobi database framework setup..."
mysql -h localhost -u root -e "source sql/framework.sql"
echo "Securing mysql..."
#/usr/local/bin/mysql_secure_installation
#mysql -h localhost -u root -e "source sql/secure_mysql.sq"
npm i npm -g
#There are some errors in here that I don't want you to see. Redirecting to dev null :D
npm install --unsafe-perm > & /dev/null
npm audit fix --unsafe-perm > & /dev/null
npm install pm2 -g
cp conf.sample.json conf.json
cp super.sample.json super.json
pm2 start camera.js
pm2 start cron.js
pm2 save
pm2 list
pm2 startup rcd
echo "login at http://THIS_JAIL_IP:8080/super"
echo "admin@shinobi.video / admin"
