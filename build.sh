#!/bin/sh -ex

cd "`dirname \"$0\"`"
ROOT_PATH="$PWD"
BUILD_PATH="$ROOT_PATH/build"

rm -rf "$BUILD_PATH"

xcodebuild -configuration Release -sdk iphoneos SYMROOT="$BUILD_PATH" CODE_SIGN_IDENTITY="iPhone Developer"
xcrun -sdk iphoneos PackageApplication -v "$BUILD_PATH/Release-iphoneos/Picsyou.app" -o "$BUILD_PATH/Release-iphoneos/Picsyou.ipa"
cd "$BUILD_PATH/Release-iphoneos"
zip -r9y Picsyou.app.dSYM.zip Picsyou.app.dSYM
