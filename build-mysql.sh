#!/bin/bash


highmem=1

pkgname=mysql-workbench
pkgver=8.0.34
_mysql_version=8.2.0
_connector_version=8.2.0
_gdal_version=3.7.2
_boost_version=1.77.0
_antlr4_version=4.13.1

# Add or adjust Fedora-specific dependencies
fedora_deps=('cairo' 'antlr4-runtime' 'curl' 'desktop-file-utils' 'freetype' 'giflib'
             'gtkmm30' 'json-c' 'libglvnd' 'libsecret' 'libssh' 'libaio'
             'libxml2' 'libzip' 'pcre' 'proj' 'python3' 'rapidjson' 'unixODBC'
             'vsqlite++' 'zstd' 'boost-devel' 'cmake' 'mesa-libGLU-devel'
             'swig' 'java-1.8.0-openjdk' 'ImageMagick' 'gdal-devel')

# Install Fedora dependencies
sudo dnf install -y "${fedora_deps[@]}"

# Download resources 
curl -z "mysql-workbench-community-${pkgver}-src.tar.gz" -O "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community-${pkgver}-src.tar.gz"
curl -z "mysql-${_mysql_version}.tar.gz" -O "https://cdn.mysql.com/Downloads/MySQL-${_mysql_version%.*}/mysql-${_mysql_version}.tar.gz"
curl -z "mysql-connector-c++-${_connector_version}-src.tar.gz" -O "https://cdn.mysql.com/Downloads/Connector-C++/mysql-connector-c++-${_connector_version}-src.tar.gz"
curl -z "gdal-${_gdal_version}.tar.xz" -O "https://download.osgeo.org/gdal/${_gdal_version}/gdal-${_gdal_version}.tar.xz"
curl -z "boost_${_boost_version//./_}.tar.bz2" -O "https://downloads.sourceforge.net/project/boost/boost/${_boost_version}/boost_${_boost_version//./_}.tar.bz2"
curl -z "0001-mysql-workbench-no-check-for-updates.patch" -O "https://raw.githubusercontent.com/archlinux/svntogit-packages/master/trunk/mysql-workbench/0001-mysql-workbench-no-check-for-updates.patch"
curl -z "0002-disable-unsupported-operating-system-warning.patch" -O "https://raw.githubusercontent.com/archlinux/svntogit-packages/master/trunk/mysql-workbench/0002-disable-unsupported-operating-system-warning.patch"
curl -z "0003-include-list.patch" -O "https://raw.githubusercontent.com/archlinux/svntogit-packages/master/trunk/mysql-workbench/0003-include-list.patch"
curl -z "0001-fix-buiild-for-32-bit.patch" -O "https://raw.githubusercontent.com/archlinux/svntogit-packages/master/trunk/mysql-workbench/0001-fix-buiild-for-32-bit.patch"
curl -z "atomic.patch" -O "https://raw.githubusercontent.com/archlinux/svntogit-packages/master/trunk/mysql-workbench/atomic.patch"
curl -z "arch_linux_profile.xml" -O "https://raw.githubusercontent.com/archlinux/svntogit-packages/master/trunk/mysql-workbench/arch_linux_profile.xml"


# Verify file integrity (adjust sha256sums as needed)
# 129Bsha256sum -c <<EOF
#b9bfc3e8746d5cebd7fa56a2ef5b7552332633306ccf99630ab242b9ff5aabb5  mysql-workbench-community-${pkgver}-src.tar.gz
#3dd017a940734aa90796a4c65e125e6712f64bbbbe3388d36469deaa87b599eb  mysql-workbench-community-${pkgver}-src.tar.gz.asc
#2ee3c7d0d031ce581deeed747d9561d140172373592bed5d0630a790e6053dc1  mysql-${_mysql_version}.tar.gz
#SKIP  mysql-${_mysql_version}.tar.gz.asc
#40c0068591d2c711c699bbb734319398485ab169116ac28005d8302f80b923ad  mysql-connector-c++-${_connector_version}-src.tar.gz
#SKIP  mysql-connector-c++-${_connector_version}-src.tar.gz.asc
#2d0f6dcf38f22e49ef7ab9de0230484f1ffac41b7ac40feaf5ef4538ae2f7a18  gdal-${_gdal_version}.tar.xz
#fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854  boost_1_77_0.tar.bz2
#cdf687f23bc6e8d52dbee9fa02b23d755e80f88476f0fc2e7c4c71cdfed3792f  0001-mysql-workbench-no-check-for-updates.patch
#e7e66ba68a21a0da87f0513f2b9550359c923a94aa7d16afe6ead063322e3d53  0002-disable-unsupported-operating-system-warning.patch
#719501bbd1de673767007c429feed2fc48d1176d456161c4ba69cf3165c0438a  0003-include-list.patch
#17294a67637ab7ffff5c39262208e63d21acac72cc2492f616ef1d8e0ae9ac02  0001-fix-buiild-for-32-bit.patch
#d816164098c90c432b4fe590708c14f95ab137abfe16ad1b7d498b2e83c0e265  atomic.patch
#fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854  arch_linux_profile.xml
#EOF

