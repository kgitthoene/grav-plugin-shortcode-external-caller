# create-embedded-map.rb

Language: [Ruby](https://www.ruby-lang.org/).

Prerequisite: Gem [redcarpet](https://github.com/vmg/redcarpet)

Creates a map with optional markers.

Call: `[external-caller="ruby self://bin/create-embedded-map.rb"]`

Arguments: None.

Stdin: YAML file with map definitions.

Output: JSON. The JSON output is processed by this plugin. And HTML is placed to the page. This indirection and its use is described [here](../README.md#return-json).

## Install prerequisites

Ruby, of course. See [here](https://www.ruby-lang.org/en/documentation/installation/).

And the gems redcarpet, fast_gettext.

```sh
$ [sudo] gem install redcarpet
```

See [here](https://github.com/vmg/redcarpet#you-can-totally-install-it-as-a-gem).

```sh
$ [sudo] gem install fast_gettext
```

See [here](https://github.com/grosser/fast_gettext#setup).

## Scheme to call this program

~~~md
[external-caller="ruby self://bin/create-embedded-map.rb"]
```
---
provider: leaflet
geo: 38.89768,-77.03656?z=13
width: 700
height: 400
poi:
  -
    description: 'The White House'
    geo: 38.89768,-77.03656
    anchor: 'loc_white_house'
    color: red
    badge: A
...
```
[/external-caller]
~~~

The configuration is a [YAML](https://yaml.org/) file. You must enclose this in [block code fences](https://learn.getgrav.org/16/content/markdown#block-code-fences) to keep the indentation, which is essential to YAML.

### Parameters

| Parameter  | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `provider` | (Optional) Provider of the displayed map.<br />Possible values: `leaflet`<br />A map without map provider defaults to `leaflet`. |
| `geo`      | Location of the center of the map.<br />Scheme: `LATITUDE,LONGITUDE[?z=ZOOM-FACTOR]`<br />`LATITUDE` and `LOGITUDE` are floating point values. The zoom factor is optional. It defaults to 16. |
| `locale`   | (Optional) Locale of map.<br />Possible values: `en`, `de` and all the other locales you define in `bin/locales` directory of the plugin. It defaults to `en`. |
| `width`    | Width of map in pixel.                                       |
| `height`   | Height of map in pixel.                                      |
| `poi`      | (Optional) Array of hashes (associative array) of POI (point of interest). |

#### POI

| Parameter     | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| `description` | (Optional) Literally description of POI.<br />Value: String.<br />The description is processed as markdown. Feel free to add links, formatting and so on. |
| `geo`         | Location of the POI.<br />Scheme: `LATITUDE,LONGITUDE`<br />`LATITUDE` and `LOGITUDE` are floating point values. No zoom factor here. 😱 So, the marker may not be visible on the map. |
| `anchor`      | (Optional) Name of an page anchor.<br />Value: String.<br />Syntax restrictions see [here](https://www.w3schools.com/hTML/html_id.asp). „The name is case sensitive. The name must contain at least one   character, and must not contain whitespaces (spaces, tabs,   etc.).“<br />On other Grav pages you may refer these POI. Say the anchor is `loc_town_hall` on page `map`. You may link it with:  `[Town Hall](map#loc_town_hall)` |
| `color`       | (Optional) HTML/CSS color of the map marker. Syntax restrictions see [here](https://www.w3schools.com/CSSref/pr_text_color.asp). POI without specific color default to an internal color scheme. |
| `badge`       | (Optional) Text for the center of the marker. Should be very short! One, two or three characters. POI without badge are numbered up beginning with 1. |

## Example

```md
[external-caller="ruby self://bin/create-embedded-map.rb"]
​```
---
provider: leaflet
locale: en
geo: 38.89768,-77.03656?z=13
width: 700
height: 400
poi:
  -
    description: '[The White House](https://en.wikipedia.org/wiki/White_House), Washington, D.C.'
    geo: 38.89768,-77.03656
    anchor: 'loc_white_house'
    color: red
    badge: A
  -
    description: 'Restaurant [Oyamel Cocina Mexicana](https://www.oyamel.com/)'
    geo: 38.89494,-77.02167
  -
    description: 'Restaurant [BLT Steak](https://bltrestaurants.com/blt-steak/washington-d-c/)'
    geo: 38.90172,-77.03760
  -
    description: 'Restaurant [Taylor Gourmet](http://taylorgourmet.com/)'
    geo: 38.90585,-77.04371
  -
    description: 'Restaurant [Minibar](http://www.minibarbyjoseandres.com/minibar/)'
    geo: 38.89632,-77.02358
  -
    description: 'Restaurant [Good Stuff Eatery](http://goodstuffeatery.com/locations/capitol-hill)'
    geo: 38.88660,-77.00179
  -
    description: 'Restaurant [Rose’s Luxury](https://www.rosesrestaurantgroupdc.com/)'
    geo: 38.88064,-76.99528
  -
    description: 'Restaurant [Blue Duck Tavern](https://www.blueducktavern.com/?src=vanity_blueducktavern.com)'
    geo: 38.90553,-77.05116
  -
    description: 'Restaurant [Ray’s Hell Burger](http://www.rayshellburger.com/)'
    geo: 38.90282,-77.01777
  -
    description: 'Restaurant [Restaurant Nora](http://www.noras.com/)'
    geo: 38.91275,-77.04727
...
​```
[/external-caller]
```
