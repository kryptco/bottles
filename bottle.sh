#!/bin/bash
version=$1
osx_name=$2
usage="usage: bottle.sh <VERSION> <OS NAME>"
if [[ -z $version ]]; then
	echo $usage 
	exit 1
fi
if [[ -z $osx_name ]]; then
	echo $usage 
	exit 1
fi
rm -rf tmp
mkdir tmp 
cd tmp
brew install libsodium
rm -rf /usr/local/lib/libsodium*.dylib
rm -rf /usr/local/opt/libsodium/lib/libsodium*.dylib
brew uninstall kr
brew untap kryptco/tap
rm -rf /usr/local/Homebrew/Library/Taps/kcking
brew install kcking/tap/kr --devel --build-bottle
brew bottle kcking/tap/kr --devel
mv kr-* kr-$version.$osx_name.bottle.tar.gz
tar xvf kr-$version.$osx_name.bottle.tar.gz
mv kr/* kr/$version
rm kr-$version.$osx_name.bottle.tar.gz
tar cvf kr-$version.$osx_name.bottle.tar.gz kr
openssl dgst -sha256 kr-$version.$osx_name.bottle.tar.gz 
