drkibitz Mark
=========

Testing render performance, based on all the previous versions of the [Bunny Benchmark](http://blog.iainlobb.com/2010/11/display-list-vs-blitting-results.html) by Ian Lobb.

### Prerequisites

- If you haven't already, please follow [these directions](http://www.openfl.org/download/) to get [OpenFL](http://www.openfl.org/) up and running.
- The implementation **MARK_TILELAYER** requires [openfl-tilelayer](https://github.com/matthewswallace/openfl-tilelayer). To install run `haxelib install tilelayer`.

### Implementations

Upon building:

- Define **MARK_BITMAP** to use the regular display list and Bitmap objects
- Define **MARK_BLIT** to render using one large bitmap and copyPixels (blitting)
- Define **MARK_DRAWTILES** to render using a tilesheet, draw list, and drawTiles
- Define **MARK_PIXI** for OpenGLView rendering using a very small haxe fork of Pixi.js
- Define **MARK_TILELAYER** to render using classes from the haxelib openfl-tilelayer

Please reference the filename and/or title of your compiled app if you are unsure what was built.

### Running

Open a terminal and run the following, where `{target}` is your chosen OpenFL target, and `{IMPLEMENTATION}` is the chosen rendering implementation.

```shell
openfl test {target} -D{IMPLEMENTATION}
```

Or open the **project.xml** file and change the following:

```xml
<!-- Default implementation -->
<set name="MARK_BITMAP" />
```
### Tested Targets

- neko
- html5 (View browser console for stats)
- mac (64)
- linux (64)
- ios
- flash (Except MARK_PIXI implementation)
