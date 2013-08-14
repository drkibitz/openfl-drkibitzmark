BunnyMark
=========

Testing rendering performance, based on all the previous versions of the [Bunny Benchmark](http://blog.iainlobb.com/2010/11/display-list-vs-blitting-results.html) by Ian Lobb.

### Prerequisites

- Install [OpenFL](http://www.openfl.org/developer/documentation/get-started/)

### Running

Open the `project.xml` file and change to one of the following:

- Default bitmap display list:

```xml
<app path="Export" file="BunnyMark" main="bunnymark.bitmap.Main" />
```

- Bitmap blitting:

```xml
<app path="Export" file="BunnyMark" main="bunnymark.blit.Main" />
```

- OpenGLView rendering (port of pixi.js):

```xml
<app path="Export" file="BunnyMark" main="bunnymark.pixi.Main" />
```

Then build and run with:
```shell
openfl test {target}
```
