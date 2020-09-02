#!/bin/bash

echo 'Setting up databases'
echo 'Setting up gs_schooldb and sharded dbs'
mysqldump --no-data -hstaging.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases gs_schooldb localized_profiles us_geo community api _ak _al _ar _az _ca _co \
_ct _dc _de _fl _ga _hi _ia _id _il _in _ks _ky _la _ma _md _me _mi _mn _mo _ms _mt _nc _nd _ne _nh _nj _nm _nv _ny _oh _ok _or _pa _ri _sc \
_sd _tn _tx _ut _va _vt _wa _wi _wv _wy | sed -e 's/\(.*DATABASE.*\)`\(.*\)`/\1`\2_test`/;s/\(.*USE \)`\(.*\)`/\1`\2_test`/' | mysql -f -uroot
echo 'Setting up warehouse dbs'
mysqldump --no-data -hdev-gsdata.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases omni gsdata | sed -e 's/\(.*DATABASE.*\)`\(.*\)`/\1`\2_test`/;s/\(.*USE \)`\(.*\)`/\1`\2_test`/' | mysql -f -uroot
