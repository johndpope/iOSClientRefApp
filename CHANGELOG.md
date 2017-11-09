# CHANGELOG

* `0.2.x` Releases - [0.2.0](#020) | [0.2.1](#021) | [0.2.2](#022)
* `0.1.x` Releases - [0.1.0](#010) | [0.1.1](#011) | [0.1.2](#012) | [0.1.6](#016)

## 0.2.2

#### Features
* Content promotion through `Carousel` layout with editorial control.
* `Featured` promotion through a topside, stretchable banner carousel.
* Additional *"carousels"* added to menu.
* Separated *login* and *environment* selection.
*`EMP-10600` Dynamic loading of content groups in sidebar menu based on `CustomerConfig`.
*`EMP-10601` Dynamic content presentation based on `CustomerConfig`.
*`EMP-10621` Player rebranding to `Red Bee`

#### Bug Fixes
* Offline media list now reloads when the view appears.

#### Changes
*`EMP-10605` Live and catchup through touch navigation.

## 0.2.1
Released 20 Oct 2017

#### Features
* `EMP-10322` Fetching cover art exhausts all options for images before displaying generic thumbnail.
* Previous playback offset displayed when viewing asset details.
* `EMP-10327` Downloading assets now possible.
* `EMP-10445` View, manage and play downloaded assets. `HLS` `Unencrypted`.
* Previous playback offset displayed when viewing asset details
* `VOD` view now uses Carousel from CustomerConfig`
* `EMP-10474` Downloading and asset now also stores the related playback entitlement on device.
* `EMP-10480` UI Refresh. Participants, actors etc added to details view.
* Offlne playback and asset management through download view

#### Changes
* `EMP-10293` Remove EntitlementRequester.
* Listen to onScrubbing event.
* Cleanup Constants naming (#9)
* `EMP-10478` Preparation of `DownloadTask`s now occur once `resume()` is called.
* `EMP-10481` Asset descriptions now fallbacks on any description locale.
* `EMP-10486` Adopted new `Exposure` based download task.

#### Bug Fixes
* Task restoration now forwards errors from tasks that completed with an error state.
* Logout response handled correctly

## 0.2.0
Released 5 Sep 2017

#### Features
* `EMP-9386` Playback events.
* `EMP-9389` Airplay for *Vod*, *Live* and *Catchup*.
* `EMP-9595` Automatic pipe line control over dependencies.
* `EMP-9772` Fairplay for *Live* and *Catchup*.
* `EMP-9801` *Live* entitlement request and playback implemented.
* `EMP-9802` *Catchup* entitlement request and playback implemented.
* `EMP-9951` Restructured dependency graph.
* `EMP-9974` Scrubbing, timebar and seeking implemented.
* `EMP-10037` Logout enabled.
* `EMP-10048` *EPG* view improvements.
* `EMP-10051` New dependency on [Analytics module](https://github.com/EricssonBroadcastServices/iOSClientAnalytics).
* `EMP-10057` Exposure based `AnalyticsProvider` implemented.
* `EMP-10095` Multi Device Session Shift.
* `EMP-10263` Localization should fallback on *any* locale before defaulting to *assetId*
* `EMP-10277` General documentation.

#### Bug fixes
* `EMP-10047` Airplay stops on screen lock.
* `EMP-10053` Fixed some layout issues in landscape mode.
* `EMP-10244` Workaround: Fetching *live* entitlements now falls back on asset endpoint if no *EPG* is available.

## 0.1.6
Released 12 Jun 2017

#### Features
* `EMP-9381` Asset selection view added.
* `EMP-9382` Added manual playback view added.
* `EMP-9383` Customized playback overlay view added.
* `EMP-9388` Fairplay for *Vod*.
* `EMP-9590` Asset details view added.
* `EMP-9749` Two-factor authentication popup implemented.

## 0.1.6
Released 30 May 2017

#### Features
* `EMP-9080` Testflight integration.
* `EMP-9379` Integrated generic config file.
* `EMP-9380` Anonymous authentication added.
* `EMP-9629` Use *Ericsson* logo and images.
* `EMP-9555` Fastlane integration for *build pipeline*.

#### Changes
* `EMP-9591` Updated login view with new aesthetics.

#### Bug fixes
* `EMP-9714` Resolved iPad issue with interface orientations.

## 0.1.2
Released 20 Apr 2017

No major changes

## 0.1.1
Released 20 Apr 2017

#### Features
* `EMP-9391` Separate repositories for modules.

## 0.1.1
Released 10 Apr 2017

Project setup.
