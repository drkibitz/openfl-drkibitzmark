![drkibitz](https://raw.github.com/drkibitz/openfl-drkibitzmark/master/Assets/images/drkibitz48.png "drkibitz") drkibitz Mark
=========

Tests rendering performance using Haxe and Openfl. Based on all the previous versions of the [Bunny Benchmark](http://blog.iainlobb.com/2010/11/display-list-vs-blitting-results.html) by Ian Lobb.

## Running

- If you haven't already, please follow [these directions](http://www.openfl.org/download/) to get [OpenFL](http://www.openfl.org/) up and running.
- Run the following command, where `{target}` is the OpenFL target, and `{IMPLEMENTATION}` is the rendering implementation:

```shell
openfl test {target} -D{IMPLEMENTATION}
```

- Alternatively, open the **project.xml** file and change the following:

```xml
<!-- Default implementation -->
<set name="MARK_BITMAP" />
```
- When your application starts, watch the trace output for stats.

## Implementations

If you have "the most amazing" rendering engine and would like it included, [let me know](https://twitter.com/drkibitz)! Please, just make sure it is compatible with OpenFL. If so, I'll try to make a *mark* for it.

### bitmap

- Define **MARK_BITMAP**
- Use the default display list and Bitmap objects

### blit

- Define **MARK_BLIT**
- Render using one large Bitmap and copyPixels (blitting)

### drawtiles

- Define **MARK_DRAWTILES**
- Render using a Tilesheet, drawList Array, and drawTiles

### pixi

- Define **MARK_PIXI**
- OpenGLView rendering using a very small haxe fork of Pixi.js
- **flash target is incompatible**

### tilelayer

- Define **MARK_TILELAYER**
- Requires [openfl-tilelayer](https://github.com/matthewswallace/openfl-tilelayer). To install run `haxelib install tilelayer`.

## Expected Results

![Screen Shot](https://raw.github.com/drkibitz/openfl-drkibitzmark/master/screenshot.png "Screen Shot")

## Tested Targets

These are just my home tests, and includes my observations of implementation performance from best to worst. I'm not including any numbers (yet). Sorry, please build, watch the stats, and see for yourself.

- **neko**: drawtiles -> tilelayer -> pixi -> blit -> bitmap
- **html5**: pixi -> blit -> drawtiles -> tilelayer -> bitmap
- **mac**: drawtiles -> tilelayer -> pixi -> blit -> bitmap
- **linux**: drawtiles -> tilelayer -> pixi -> blit -> bitmap
- **ios**: drawtiles -> tilelayer -> pixi -> blit -> bitmap
- **flash**: blit -> bitmap -> drawtiles -> tilelayer

## TODO

- Eventually create an [openfl-stage3d](https://github.com/wighawag/openfl-stage3d) mark
- Would like to remove the small fork of Pixi.js and use a proper GL implementation
- May do something with [openfl-pixi](https://github.com/openfl/openfl-pixi), but not sure


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/drkibitz/openfl-drkibitzmark/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

