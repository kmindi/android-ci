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
image: kmindi/android-ci:latest

variables:
  ANDROID_COMPILE_SDK: "25"

before_script:
  - export GRADLE_USER_HOME=$(pwd)/.gradle
  - chmod +x ./gradlew

stages:
  - build
  - test

cache:
  key: ${CI_PROJECT_ID}
  paths:
  - .gradle/

build:tagged:
  stage: build
  script:
    - ./gradlew assembleDebug
  artifacts:
    name: "AppName_{$CI_BUILD_TAG}"
    paths:
    - "app/build/outputs/apk/**/*.apk"
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
    - "app/build/outputs/apk/**/*.apk"
  except:
    - tags

test:unit:
  stage: test
  script:
    - ./gradlew test jacoco
  artifacts:
    name: "tests-unit-${CI_BUILD_NAME}_${CI_BUILD_REF_NAME}_${CI_BUILD_REF}"
    expire_in: 1 week
    paths:
      - "**/build/reports/**"
    
test:instrumentation:25:
  stage: test
  script:
    - echo no | avdmanager -v create avd --force --name test --abi google_apis/x86_64 --package "system-images;android-25;google_apis;x86_64"
    # - export SHELL=/bin/bash && emulator -avd test -no-window -no-audio & #prepend shell for bitness (32/64 bit) detection
    - export SHELL=/bin/bash && echo "no" | emulator -avd test -noaudio -no-window -gpu off -verbose -qemu &
    - adb wait-for-device
    - android-wait-for-emulator
    - export TERM=${TERM:-dumb}
    - export ADB_INSTALL_TIMEOUT=4 # minutes (2 minutes by default)
    - assure_emulator_awake.sh "./gradlew cAT"
    - ./gradlew createDebugCoverageReport
  artifacts:
    name: "tests-instrumentation-${ANDROID_COMPILE_SDK}-${CI_BUILD_NAME}"
    expire_in: 1 week
    paths:
      - "**/build/reports/**"

```
