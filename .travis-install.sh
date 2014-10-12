set -Ceux

case "$DCOMPILER" in
  dmd)
    curl -L -O http://downloads.dlang.org/releases/2014/dmd_2.066.0-0_amd64.deb
    sudo dpkg --install dmd_2.066.0-0_amd64.deb
    ;;
  gdc*|ldc*)
    sudo apt-get -y install "$DCOMPILER"
    ;;
esac
sudo curl -L -o /etc/apt/sources.list.d/d-apt.list http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list
sudo apt-get -y update
sudo apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring
sudo apt-get -y update
sudo apt-get -y install dub

# vim: set et sw=2 sts=2:
