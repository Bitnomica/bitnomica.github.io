---
title: Android Integration
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

Services encompasses classes that implement backend request for typical CRUD operations on the data models. Internally we use Retrofit Services, that probably will be familiar to many Android developers.

UI Elements contains Views, Fragments and Activities, required for building User Interfaces with Lifeshare, such as Video Player, Submission Manager, GDPR Reporting functionality.

# Gradle Setup

Project level build.gradle:

Add the following lines to the corresponding sections:

``` gradle
buildscript {
    ...
    dependencies {
        ...
        classpath "org.jfrog.buildinfo:build-info-extractor-gradle:4+"
    }
}

allprojects {
    ...
    apply plugin: "com.jfrog.artifactory"
}


artifactory {
    contextUrl = "${artifactory_contextUrl}"   //The base Artifactory URL if not overridden by the publisher/resolver

    resolve {
        repository {
            repoKey = 'gradle-release'
            username = "${artifactory_user}"
            password = "${artifactory_password}"
            maven = true
        }
    }
}
```

Artifactory can generate this snippets for you. Hit

gradle.properties:

``` gradle
...

artifactory_user=""
artifactory_password=""
artifactory_contextUrl=https://artifactory.dev.bitnomica.com/artifactory
```

Target-level build.gradle

``` gradle
...
dependencies {
    ...
    implementation 'com.bitnomica:LifeshareSDK:4.0.0'
}
```

Note the examples in this file may use RXKotlin

``` gradle
    implementation 'io.reactivex.rxjava2:rxkotlin:2.4.0'
```

# Data Models

Data models are mostly self documenting, but we refer to other Lifeshare Documentation for more details.

In general, Lifeshare serves Channels in a tree-like structure, so a Channel may have zero or more sub-channels. Subchannels may subchannels of themselves.

The main playable video element in Lifeshare is called a Story. A Story is an assembly of multiple short video Fragments.

As as story contains all metadata required to play in a video player, it is by itself not playable. We need a Playlist for that. A playlist is constructed by our servers, and is in a format our players understands. It contains all instructions such as which video fragments to play and which overlays to show.

A Video model is a low-level object which corresponds to an actual video stored on our servers. Lifeshare supports streaming these video files in different formats, sizes and resolutions. Which of those are available will depend on SLA’s.

# Services

Lifeshare SDK adopts the `RxJava` library for reactive programming. This allows use to write concise and responsive code.

All Services are implemented as Retrofit `…​Service` protocols. Services that yield a single object will return a `Single<Resource<T>>` observable. The backend wraps each object in a generic `Resource` object, that acts as a container. The inner object is available under the '.resource' property.

Every endpoint that may yield multiple results, are paginated. This means that it will responds with a limited set of results (i.e. a `Page`). When you are ready to receive more results, you can request the next page. These services return a `Single<Resource<Page>` object. All these services have a `page` and 'perPage\` argument for requesting each page of data. A `` Page` `` object will contain the items (`.items`) and an information (`.info`) object that tells more about the number of results available and the number of pages.

# Initialization

Before requests can be made, LifeshareSDK needs initialization (once), typically in the `Application` class.

``` kotlin
import com.bitnomica.lifeshare.LifeshareSDK

class Application: Application() {
    override fun onCreate() {
        super.onCreate()
        LifeshareSDK.setup(this) // or LifeshareSDK.setup(this, "production")
        ...
    }
}
```

# Code Examples:

Calling a Service

``` kotlin
val playlist: Single<Playlist> = LifeshareSDK.getApiCaller(this, StoryService::class.java)
    .playlist("1", "1.0.0")
    .map { playlist ->
        playlist.resource
    }
    .observe { playlist ->
        ...
    }
```

Request stories.

``` kotlin
LifeshareSDK.request(this, PublisherService::class.java)
    .stories("slugs",0, 20)
    .map { resource -> resource.resource.items }
    .subscribe({ items ->
        print(items)
    }, { error ->
        print(error)
    })
    .addTo(disp)
```

## UI Elements

A Fullscreen player for a story is presented using a `ModalVideoPlayerActivity`. To be able to start a player, we need a `` Playlist` ``, and a `Domain` object. Domain encapsulates the configuration that belongs to the specific channel the story belongs to.

You can use the following convenience method:

``` kotlin
val storyId "159"
val channelId = "126"

StoryServiceHelper.openPlayer(context, storyId, channelId)
```

or the more complete example:

``` kotlin
val disp = CompositeDisposable()
...

val sPlaylist: Single<Playlist> = LifeshareSDK.request(context, StoryService::class.java)
    .playlist(storyId, "1.0.0")
    .map { playlist ->
        playlist.resource
    }

val sDomain: Single<Domain> = LifeshareSDK.request(context, PublisherService::class.java)
    .domain(channelId, "")
    .map { resource -> resource.resource }

sPlaylist.zipWith(sDomain)
    .subscribeOn(Schedulers.io())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe({ pair ->
        startActivity(Intent(context, ModalVideoPlayerActivity::class.java)
            .putExtra("playlist", pair.first)
            .putExtra("config", pair.second.playerConfig))
    }, { error ->
        Log.i("Main", "Error playlist ${error}")
    })
    .addTo(disp)
```

### Images

Channels have both a `.coverImage`, meant to show as a background for a (rectangular) region, for instance a button; and a `.logoImage`, which can be partially transparent (png) and can be shown as overlay on the background or standalone.

The easiest way is to use the `ImageServiceHelper` class. This example loads the `coverImage` for a given story and loads it into the `ImageView`: Size should be the size of the imageView in pixels, or an approximation thereof. Omitting `size` is discouraged.

``` kotlin
story.coverImageId?.let {
    ImageServiceHelper.setImage(context, it, Size(400, 400), imageView)
}
```

Alternatively, image data can be requested by using the `ImageService`.

``` kotlin
LifeshareSDK.request(this, ImageService::class.java)
    .subscribeOn(Schedulers.io())
    .image(imageId, 400, 400)
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe { image ->
        val imageView = ImageView(this)
        Glide.with(this)
            .load(image)
            .into(imageView)
    }
}
```

Other model that provide images: `User.avatarImageID`, `User.coverImageID`, `Story.coverImageID`, `Video.coverImageID`.
