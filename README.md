[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Reference App

* [Features](#features)
* [License](https://github.com/EricssonBroadcastServices/iOSClientRefApp/LICENSE)
* [Requirements](#requirements)
* [Installation](#installation)
* [Release Notes](#release-notes)
* [Roadmap](#roadmap)
* [Contributing](#contributing)

## Features

- [x] Vod, Live and Catchup playback.
- [x] Fairplay `DRM` protection.
- [x] Catchup playback from live *EPG*.
- [x] Download and offline playback.
- [x] Persistent user `SessionToken`s.
- [x] Multi Device Session Shift.
- [x] Airplay.
- [x] ChromeCast integration
- [x] Custom playback overlay.
- [x] Customer configured carousels

## Requirements

* `iOS` 9.0+
* `Swift` 4.0+
* `Xcode` 9.0+

* Framework dependencies
    - [`Exposure`](https://github.com/EricssonBroadcastServices/iOSClientExposure)
    - [`Player`](https://github.com/EricssonBroadcastServices/iOSClientPlayer)
    - [`ExposurePlayback`](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback)
    - [`Download`](https://github.com/EricssonBroadcastServices/iOSClientDownload)
    - [`ExposureDownload`](https://github.com/EricssonBroadcastServices/iOSClientExposureDownload)
    - [`Cast`](https://github.com/EricssonBroadcastServices/iOSClientCast)
    - Exact versions described in [Cartfile](https://github.com/EricssonBroadcastServices/iOSClientRefApp/blob/master/Cartfile)

## Installation
Cloning the repo should be enough to be able to build and run the *Reference App*.

### Environment.json
Customer specific environments should be added to the `environments.json` file, following the specified format.

```json
[
    {
        "name": "Environment Name",
        "exposureUrl": "ExposureURL",
        "customers": [
                        {
                            "name": "Customer Name",
                            "customer": "Customer",
                            "businessUnit": "BusinessUnit",
                            "defaultUsername": "Username",
                            "defaultPassword": "Password",
                            "mfa": false
                       }
                   ]
   }
]
```

Any environments specified in the `environments.json` file will be loaded by the *Reference App* on startup. The file exists as a template for local development and should be replaced with actual environments.

Applying the following commands will ignore local changes to `environments.json`, thus avoiding git conflicts. The template should never contain *actual* environment variables.

```sh
git update-index --skip-worktree environments.json
```

This could possibly be combined with pulling a local dev environment through `curl`

```sh
curl -O http://path.to.your/environment.json
```

### Carthage
The *Reference App* uses  [Carthage](https://github.com/Carthage/Carthage) for dependency management. Carthage is a decentralized dependency manager that builds your dependency graph without interfering with your `Xcode` project setup. `CI` integration through [fastlane](https://github.com/fastlane/fastlane) is also available.

## Release Notes
Release specific changes can be found in the [CHANGELOG](https://github.com/EricssonBroadcastServices/iOSClientRefApp/blob/master/CHANGELOG.md).

## Roadmap
No formalised roadmap has yet been established but an extensive backlog of possible items exist. The following represent an unordered *wish list* and is subject to change.

- [ ] Content search
- [ ] User playback history
- [ ] Better customization and loading of selected `Environment`s.

## Contributing

