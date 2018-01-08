#!/bin/bash
set -e

rm -rf tmp || true
mkdir tmp 
cd tmp

cd /usr/local/Homebrew/Library/Taps/kryptco/homebrew-tap && git fetch origin devel && git checkout FETCH_HEAD && git checkout -B devel && cd -

brew uninstall kr || true
rm -rf ~/Library/Caches/Homebrew/kr--git
brew tap kryptco/tap
brew install --verbose --build-bottle kryptco/tap/kr || true

brew bottle kryptco/tap/kr
bottle_name=`ls`
tar xvf $bottle_name
rm -f $bottle_name

cd kr
cd `ls`;
for binary in `find bin Frameworks -d 1 2>/dev/null || true`; do
	echo signing $binary...;
	codesign --force --deep --sign 577FDBB908358A69E5F25C0735ECF15143EF028D --timestamp=none $binary
done
cd ../..

tar cvf $bottle_name kr
mv $bottle_name ..
hash=`openssl dgst -sha256 ../$bottle_name | awk '{print $2}'`
echo $hash
cd ..
git add $bottle_name
git commit -m "$bottle_name SHA256: $hash"
