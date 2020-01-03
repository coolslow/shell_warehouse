#功能：将当前所在的flutter plugin 或者 package 上传到私有的dart-pub
# pub server : https://github.com/dart-lang/pub_server
# pub server 所在的ip，需要 export PUB_HOSTED_URL=http://10.33.108.16:2406
# 前提： 
# （1）当前flutter 工程有一个example
# （2）brew install yq

#输入参数 1 : 将要发布到pub的版本，写入pubspec的version属性


if [ -z "$1" ]
then
   echo "version is expected"
   exit -1
fi

version=$1

echo "new version is $version"

# 检验是否有编译错误
cd example/
rm -fr ~/.pub_cache

flutter clean || { flutter packages get ; }
flutter packages get
flutter packages upgrade

cd ios/
pod install || { pod repo update && pod install ; }
cd ..

flutter build ios --simulator || { exit -1 ; }
cd ..

# 修改版本
yq delete  pubspec.yaml version -i
yq write   pubspec.yaml version "$version" -i
# 上传
pub get
pub publish  --force 
