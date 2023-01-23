#!/bin/bash

# author: Wesley Marques
# describe: Instalar e configurar SAMBA4 para ADDC
# version: 0.3
# license: MIT License

SAMBA_VERSION="4.17.4"
SAMBA_PACK="samba-${SAMBA_VERSION}.tar.gz"
SAMBA_DIR="samba-${SAMBA_VERSION}"
SAMBA_LINK="https://download.samba.org/pub/samba/stable/${SAMBA_PACK}"

# Function to check if script has execution permission
check_permission() {
    if [ ! -x "$0" ]; then
        echo "Script does not have execution permission. Exiting..."
        exit 1
    fi
}

# Function to configure date and time
configure_date_time() {
    timedatectl set-timezone America/Sao_Paulo
    apt-get install -y ntp ntpdate
    service ntp stop
    ntpdate a.st1.ntp.br
    service ntp start
}

# Function to install dependencies
install_dependencies() {
    apt-get update && apt-get upgrade -y
    apt-get install -y wget acl attr autoconf bind9utils bison build-essential debhelper dnsutils docbook-xml docbook-xsl flex gdb libjansson-dev krb5-user libacl1-dev libaio-dev libarchive-dev libattr1-dev libblkid-dev libbsd-dev libcap-dev libcups2-dev libgnutls28-dev libgpgme-dev libjson-perl libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl libpopt-dev libreadline-dev nettle-dev perl pkg-config python-all-dev python2-dbg python-dev-is-python3 python3-dnspython python3-gpg python3-markdown python3-dev xsltproc zlib1g-dev liblmdb-dev lmdb-utils libsystemd-dev perl-modules-* libdbus-1-dev libtasn1-bin apt-transport-https
    apt-get -y autoremove
    apt-get -y autoclean
    apt-get -y clean 
}

# Function to install samba
install_samba() {
    cd /usr/src/
    
    wget -c ${SAMBA_LINK}
   
    tar -xf ${SAMBA_PACK}
    
    cd ${SAMBA_DIR}
    
    ./configure --with-systemd --prefix=/usr/local/samba --enable-fhs
    
    make && make install
    
    echo "PATH=$PATH:/usr/local/samba/bin:/usr/local/samba/sbin" >> /root/.bashrc
    
    source /root/.bashrc
    
    cp -v /usr/src/${SAMBA_DIR}/bin/default/packaging/systemd/samba.service /etc/systemd/system/samba-ad-dc.service
    
    mkdir -v /usr/local/samba/etc/sysconfig

    echo 'SAMBAOPTIONS="-D"' > /usr/local/samba/etc/sysconfig/samba

    systemctl daemon-reload

}

# Function to provision samba AD
provision_samba() {
    samba-tool domain provision --use-rfc2307 --realm=$FQDN --domain=${FQDN%%.*}
    
    rm /etc/krb5.conf

    cp -bv /usr/local/samba/var/lib/samba/private/krb5.conf /etc/krb5.conf
}

# Function to enable samba service
enable_samba_service() {
    systemctl enable samba-ad-dc.service
}

# Function to start samba service
start_samba_service() {
    systemctl start samba-ad-dc.service
}

# Function to uninstall samba
uninstall_samba() {
    systemctl stop samba-ad-dc.service
    rm -rf /usr/local/samba
    rm -rf /etc/systemd/system/samba-ad-dc.service
    sed -i '/samba/d' /root/.bashrc
    apt-get remove -y samba
}

# Function to configure hostname and DNS
configure_hostname_dns() {
    echo "Enter FQDN (Fully Qualified Domain Name) : "
    read FQDN
    hostnamectl set-hostname $FQDN
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    echo "$IP_ADDRESS $FQDN ${FQDN%%.*}" >> /etc/hosts
}


# Main function
main() {
    check_permission
    configure_date_time
    install_dependencies
    configure_hostname_dns
    install_samba
    provision_samba
    enable_samba_service
    start_samba_service
}

# Run main function
main
