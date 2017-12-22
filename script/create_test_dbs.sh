#!/bin/sh

echo "enter mysql developer password when prompted..."
mysqldump -hditto.greatschools.org -d -udeveloper -p --databases api gs_schooldb localized_profiles gscms_pub us_geo community surveys _ak _al _ar _az _ca _co _ct _dc _de _fl _ga _hi _ia _id _il _in _ks _ky _la _ma _md _me _mi _mn _mo _ms _mt _nc _nd _ne _nh _nj _nm _nv _ny _oh _ok _or _pa _ri _sc _sd _tn _tx _ut _va _vt _wa _wi _wv _wy | sed 's/\(.*DATABASE.*\)`\(.*\)`/\1`\2_test`/;s/\(.*USE \)`\(.*\)`/\1`\2_test`/' | mysql -f -uroot

echo "dumping gsdata tables now"
mysqldump -hdev-gsdata.greatschools.org -d -udeveloper -p --databases gsdata | sed 's/\(.*DATABASE.*\)`\(.*\)`/\1`\2_test`/;s/\(.*USE \)`\(.*\)`/\1`\2_test`/' | mysql -f -uroot

echo "done!"



