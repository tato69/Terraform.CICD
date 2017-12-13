#!/bin/bash
# 
# This Script delivers the following configuration:
#    Sets Puppet facts to dev_dev environment (Dev Stamp Dev branch)
#    DNS resolves to devcloudnp.ad.pwcinternal.com
#    Yum dev repos used
#    Connects to Dev Puppet Master
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin

factfile='/etc/puppetlabs/facter/facts.d/site-facts.yaml'
factdir='/etc/puppetlabs/facter/facts.d/'

echo "Setting ${factfile}"

mkdir -p ${factdir}
echo "pwcenv: dev_explore" > ${factfile}
#echo "pwcdatacenter: azure" >> ${factfile}
#echo "pwcdomain: devcloudnp.ad.pwcinternal.com" >> ${factfile}

if [ -d /var/www/html/RH ];then

  echo "pwcrepo: redhat7repo" >> ${factfile}

elif [ -d /var/www/html/CentOS ]; then
  
  echo "pwcrepo: centos7repo" >> ${factfile}

fi

yum clean all

#  Puppet Agent Install
echo "Checking for Puppet Agent"
hasPuppHost=$(egrep -q '^104.196.135.96 96.135.196.104.bc.googleusercontent.com bob-pupp-explore-master.c.pg-us-e-rob-01.internal bob-pupp-explore-master' /etc/hosts)${?}

if [ ${hasPuppHost} -ne 0 ] ; then
  echo "Installing Puppet Agent"
  echo '104.196.135.96 96.135.196.104.bc.googleusercontent.com bob-pupp-explore-master.c.pg-us-e-rob-01.internal bob-pupp-explore-master # Puppet Master' >> /etc/hosts
fi

if [ ! -h /usr/local/bin/puppet ] ; then 
  curl -k https://bob-pupp-explore-master.c.pg-us-e-rob-01.internal:8140/packages/current/install.bash | bash
fi


apt-get install -y git 2>1 > /dev/null || yum install -y git 2>1 > /dev/null
mkdir -p /tmp/puppet/
git clone https://github.com/tato69/jenkinsariso001a /tmp/puppet/jenkinsariso001a
/usr/local/bin/puppet module install puppetlabs-vcsrepo --modulepath=/tmp/puppet/
/usr/local/bin/puppet apply --modulepath=/tmp/puppet/ -e 'include jenkinsariso001a'

