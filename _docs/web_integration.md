---
layout: page
toc: true
title: Lifeshare SDK Web Integration
---

## Use cases

- Embedding a player into your website

- Full-featured channel browser for publishers

- Narrowcasting / digital signage

## Embedded Player

Paste the following snippet in your HTML document:

``` html
  <script type="application/javascript" src="https://app.vidicrowd.com/scripts/lifesharesdk-v3.js">

  <div id="player"></div>
  <script type="application/javascript">
    var player = LifeshareSDK.Player("player", "<STORYID>", <WIDTH>, <HEIGHT>, <MODE>, <AUTOPLAY>);
    player.addEventListener("player_ended", (e) => {
      console.log("Player Ended!");
    });
  </script>
```

This constructs a new player iframe and add that to the DOM-element with id: "player". Replace `<STORYID>` with the id of the story you want to play, and `<WIDTH>` and `<HEIGHT>` with the required CSS size on your page. If any of them is omitted, "100%" is used.

Arguments for Player:

``` javascript
LifeshareSDK.Player(
    containerId,
    src,
    width,
    height,
    mode,
    autoplay
)
```

Arguments:

- {string} containerId: The `id` of a container element in the DOM

- {object} src: The source you want to play

- {string} width: the preferred CSS width of the player. Default = "100%"

- {string} height: the preferred CSS height of the player. Default = "100%"

- {string} mode: one of: "default", "noninteractive", "modal". Default = "default"

- {boolean} autoplay: start playing automatically. noninteractive also means autoplay is on. Default is false

`source` can be one of:

- \- `string`: the player loads interprets the string as a Story.id, and plays the respective story.

- \- `object`: `{ 'url': <url> }`, the player loads the url which should point to a (dynamic) story.

The player sends the "player_ended" event when the player has stopped playing, or an error has occurred.

## Channel Browser

The Channel browser is the easiest solution for publishers to add a video browsing interface to their webites. You reserve some space on the html page and this component will take control over that area and present a full-featured channel browser including main player, search bar and channel navigator.

Channels are presented in a tree-like structure beginning with the topmost 'root'-Channel, and all sub-channels under that.

``` html
  <script type="application/javascript" src="https://app.vidicrowd.com/scripts/lifesharesdk-v3.js">
  <div id="browser"></div>
  <script type="application/javascript">
    var browser = new LifeshareSDK.Browser("browser", <SLUGS>, <WIDTH>, <HEIGHT>, <RESPONSIVE>)
  </script>
```

``` javascript
LifeshareSDK.Browser(containerId, slugs, width, height, autoHeight, live);
```

Arguments:

- {string} containerId: The `id` of a container element in the DOM

- {ArrayLike\<string\>} slugs: A list of strings containing the slugs(names) of the channel for which you want to present a browser

- {string} width: the preferred CSS width of the player. Use `null` for autofit

- {string} height: the preferred CSS height of the player. Use `null` for autofit

- {boolean} autoHeight: if true, the element will update its size to fit all content. Make sure the container element is able to grow/shrink together with its contents

- {boolean} live: if true, the browser component will load a "Live" HLS player.

When `autoHeight` is true. The iframe will automatically adjust the height of the iframe as needed to contain all content. As a result the iframe itself will need no scrollbar, the (outer) document will grow as needed and provide the scrolling.

# Narrow-casting / Digital Signage

Our narrowcasing solution uses the same HTML solutions we employ for websites. The most important requirement we require is that the narrowcasting system allows loading and showing webpages, and proceed based on some javascript event.

Some special considerations for this use case:

1.  Typically there is no user interaction, so the player must start automatically.

2.  UI should be minimal, only the progress bar should be shown.

3.  When playback is done, an event is raised so that the narrowcasting application can proceed.

The player has a special mode "noninteractive", which takes care of these considerations.

Example:

``` html
  <script type="application/javascript" src="https://app.vidicrowd.com/scripts/lifesharesdk-v3.js">

  <div id="player"></div>
  <script type="application/javascript">
    var player = LifeshareSDK.Player("player", "<STORYID>", <WIDTH>, <HEIGHT>, "noninteractive");
    player.addEventListener("player_ended", (e) => {
      console.log("Player Ended!");
    });
  </script>
```
