#!/bin/bash
set -e
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
rm -rf tmp || true
mkdir tmp 
cd tmp
brew install libsodium
rm -rf /usr/local/lib/libsodium*.dylib
rm -rf /usr/local/opt/libsodium/lib/libsodium*.dylib
brew uninstall kr || true
brew untap kryptco/tap || true
rm -rf /usr/local/Homebrew/Library/Taps/kcking
rm -rf ~/Library/Caches/Homebrew/kr--git
brew tap kcking/tap
brew install --devel --build-bottle kcking/tap/kr || true

codesign -s "3rd Party Mac Developer Application: KryptCo, Inc. (W7AMYM5LPN)" /usr/local/Cellar/kr/$version/bin/kr
codesign -s "3rd Party Mac Developer Application: KryptCo, Inc. (W7AMYM5LPN)" /usr/local/Cellar/kr/$version/bin/krd
codesign -s "3rd Party Mac Developer Application: KryptCo, Inc. (W7AMYM5LPN)" /usr/local/Cellar/kr/$version/bin/krssh
codesign -s "3rd Party Mac Developer Application: KryptCo, Inc. (W7AMYM5LPN)" /usr/local/Cellar/kr/$version/bin/krgpg
if [ -f /usr/local/Cellar/kr/$version/Frameworks/krbtle.framework ]; then
	codesign -s "3rd Party Mac Developer Application: KryptCo, Inc. (W7AMYM5LPN)" /usr/local/Cellar/kr/$version/Frameworks/krbtle.framework
fi


brew bottle kcking/tap/kr --devel
mv kr-* kr-$version.$osx_name.bottle.tar.gz
tar xvf kr-$version.$osx_name.bottle.tar.gz
rm -f kr-$version.$osx_name.bottle.tar.gz
tar cvf kr-$version.$osx_name.bottle.tar.gz kr
mv kr-$version.$osx_name.bottle.tar.gz ..
openssl dgst -sha256 ../kr-$version.$osx_name.bottle.tar.gz 
cd ..
git add kr-$version.$osx_name.bottle.tar.gz
git commit -m "$osx_name $version"
