---
title: Lifeshare IOS SDK
layout: page
toc: true
---
# Introduction

Lifeshare SDK is a software development dedicated to work with and on the Lifeshare Platform. It contains all that is needed to interact with Lifeshare and make meaningful user interfaces with Interactive Video.

# Background

Lifeshare SDK consists of three main pieces of code

1.  Data Models

2.  Services

3.  UI Elemements

Data Models contain all models that have meaning in the Lifeshare Ecosystem, such as `Channel`, `Story`, `Fragment`, `Video` and `User`

Services encompasses classes that implement backend request for typical CRUD operations on the data models.

UI Elements contains Views and ViewControllers, required for building User Interfaces with Lifeshare, such as Video Player, Submission Manager, GDPR Reporting functionality.

# Integration

We support both Cocoapod integration and SPM (Swift Package Manager). Cocoapod support will be removed in the near future.

## Cocoapod integration

Lifeshare SDK is distributed as a cocoapod

Add these lines to your `Podfile` and update: `pod install`

    source 'git@git.dev.bitnomica.com:repo/cocoapods.git'

    pod 'LifeshareSDK'
    # pod 'LifeshareSDK/Advertising'  # if advertisingmodule is required

## Swift Package Manager

LifeshareSDK is served from a private GIT repository (git.dev.bitnomica.com). Since this is no public server, a SSH key is required to access the repository. A key can be obtained by contacting sales.

XCode is a bit tough on ssh-keys. The proper way to install the key is as follows:

1.  Close XCode completely (all windows)

2.  Copy the obtained key to ~/.ssh/git-dev-bitnomica-com

3.  run `ssh-add --apple-use-keychain ~/.ssh/git-dev-bitnomica-com`

4.  Start XCode and open your project.

5.  Add a new package dependency for your project. Add this url as a package dependency in XCode or in your Packages.swift: `git@git.dev.bitnomica.com:/home/git/repo/lifeshare-sdk-ios.git`

6.  Select LifeshareSDK (and LifeshareSDKAdvertising if required) to your target. We recommend to use `up to next Major version` and use the latest version

7.  Build

# CI Integration

**IMPORTANT** Read <https://developer.apple.com/documentation/xcode/building-swift-packages-or-apps-that-use-them-in-continuous-integration-workflows>

In essence this boils down to:

1.  Make sure the git.dev.bitnomica.com public host key is added to the known_hosts file.

2.  Make sure the SSH Key is added to the SSH Agent before running xcodebuild

# Data Models

Data models are mostly self documenting, but we refer to other Lifeshare Documentation for more details.

In general, Lifeshare serves Channels in a tree-like structure, so a Channel may have zero or more sub-channels. Subchannels may subchannels of themselves.

The main playable video element in Lifeshare is called a Story. A Story is an assembly of multiple short video Fragments.

As as story contains all metadata required to play in a video player, it is by itself not playable. We need a Playlist for that. A playlist is constructed by our servers, and is in a format our players understands. It contains all instructions such as which video fragments to play and which overlays to show.

A Video model is a low-level object which corresponds to an actual video stored on our servers. Lifeshare supports streaming these video files in different formats, sizes and resolutions. Which of those are available will depend on SLA’s.

# Services

Lifeshare SDK adopted the `ReactiveSwift` library for reactive programming. This allows use to write concise and responsive code.

All Services are implemented in `…​Service` classes. Services that yield a sinlgle object will return a `SignalProducer<T, Error>` observable (in Rx the equivalent would be `Single<T>`)

Every endpoint that may yield multiple results, are paginated. This means that it will responds with a limited set of results (i.e. a `Page`). When you are ready to receive more results, you can request the next page. These services return a `Paginator<T>` object. Requesting a page is done by `paginator.get(page: Int) → Page<T>`. The page object will contain the items (`.items`) and an information (`.info`) object that tells more about the number of results available and the number of pages

# Initialization

Before requests can be made, LifeshareSDK needs initialization (once), typically in AppDelegate.

``` swift
import LifeshareSDK
Lifeshare.setup(application: application,
                environment: Environment(dtap: .test),
                theme: DefaultTheme())
```

## Example Request

Get channel

``` swift
import ReactiveSwift
...

PublisherService.channel(slugs: ["channel-slug"])
    .request()
    .startWithResult { result in
        switch result {
        case .success(let channel):
            print(channel)
        default:
            ()
        }
    }
```

Channels are identified by either their unique `.id` property or a unique sequence of strings, called `.slug`. This sequence is constructed by following the path from the root channel to the lead channel and taking the slug from each channel on the path.

Get available subchannels

``` swift
PublisherService.browse(slugs: ["channel-slug"])
    .get(page: 0)
    .request()
    .startWithResult { result in
        switch result {
        case .success(let page):
            print(page.items)
            print(page.total)
        default:
            ()
        }
    }
```

Get Story

``` swift
PublisherService.channel(slugs: ["channel-slug"])
    .request()
    .flatMap(.concat) { channel in
        PublisherService.stories(channelId: channel.id)
            .get(page: 0)
            .request(with: client)
    }
    .startWithResult { result in
        switch result {
        case .success(let page):
            print(page.items)
        default:
            ()
        }
    }
```

## UI Elements

A Fullscreen player for a story is presented using `ModalPlayerPresenter`.

`ModalPlayerPresenter` is a protocol that can be implemented by any ViewController. `ModalPlayerPresenter` provides a default implementation for presenting a `` PlayerViewModel` `` or a `Story`. You can use this by decorating your own presenting ViewController class with a `ModalPlayerPresenter` protocol and calling the `.present(…​)` method somewhere in a class method implementation

Example:

``` swift
class MyViewControlller: UIViewController, ModalPlayerPresenter {
    ...

    func ... {
        ...
        self.present(story: story, channel: channel)
        ...
    }
}
```

## Images

Channels have both a `.coverImage`, meant to show as a background for a (rectangular) region, for instance a button; and a `.logoImage`, which can be partially transparent (png) and can be shown as overlay on the background or standalone.

Image URLs can be requested by using the `.coverImageURL: URL` property and `.logoImageURL` property.

The same holds for `User.avatarImageID`, `User.coverImageID`, `Story.coverImageID`, `Video.coverImageID`. These URLs can be used to fetch images with your framework of choice.

LifeshareSDK also provides its own `ImageProvider` class that can take care of fetching images and putting them in the right imageView. Using `` ImageProvider`s `` is fully optional.

``` swift
imageView.provider = story.coverImageProvider
```

This will asynchronously fetch the image, and set the `UIImageView.image` property. The imageProvide is 'bound' to the imageview during the lifetime of the imageview, or until another imageprovider is assigned.

Alternatively to use a placeholder image if loading fails:

``` swift
imageView.provider = PictureImageProvider(imageID: story.coverImageID, placeholder: UIImage("placeholder"))
```

In a view that can be recycled, such as in uitableview or uicollectionview, you need to check whether the cell is still the right one.

``` swift
imageView.provider = PictureImageProvider(imageID: story.id, placeholder: UIImage("placeholder"))
imageView.set(provider: story.coverImageProvider, condition: {
    collectionView.isNotCellReused(cell: self, at: indexPath)
})
```

If the `condition` returns false at the time the image is fetched, the image property will not be set.
