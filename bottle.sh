#!/bin/bash
set -e
version=$1
osx_name=$2

rebuild=$3
if [[ ! -z "$rebuild" ]]; then
	rebuild="${rebuild}."
fi

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
brew install --verbose --HEAD --build-bottle kcking/tap/kr || true

bottle_name=kr-$version.$osx_name.bottle.${rebuild}tar.gz
brew bottle kcking/tap/kr --HEAD
mv kr-* $bottle_name
tar xvf $bottle_name
rm -f $bottle_name

cd kr
mv `ls` $version
cd `ls`;
for binary in `find bin -d 1 2>/dev/null || true`; do
	echo signing $binary...;
	codesign --force --sign BA1AEE36032DAA5F5D57C2E7E1A9856ADAB4F119 --timestamp=none $binary
done
cd ../..

tar cvf $bottle_name kr
mv $bottle_name ..
openssl dgst -sha256 ../$bottle_name 
cd ..
git add $bottle_name
git commit -m "$osx_name $version.$rebuild"
