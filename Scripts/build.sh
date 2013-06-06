#!/bin/sh

#Git configurations
GIT_RELEASE_BRANCH="master"

#Project configurations
PROJECT_DIR=`pwd` 											#the project dir
TARGET_NAME="TestflightDistributionDemo" 					#the app name
TARGET_SDK="iphoneos6.1"									#iphone sdk use to build
TEMP_DIR="$PROJECT_DIR/build/tmp"							#build temp dir for .app and dSYM file
BUILD_DIR="$PROJECT_DIR/build"								#ipa dir
BUILD_NAME=${TARGET_NAME}`date +"%m%d%y%H%M%S"`				#ipa name

#TestFlight configurations
TF_RELEASE_NOTE="uploaded by build script"														#the release note `git log -1 -s --format=%s`
TF_DISTRIBUTON_LIST="Internal, QA"																#distribution list on testflight
TF_TEAM_TOKEN="!!!YOUR_TEST_FLIGHT_TEAM_TOKEN"													#Testlfight team token
TF_API_TOKEN="!!!YOUR_TEST_FLIGHT_API_TOKEN"													#Testflight API token
TF_NOTIFY="True"																				#Send email to tester after uploaded
TF_REPLACE="True"																				#replace the build if have same version

#pull new source codes from git
#cd "${PROJECT_DIR}"
#git reset --hard
#git pull origin ${GIT_RELEASE_BRANCH}


#compile project
echo Building Project
xcodebuild -target "${TARGET_NAME}" -sdk "${TARGET_SDK}" -configuration "Release" clean CONFIGURATION_BUILD_DIR="${TEMP_DIR}"
xcodebuild -target "${TARGET_NAME}" -sdk "${TARGET_SDK}" -configuration "Release" build CONFIGURATION_BUILD_DIR="${TEMP_DIR}"


#create ipa file
echo Create IPA
zip -r "${BUILD_DIR}/${BUILD_NAME}.app.dSYM.zip" "${TEMP_DIR}/${TARGET_NAME}.app.dSYM"
/usr/bin/xcrun -sdk "${TARGET_SDK}" PackageApplication -v "${TEMP_DIR}/${TARGET_NAME}.app" -o "${BUILD_DIR}/${BUILD_NAME}.ipa"

#upload to testflight
echo Upload to testflight
curl http://testflightapp.com/api/builds.json --progress-bar --verbose  -F file=@"${BUILD_DIR}/${BUILD_NAME}.ipa" -F dsym=@"${BUILD_DIR}/${BUILD_NAME}.app.dSYM.zip" -F api_token="${TF_API_TOKEN}" -F team_token="${TF_TEAM_TOKEN}" -F notes="${TF_RELEASE_NOTE}" -F notify="${TF_NOTIFY}" -F replace="${TF_REPLACE}" -F distribution_lists="${TF_DISTRIBUTON_LIST}"

#clean up
echo Clean up
rm -r ${TEMP_DIR}
rm -r ${PROJECT_DIR}/build
#git reset --hard