# Extract source files
tar -xvf "mysql-workbench-community-${pkgver}-src.tar.gz"
tar -xvf "mysql-${_mysql_version}.tar.gz"
tar -xvf "mysql-connector-c++-${_connector_version}-src.tar.gz"
tar -xvf "gdal-${_gdal_version}.tar.xz"
tar -xvf "boost_${_boost_version//./_}.tar.bz2"

# Proceed with the build process

echo "Build mysql"
echo "*******"
echo ""
mkdir "mysql-${_mysql_version}-build"
cd "mysql-${_mysql_version}-build"
cmake "../mysql-${_mysql_version}" \
  -DWITHOUT_SERVER=ON \
  -DBUILD_CONFIG=mysql_release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DSYSCONFDIR=/etc/mysql \
  -DMYSQL_DATADIR=/var/lib/mysql \
  -DWITH_BOOST=~/app/boost_1_77_0
make
make DESTDIR="$(pwd)/../mysql-install-bundle/"
sudo make install
cd ..

echo "Build mysql-connector-c++"
echo "*****"
mkdir "mysql-connector-c++-${_connector_version}-src-build"
cd "mysql-connector-c++-${_connector_version}-src-build"
cmake "../mysql-connector-c++-${_connector_version}-src" \
  -Wno-dev \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_BUILD_TYPE=Release \
  -DINSTALL_LIB_DIR=lib \
  #-DMYSQL_DIR=""\
  #-DMYSQL_CONFIG_EXECUTABLE=""
#  -DWITH_JDBC=OFF
make
sudo make install
cd ..

echo "Build gdal"
echo "*****"
echo ""
mkdir "build-gdal"
cd "build-gdal"
cmake -DCMAKE_INSTALL_PREFIX='/usr' \
      -DGDAL_USE_JASPER='OFF' \
      -DGDAL_USE_MYSQL='OFF' \
      -B . -S "../gdal-${_gdal_version}"
make LD_LIBRARY_PATH="$(pwd)/../mysql-${_mysql_version}-build/usr/lib/" -j$(nproc)
sudo make LD_LIBRARY_PATH="$(pwd)/../mysql-${_mysql_version}-build/usr/lib/" install
sudo ln -s '.' "/usr/include/gdal"
cd ..

echo "Build MySQL Workbench itself with bundled libs"
echo "*****"
echo ""
mkdir "mysql-workbench-community-${pkgver}-src-build"
cd "mysql-workbench-community-${pkgver}-src-build"
cmake "../mysql-workbench-community-${pkgver}-src" \
  -Wno-dev \
  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS} -std=c++17 -fsigned-char" \
  -DCMAKE_BUILD_TYPE=Release \
  -DMySQL_CONFIG_PATH="$(pwd)/../mysql-${_mysql_version}-build/usr/bin/mysql_config" \
  -DMySQLCppConn_LIBRARY="$(pwd)/../mysql-connector-c++-${_connector_version}-src-build/usr/lib/libmysqlcppconn.so" \
  -DMySQLCppConn_INCLUDE_DIR="$(pwd)/../mysql-connector-c++-${_connector_version}-src-build/usr/include/jdbc" \
  -DGDAL_INCLUDE_DIR="$(pwd)/../mysql-${_mysql_version}-build/usr/include" \
  -DGDAL_LIBRARY="$(pwd)/../mysql-${_mysql_version}-build/usr/lib/libgdal.so" \
  -DUNIXODBC_CONFIG_PATH='/usr/bin/odbc_config' \
  -DUSE_BUNDLED_MYSQLDUMP=1 \
  -DWITH_ANTLR_JAR="/usr/share/java/antlr-${_antlr4_version}-complete.jar"
make
sudo make install
cd ..
