# Grav Shortcode External Caller Plugin

## About

The **Shortcode External Caller** plugin provides the `[external-caller="..."]` shortcode for
[Grav](https://github.com/getgrav/grav) to call external programs.

Basically the external program gets an environment and arguments.
The text between the opening and ending shortcode is passed to the program as stdin.
The complete shortcode is replaced by the HTML output of the external program (stdout).

The output from the external program is **not** post-processed by the markdown processor of Grav!

## Installation

Typically a plugin should be installed via [GPM](http://learn.getgrav.org/advanced/grav-gpm) (Grav Package Manager):

```
$ bin/gpm install shortcode-external-caller
```

Alternatively it can be installed via the [Admin Plugin](http://learn.getgrav.org/admin-panel/plugins)

## Usage

Using the shortcode like:

```md
[external-caller="PROGRAM ARGUMENTS"]
​```
OPTIONAL-STDIN-OF-PROGRAM
​```
[/external-caller]
```

The shortcode is replaced by the HTML output (stdout) of the program. See the examples below.
Don't forget the **double quotes** around the program and its arguments.
Enclose the stdin, between the opening and closing shortcode with **[block code fences](https://learn.getgrav.org/16/content/markdown#block-code-fences)**. Unless you want Grav to process the stdin with its markdown processor before giving it to the program. (Not really a good idea, if you want to handle indented text to a program. E.g. [YAML](https://yaml.org/) files.) – But, this is optional. You may want to read the HTML produced by the markdown processor of Grav.

## Environment

A set of environment variables is defined. You may use them in your program.

| Variable                                        | Meaning                                  | Example                                                      |
| ----------------------------------------------- | ---------------------------------------- | ------------------------------------------------------------ |
| <a name="ROOT_PATH"></a>ROOT_PATH               | Root directory of the Grav installation. | `/var/www/grav_instance`                                     |
| <a name="PLUGIN_PATH"></a>PLUGIN_PATH           | Root directory of all plugins.           | `/var/www/grav_instance/user/plugins`                        |
| <a name="THIS_PLUGIN_PATH"></a>THIS_PLUGIN_PATH | Directory of this plugin.                | `/var/www/grav_instance/user/plugins/shortcode-external-caller` |
| <a name="PAGE_PATH"></a>PAGE_PATH               | Directory of the current page.           | `/var/www/grav_instance/user/page/08.about`                  |
| PAGE_ROUTE                                      | Grav route to current page.              | `/about`                                                     |
| PAGE_URL                                        | Grav URL to current page.                | `/about`                                                     |

## <a name="return-json"></a>Return HTML or JSON

Your external program normally returns HTML code which is inserted in your page.

For some applications this is not enough, because you want to inject [CSS](https://www.w3.org/Style/CSS/) or [Javascript](https://www.w3schools.com/Js/) to your page via Grav. No problem. Return a [JSON](https://json.org/) object which contains the HTML and the URLs to the CSS and JS files.

Schematic JSON object:

```JSON
{
  "html": "HTML-CODE",
  "css": [ "CSS-URL-1", "CSS-URL-2" ],
  "js": [ "JS-URL-1" ]
}
```

`"html"` contains the HTML code inserted to your page.

`"css"` is an array of URLs to CSS files. `"js"` is an array of URLs to JS files. Both values must be an array, even if containing only one value.

`"css"` and `"js"` may contain common external URLs pointing to the Web.
Example: `"js": [ "https://code.jquery.com/jquery-3.5.1.min.js" ]`

**To access local CSS or JS files in the context of Grav, say routes, use special protocol specifiers. Discussed in the next chapter.**

### Routes for CSS and JS files

This chapter is only important, if you return JSON. If the URL starts with `self://`,`plugin://`, `page://` or `grav://` this is substituted.

| PHP Regular Expression Pattern | Replacement                                                  | Example                                   |
| ------------------------------ | ------------------------------------------------------------ | ----------------------------------------- |
| `"~^self://~"`                 | Route to the directory of this plugin. (See: [THIS_PLUGIN_PATH](#THIS_PLUGIN_PATH)) | `/user/plugins/shortcode-external-caller` |
| `"~^plugin://~"`               | Route to the directory of all plugins. (See: [PLUGIN_PATH](#PLUGIN_PATH)) | `/user/plugins`                           |
| `"~^page://~"`                 | Route to the directory of the current page. (See: [PAGE_PATH](#PAGE_PATH)) | `/user/page/08.about`                     |
| `"~^grav://~"`                 | `/` (Slash) – Route to the top level of Grav. This is normally [ROOT_PATH](ROOT_PATH), but Grav may have internally other routes, which may alter this behaviour. | `/`                                       |

To access CSS or JS files in the file space of all plugins use URLs starting with `plugin://`.

If the root path of all plugins is `/var/www/grav_instance/user/plugins/` the location:

```
plugin://shortcode-external-caller/css/sample.css
```

will refer to this route:

```
/user/plugins/shortcode-external-caller/css/sample.css
```

To access CSS or JS files in the file space of the current page starting with `page://`.

If the path to the current page is `/var/www/grav_instance/user/page/08.about` the location:

```
page://css/sample.css
```

will refer to this route:

```
/user/page/08.about/css/sample.css
```

To access CSS or JS files in the file space of Grav use URLs starting with `grav://`.

If the path of the Grav instance is `/var/www/grav_instance` the location:

```
grav://css/sample.css
```

will refer to this route:

```
/css/sample.css
```

**Warning!** Do not misunderstand these helper routes for CSS and JS files with the normal Grav routes. If you enter such a helper route to a markdown page in the browser, you'll go outside the regular Grav routes and neither get any page.

## File paths

### Where to place the external programs?

Your decision.

The working directory is the Root directory of your Grav instance. This in mind, you may use all kinds of path (absolute, relative).

### Path and argument substitutions

The program path and **all** arguments are processed with following replacements. If the program path or argument starts with `self://`, `plugin://`, `page://` or `grav://` this is substituted.

| PHP Regular Expression Pattern | Replacement                                                  |
| ------------------------------ | ------------------------------------------------------------ |
| `"~^self://~"`                 | Directory of this plugin. (See: [THIS_PLUGIN_PATH](#THIS_PLUGIN_PATH)) |
| `"~^plugin://~"`               | Root directory of all plugins. (See: [PLUGIN_PATH](#PLUGIN_PATH)) |
| `"~^page://~"`                 | Directory of the current page. (See: [PAGE_PATH](#PAGE_PATH)) |
| `"~^grav://~"`                 | Root directory of Grav instance. (See: [ROOT_PATH](ROOT_PATH)) |

So, you may create a `external-bin` directory in the root directory of your Grav instance and place programs (shell scripts, etc.) there.

Example: `[external-caller="/bin/sh grav://external-bin/script.sh"]`

Alternatively you may use the existing `bin` directory from this plugin. Which can be found here. (`$ROOT_PATH` is the instance directory of your Grav installation.)

```md
$ROOT_PATH/user/plugins/shortcode-external-caller/bin
```

Refer a sample script by:

```md
[external-caller="/bin/sh self://bin/inspect.sh"]
```

**Please note!** In contrast to the CSS an JS routes (discussed above). These replacements here are concrete file and directory paths. They don't conflict with Grav routes and should always work.

## Examples

### Without closing shortcode

```md
[external-caller="/bin/sh self://bin/inspect.sh"]
```

If you call programs without the closing shortcode the programs gets an empty stdin.

The `inspect.sh` script is [delivered](#inspect-sh) with this plugin.

### Arguments with spaces

```md
[external-caller="/bin/sh self://bin/inspect.sh One Two Argument\ with\ spaces Four"]
```

Escape spaces in arguments with a `\` (backslash).

### Stdin with indentation

```md
[external-caller="/bin/sh self://bin/inspect.sh"]
​```
---
planet: Earth
avenger:
  -
    name: 'Captain America'
    superpower: 'Infinity-Formula-Serum'
  -
    name: 'Iron Man'
    superpower: 'Arc-Reaktor'
...
​```
[/external-caller]
```

Here you see a YAML input. Essential to YAML files is the indentation. The block code fences prevent Grav from processing the stdin as markup.

## Scripts / Programs deployed with this Plugin

### <a name="inspect-sh"></a>inspect.sh

Language: [Bourne Shell](https://en.wikipedia.org/wiki/Bourne_shell).

Outputs all environment variables provided by this plugin, the PATH, the arguments and the stdin.

Call: `[external-caller="/bin/sh self://bin/inspect.sh"]`

Arguments: Optional.

Stdin: Optional.

Output: HTML.

### create-embedded-map.rb

Language: [Ruby](https://www.ruby-lang.org/).

Prerequisite: Gem [redcarpet](https://github.com/vmg/redcarpet)

Creates a map with optional markers.

Call: `[external-caller="ruby self://bin/create-embedded-map.rb"]`

Arguments: None.

Stdin: YAML file with map definitions.

Output: JSON. The JSON output is processed by this plugin. And HTML is placed to the page. This indirection and its use is described [above](#return-json).

For a complete documentation of this program see: [create-embedded-map.md](bin/create-embedded-map.md)