#!/bin/bash

echo 'Setting up databases'
echo 'SCP-ing gs_schooldb and sharded dbs from staging.greatschools.org'
scp syncer@staging.greatschools.org:jenkins_mysqldump_db /home/admin/

if test "`find /home/admin/jenkins_mysqldump_db -mmin -300`"; then
  echo 'jenkins_mysqldump_db is current'
  mysql -f -uroot < /home/admin/jenkins_mysqldump_db
else
  echo 'jenkins_mysqldump_db is older than 5h --aborting'
  exit 1
fi

echo 'SCP-ing warehouse dbs from dev-gsdata.greatschools.org'
scp syncer@dev-gsdata.greatschools.org:jenkins_mysqldump_gsdata /home/admin/

if test "`find /home/admin/jenkins_mysqldump_gsdata -mmin -300`"; then
  echo 'jenkins_mysqldump_gsdata is current'
  mysql -f -uroot < /home/admin/jenkins_mysqldump_gsdata
else
  echo 'jenkins_mysqldump_gsdata is older than 5h --aborting'
  exit 1
fi