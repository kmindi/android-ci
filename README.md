# Android CI
[![](https://images.microbadger.com/badges/image/kmindi/android-ci.svg)](https://microbadger.com/images/kmindi/android-ci "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/kmindi/android-ci.svg)](https://microbadger.com/images/kmindi/android-ci "Get your own version badge on microbadger.com")

Repository for a docker image used for android CI.

It contains:
 - build tools
 - platform tools

 - android-25 (+ system img)
 - android-26 

 - extra-android-m2repository
 - extra-google-m2repository
 - extra-google-google_play_services

It can also be used in GitLab CI here is how a .gitlab-ci.yml  could look like:

```YAML
image: kmindi/android-ci

variables:
 ANDROID_COMPILE_SDK: "25"

before_script:
 - chmod +x ./gradlew

stages:
 - build
 - test

build:tagged:
  stage: build
  script:
    - ./gradlew assembleDebug
  artifacts:
    name: "AppName_{$CI_BUILD_TAG}"
    paths:
    - "app/build/outputs/**/*.apk"
  only:
    - tags

build:
 stage: build
 script:
   - ./gradlew assembleDebug
 artifacts:
   name: "AppName_{$CI_BUILD_ID}"
   expire_in: 1 week
   paths:
   - "app/build/outputs/**/*.apk"
 except:
   - tags

test:unit:
 stage: test
 script:
   - ./gradlew test
 artifacts:
   name: "tests-unit-${CI_BUILD_NAME}_${CI_BUILD_REF_NAME}_${CI_BUILD_REF}"
   expire_in: 1 week
   paths:
     - "**/build/reports/tests"

test:instrumentation:25:
 stage: test
 script:
   - echo no | android create avd -n test -t android-${ANDROID_COMPILE_SDK} --abi google_apis/x86
   - emulator64-x86 -avd test -no-window -no-audio &
   - android-wait-for-emulator
   - export TERM=${TERM:-dumb}
   - assure_emulator_awake.sh "./gradlew cAT"
 artifacts:
   name: "tests-instrumentation-${ANDROID_COMPILE_SDK}-${CI_BUILD_NAME}"
   expire_in: 1 week
   paths:
     - "**/build/reports/androidTests"
```
