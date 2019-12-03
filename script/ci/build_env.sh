#!/bin/bash

echo 'Adding routes'
sudo /sbin/route del default
sudo /sbin/route add default gw 192.168.111.81
sudo /sbin/route add -net 172.16.0.0 netmask 255.240.0.0 gw 192.168.111.187
sudo /sbin/route add -net 192.168.121.0 netmask 255.255.255.0  gw 192.168.111.187

# echo 'Bundle'
# bundle install --deployment --without development

echo 'Setting up databases'
mysqldump -hqa-db1.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases gs_schooldb localized_profiles us_geo community api _ak _al _ar _az _ca _co \
_ct _dc _de _fl _ga _hi _ia _id _il _in _ks _ky _la _ma _md _me _mi _mn _mo _ms _mt _nc _nd _ne _nh _nj _nm _nv _ny _oh _ok _or _pa _ri _sc \
_sd _tn _tx _ut _va _vt _wa _wi _wv _wy | sed -e 's/\(.*DATABASE.*\)`\(.*\)`/\1`\2_test`/;s/\(.*USE \)`\(.*\)`/\1`\2_test`/' | mysql -f -uroot

mysqldump -hqa-warehouse.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases omni gsdata | sed -e 's/\(.*DATABASE.*\)`\(.*\)`/\1`\2_test`/;s/\(.*USE \)`\(.*\)`/\1`\2_test`/' | mysql -f -uroot

# echo 'Webpack and npm install'
# mkdir -p app/assets/webpack
# rm -f app/assets/webpack/*
# npm install
# npm run build:production