# create-embedded-map.rb

Language: [Ruby](https://www.ruby-lang.org/).

Prerequisite: Gem [redcarpet](https://github.com/vmg/redcarpet)

Creates a map with optional markers.

Call: `[external-caller="ruby self://bin/create-embedded-map.rb"]`

Arguments: None.

Stdin: YAML file with map definitions.

Output: JSON. The JSON output is processed by this plugin. And HTML is placed to the page. This indirection and its use is described [here](../README.md#return-json).

## Install prerequisites

```
$ [sudo] gem install redcarpet
```

See also [here](https://github.com/vmg/redcarpet#you-can-totally-install-it-as-a-gem).

## Scheme to call this program

~~~md
[external-caller="ruby self://bin/create-embedded-map.rb"]
```
---
provider: leaflet
geo: 52.05551,8.36240?z=16
width: 700
height: 400
poi:
  -
    description: Stadtpark
    geo: 52.05551,8.36240
    anchor: 'loc_stadtpark'
  -
    description: Spielplatz
    geo: 52.05592,8.36007
  -
    description: 'Eingang zum Stadtpark [Home](/)'
    geo: 52.05595,8.36562
    anchor: 'loc_stadtpark_eingang'
...
```
[/external-caller]
~~~

The configuration is a [YAML](https://yaml.org/) file. You must enclose this in [block code fences](https://learn.getgrav.org/16/content/markdown#block-code-fences) to keep the indentation, which is essential to YAML.

### Parameters

| Parameter  | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `provider` | Provider of the displayed map.<br />Possible values: `leaflet` |
| `geo`      | Location of the center of the map.<br />Scheme: `LATITUDE,LONGITUDE[?z=ZOOM-FACTOR]`<br />`LATITUDE` and `LOGITUDE` are floating point values.<br />The zoom factor is optional. It defaults to 16. |
| `width`    | Width of map in pixel.                                       |
| `height`   | Height of map in pixel.                                      |
| `poi`      | Array of hashes (associative array) of POI (point of interest). |

#### POI

| Parameter     | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| `description` | Literally description of POI.<br />Value: String.<br />The description is processed as markdown. Feel free to add links, formatting and so on. |
| `geo`         | Location of the center of the map.<br />Scheme: `LATITUDE,LONGITUDE`<br />`LATITUDE` and `LOGITUDE` are floating point values.<br />No zoom factor here. 😱 |
| `anchor`      | Name of an page anchor.<br />Value: String.<br />Syntax restrictions see [here](https://www.w3schools.com/hTML/html_id.asp). „The name is case sensitive. The name must contain at least one   character, and must not contain whitespaces (spaces, tabs,   etc.).“<br />On other Grav pages you may refer these POI.<br />Say the name is `loc_town_hall` on page `map`.<br />On any other or the same page you may link it with:<br /> `[Town Hall](map#loc_town_hall)` |
| `color`       | HTML/CSS color of the map marker.<br />Syntax restrictions see [here](https://www.w3schools.com/CSSref/pr_text_color.asp). |
| `badge`       | Text for the center of the marker. Should be very short! One, two or three characters. |

## Examples


```
[external-caller="ruby self://bin/create-embedded-map.rb"]
​```
---
provider: leaflet
geo: 38.89768,-77.03656?z=16
width: 700
height: 400
poi:
  -
    description: '[The White House](https://en.wikipedia.org/wiki/White_House)'
    geo: 38.89768,-77.03656
    anchor: 'loc_white_house'
...
​```
[/external-caller]
```
