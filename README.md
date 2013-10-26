![drkibitz](https://raw.github.com/drkibitz/openfl-drkibitzmark/master/Assets/images/drkibitz48.png "drkibitz") drkibitz Mark
=========

Testing render performance, based on all the previous versions of the [Bunny Benchmark](http://blog.iainlobb.com/2010/11/display-list-vs-blitting-results.html) by Ian Lobb.

### Prerequisites

- If you haven't already, please follow [these directions](http://www.openfl.org/download/) to get [OpenFL](http://www.openfl.org/) up and running.
- The implementation **MARK_TILELAYER** requires [openfl-tilelayer](https://github.com/matthewswallace/openfl-tilelayer). To install run `haxelib install tilelayer`.

### Implementations

If you have an fantastic rendering engine and would like it included, [let me know](https://twitter.com/drkibitz)! Please, just make sure it is compatible with OpenFL. If so, I'll try to make a *mark* for it.

- Define **MARK_BITMAP** to use the regular display list and Bitmap objects
- Define **MARK_BLIT** to render using one large Bitmap and copyPixels (blitting)
- Define **MARK_DRAWTILES** to render using a Tilesheet, draw list, and drawTiles
- Define **MARK_PIXI** for OpenGLView rendering using a very small haxe fork of Pixi.js
- Define **MARK_TILELAYER** to render using classes from the haxelib openfl-tilelayer

### Running

Run the following command, where `{target}` is the OpenFL target, and `{IMPLEMENTATION}` is the rendering implementation.

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
- ios (Simulator, iPhone 4S, iPhone 5)
- flash (Except MARK_PIXI implementation)

### TODO

- Would like to make a [openfl-stage3d](https://github.com/wighawag/openfl-stage3d) mark
- Would like to remove the small fork of Pixi.js and use a proper GL implementation
- Might do something with [openfl-pixi](https://github.com/openfl/openfl-pixi), but no sure

### Expected Resuilt

![Screen Shot](https://raw.github.com/drkibitz/openfl-drkibitzmark/master/screenshot.png "Screen Shot")
