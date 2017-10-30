# Android CI
[![](https://images.microbadger.com/badges/image/kmindi/android-ci.svg)](https://microbadger.com/images/kmindi/android-ci "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/kmindi/android-ci.svg)](https://microbadger.com/images/kmindi/android-ci "Get your own version badge on microbadger.com")

Repository for a docker image used for android CI.

The actual versions of the Android SKD* tools can be found at the end of the build log (given by `sdkmanager --list`)
It contains:
 - build tools
 - platform tools

 - android-25 (+ x86 system image)
 - android-26 (+ x86 system image)
 - android-27 (+ x86 system image)

 - extra-android-m2repository
 - extra-google-m2repository
 - extra-google-google_play_services

It can also be used in GitLab CI. Here is how a .gitlab-ci.yml  could look like:

```YAML
image: kmindi/android-ci:platforms-25-26-27

variables:
  GRADLE_OPTS: "-Dorg.gradle.daemon=false"

before_script:
  # Define cache-folders withing the build-folder to make it available for GitLab CI caching
  # http://stackoverflow.com/a/36050711/2170109
  # https://developer.android.com/studio/build/build-cache.html
  - export ANDROID_SDK_HOME=$CI_PROJECT_DIR
  - export GRADLE_USER_HOME=$(pwd)/.gradle
  - chmod +x ./gradlew

stages:
  - build
  - test

cache:
  key: ${CI_PROJECT_ID}
  paths:
  - .gradle/
  - .android/build-cache/

build:tagged:
  stage: build
  tags:
    - docker
  script:
    - ./gradlew assembleDebug
  artifacts:
    name: "AppName_{$CI_BUILD_TAG}"
    paths:
    - app/build/outputs/apk/
  only:
    - tags
    
build:
  stage: build
  tags:
    - docker
  script:
    - ./gradlew assembleDebug
  artifacts:
    name: "AppName_{$CI_BUILD_ID}"
    expire_in: 1 week
    paths:
    - app/build/outputs/apk/
  except:
    - tags

test:unit:
  stage: test
  tags:
    - docker
  script:
    - ./gradlew test jacocoTestReport
    - cat "app/build/reports/jacoco/jacocoTestReport/html/index.html"
  coverage: '/Total.+([0-9]{1,3})\%/'
  cache:
    key: ${CI_PROJECT_ID}
    paths:
    - .gradle/
    - .android/build-cache/
    policy: pull
  artifacts:
    name: "tests-unit-${CI_BUILD_NAME}_${CI_BUILD_REF_NAME}_${CI_BUILD_REF}"
    expire_in: 1 week
    paths:
      - "**/build/reports/**"
    
test:instrumentation:25:
  stage: test
  tags: 
    - docker
    - kvm
  script:
    - echo no | avdmanager -v create avd --force --name test --abi google_apis/x86 --package "system-images;android-25;google_apis;x86"
    - export SHELL=/bin/bash && echo "no" | emulator -avd test -noaudio -no-window -gpu off -verbose -qemu &
    - adb wait-for-device
    - android-wait-for-emulator
    - export TERM=${TERM:-dumb}
    - export ADB_INSTALL_TIMEOUT=4 # minutes (2 minutes by default)
    - assure_emulator_awake.sh "./gradlew connectedAndroidTest"
    - ./gradlew createDebugCoverageReport
    - cat "app/build/reports/coverage/debug/index.html"
  coverage: '/Total.+([0-9]{1,3})\%/'
  artifacts:
    name: "tests-instrumentation-25-${CI_BUILD_NAME}"
    expire_in: 1 week
    paths:
      - "**/build/reports/**"

test:instrumentation:26:
  stage: test
  tags:
    - docker
    - kvm
  script:
    - echo no | avdmanager -v create avd --force --name test --abi google_apis/x86 --package "system-images;android-26;google_apis;x86"
    - export SHELL=/bin/bash && echo "no" | emulator -avd test -noaudio -no-window -gpu off -verbose -qemu &
    - adb wait-for-device
    - android-wait-for-emulator
    - export TERM=${TERM:-dumb}
    - export ADB_INSTALL_TIMEOUT=4 # minutes (2 minutes by default)
    - assure_emulator_awake.sh "./gradlew connectedAndroidTest"
    - ./gradlew createDebugCoverageReport
    - cat "app/build/reports/coverage/debug/index.html"
  coverage: '/Total.+([0-9]{1,3})\%/'
  artifacts:
    name: "tests-instrumentation-26-${CI_BUILD_NAME}"
    expire_in: 1 week
    paths:
      - "**/build/reports/**"

```
