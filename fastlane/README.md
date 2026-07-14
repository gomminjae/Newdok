fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios certs

```sh
[bundle exec] fastlane ios certs
```

인증서/프로비저닝 프로파일 동기화

### ios release

```sh
[bundle exec] fastlane ios release
```

상용 TestFlight 배포

### ios dev

```sh
[bundle exec] fastlane ios dev
```

테섭 TestFlight 배포

### ios all

```sh
[bundle exec] fastlane ios all
```

상용 + 테섭 동시 TestFlight 배포

### ios build

```sh
[bundle exec] fastlane ios build
```

빌드만 (CI용)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
