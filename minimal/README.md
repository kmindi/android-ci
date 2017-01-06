# Android CI

[![](https://images.microbadger.com/badges/image/silentstorm/android-ci:minimal.svg)](https://microbadger.com/images/silentstorm/android-ci:minimal "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/silentstorm/android-ci:minimal.svg)](https://microbadger.com/images/silentstorm/android-ci:minimal "Get your own version badge on microbadger.com")

A minimal version of the image which tries to use as less space as possible.
(Therefor only contains the android-23 target)

It contains:
 - build tools
 - platform tools

 - android-23 (+ system img)

 - extra-android-m2repository
 - extra-google-m2repository
 - extra-google-google_play_services

It can also be used in GitLab CI here is how a .gitlab-ci.yml  could look like:

```YAML
image: silentstorm/android-ci:minimal

variables:
  ANDROID_COMPILE_SDK: "23"

before_script:
  - chmod +x ./gradlew

stages:
  - build
  - test

build:
  stage: build
  script:
    - ./gradlew assembleDebug
  artifacts:
    name: "Namfy_{$CI_BUILD_ID}"
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

test:instrumentation:23:
  stage: test
  script:
    - echo no | android create avd -n test -t android-${ANDROID_COMPILE_SDK} --abi google_apis/armeabi-v7a
    - emulator64-arm -avd test -no-window -no-audio &
    - android-wait-for-emulator
    - export TERM=${TERM:-dumb}
    - assure_emulator_awake.sh "./gradlew cAT"
  artifacts:
    name: "tests-instrumentation-${ANDROID_COMPILE_SDK}-${CI_BUILD_NAME}"
    expire_in: 1 week
    paths:
      - "**/build/reports/androidTests"
```
