package pixi.renderer.gl;

import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl.utils.Int16Array;
import pixi.display.DisplayObject;
import pixi.texture.TextureBase;

class GLRenderBatch
{
    private static var _glBatches:Array <GLRenderBatch> = [];

    private static function _refreshBatch(glBatch:GLRenderBatch):Void
    {
        if (glBatch.dynamicSize < glBatch.size) {
            glBatch.growBatch();
        }

        var indexRun:Int = 0;
        var worldTransform, width, height, aX, aY, w0, w1, h0, h1, index;
        var a, b, c, d, tx, ty;

        var current = glBatch.head;
        var displayObject:DisplayObject = cast current;

        while (displayObject != null) {
            index = indexRun * 8;

            var texture = current.texture;

            var frame = texture.frame;
            var tw = texture.textureBase.width;
            var th = texture.textureBase.height;

            glBatch.uvs[index + 0] = frame.x / tw;
            glBatch.uvs[index + 1] = frame.y / th;

            glBatch.uvs[index + 2] = (frame.x + frame.width) / tw;
            glBatch.uvs[index + 3] = frame.y / th;

            glBatch.uvs[index + 4] = (frame.x + frame.width) / tw;
            glBatch.uvs[index + 5] = (frame.y + frame.height) / th;

            glBatch.uvs[index + 6] = frame.x / tw;
            glBatch.uvs[index + 7] = (frame.y + frame.height) / th;

            current.updateFrame = false;

            var colorIndex:Int = indexRun * 4;
            glBatch.colors[colorIndex] =
                glBatch.colors[colorIndex + 1] =
                glBatch.colors[colorIndex + 2] =
                glBatch.colors[colorIndex + 3] = displayObject.worldAlpha;

            current = current.__texturedNext;
            displayObject = cast current;
            indexRun ++;
        }

        glBatch.dirtyUvs = true;
        glBatch.dirtyColors = true;
    }

    private static function _updateBatch(glBatch:GLRenderBatch):Void
    {
        var worldTransform, width, height, aX, aY, w0, w1, h0, h1, index, index2, index3;

        var a, b, c, d, tx, ty;

        var indexRun = 0;

        var current = glBatch.head;
        var displayObject:DisplayObject = cast current;

        while (displayObject != null) {
            if (displayObject.worldVisible) {
                width = current.texture.frame.width;
                height = current.texture.frame.height;

                aX = displayObject.pivot.x;
                aY = displayObject.pivot.y;
                w0 = width * (1-aX);
                w1 = width * -aX;

                h0 = height * (1-aY);
                h1 = height * -aY;

                index = indexRun * 8;

                worldTransform = displayObject.worldTransform;

                a = worldTransform[0];
                b = worldTransform[3];
                c = worldTransform[1];
                d = worldTransform[4];
                tx = worldTransform[2];
                ty = worldTransform[5];

                glBatch.verticies[index + 0] = a * w1 + c * h1 + tx;
                glBatch.verticies[index + 1] = d * h1 + b * w1 + ty;

                glBatch.verticies[index + 2] = a * w0 + c * h1 + tx;
                glBatch.verticies[index + 3] = d * h1 + b * w0 + ty;

                glBatch.verticies[index + 4] = a * w0 + c * h0 + tx;
                glBatch.verticies[index + 5] = d * h0 + b * w0 + ty;

                glBatch.verticies[index + 6] =  a * w1 + c * h0 + tx;
                glBatch.verticies[index + 7] =  d * h0 + b * w1 + ty;

                if (current.updateFrame || current.texture.updateFrame) {
                    glBatch.dirtyUvs = true;

                    var texture = current.texture;

                    var frame = texture.frame;
                    var tw = texture.textureBase.width;
                    var th = texture.textureBase.height;

                    glBatch.uvs[index + 0] = frame.x / tw;
                    glBatch.uvs[index + 1] = frame.y / th;

                    glBatch.uvs[index + 2] = (frame.x + frame.width) / tw;
                    glBatch.uvs[index + 3] = frame.y / th;

                    glBatch.uvs[index + 4] = (frame.x + frame.width) / tw;
                    glBatch.uvs[index + 5] = (frame.y + frame.height) / th;

                    glBatch.uvs[index + 6] = frame.x / tw;
                    glBatch.uvs[index + 7] = (frame.y + frame.height) / th;

                    current.updateFrame = false;
                }

                // TODO this probably could do with some optimisation....
                if (displayObject._prevAlpha != displayObject.worldAlpha) {
                    displayObject._prevAlpha = displayObject.worldAlpha;

                    var colorIndex = indexRun * 4;
                    glBatch.colors[colorIndex] =
                        glBatch.colors[colorIndex + 1] =
                        glBatch.colors[colorIndex + 2] =
                        glBatch.colors[colorIndex + 3] = displayObject.worldAlpha;
                    glBatch.dirtyColors = true;
                }
            } else {
                index = indexRun * 8;

                glBatch.verticies[index + 0] = 0;
                glBatch.verticies[index + 1] = 0;

                glBatch.verticies[index + 2] = 0;
                glBatch.verticies[index + 3] = 0;

                glBatch.verticies[index + 4] = 0;
                glBatch.verticies[index + 5] = 0;

                glBatch.verticies[index + 6] = 0;
                glBatch.verticies[index + 7] = 0;
            }

            indexRun++;
            current = current.__texturedNext;
            displayObject = cast current;
       }
    }

    public static function getBatch():GLRenderBatch
    {
        if (_glBatches.length == 0) {
            return new GLRenderBatch();
        } else {
            return _glBatches.pop();
        }
    }

    public static function returnBatch(glBatch:GLRenderBatch):Void
    {
        glBatch.clean();
        _glBatches.push(glBatch);
    }

    public var dirty:Bool = false;
    public var dirtyColors:Bool = false;
    public var dirtyUvs:Bool = false;
    public var dynamicSize:Int = 1;
    public var size:Int = 0;

    public var texture:TextureBase;
    public var head:ITextured;
    public var tail:ITextured;

    public var colors:Array <Float>;
    public var indices:Array <Int>;
    public var uvs:Array <Float>;
    public var verticies:Array <Float>;

    public var glBufferColor:GLBuffer;
    public var glBufferIndex:GLBuffer;
    public var glBufferUv:GLBuffer;
    public var glBufferVertex:GLBuffer;

    public function new()
    {
        this.glBufferColor = GL.createBuffer();
        this.glBufferIndex = GL.createBuffer();
        this.glBufferUv = GL.createBuffer();
        this.glBufferVertex = GL.createBuffer();
    }

    public function clean():Void
    {
        this.dynamicSize = 1;
        this.size = 0;
        this.texture = null;
        this.head = null;
        this.tail = null;

        this.verticies = [];
        for (i in 0...this.dynamicSize * 8) this.verticies[i] = 0.0; // preallocate
        this.uvs = [];
        for (i in 0...this.dynamicSize * 8) this.uvs[i] = 0.0; // preallocate
        this.indices = [];
        for (i in 0...this.dynamicSize * 6) this.indices[i] = 0; // preallocate
        this.colors = [];
        for (i in 0...this.dynamicSize * 4) this.colors[i] = 0.0; // preallocate
    }

    public function init(current:ITextured):Void
    {
        current.__glBatch = this;
        this.dirty = true;
        this.texture = current.texture.textureBase;
        this.head = current;
        this.tail = current;
        this.size = 1;
        this.growBatch();
    }

    public function insertBefore(current:ITextured, next:ITextured):Void
    {
        this.size++;

        current.__glBatch = this;
        this.dirty = true;
        var tempPrev = next.__texturedPrev;
        next.__texturedPrev = current;
        current.__texturedNext = next;

        if (tempPrev != null) {
            current.__texturedPrev = tempPrev;
            tempPrev.__texturedNext = current;
        } else {
            this.head = current;
        }
    }

    public function insertAfter(current:ITextured, previous:ITextured):Void
    {
        this.size++;

        current.__glBatch = this;
        this.dirty = true;

        var tempNext = previous.__texturedNext;
        previous.__texturedNext = current;
        current.__texturedPrev = previous;

        if (tempNext != null) {
            current.__texturedNext = tempNext;
            tempNext.__texturedPrev = current;
        } else {
            this.tail = current;
        }
    };

    public function remove(current:ITextured):Void
    {
        this.size--;

        if (this.size == 0) {
            current.__glBatch = null;
            current.__texturedPrev = null;
            current.__texturedNext = null;
            return;
        }

        if (current.__texturedPrev != null) {
            current.__texturedPrev.__texturedNext = current.__texturedNext;
        } else {
            this.head = current.__texturedNext;
            this.head.__texturedPrev = null;
        }

        if (current.__texturedNext != null) {
            current.__texturedNext.__texturedPrev = current.__texturedPrev;
        } else {
            this.tail = current.__texturedPrev;
            this.tail.__texturedNext = null;
        }

        current.__glBatch = null;
        current.__texturedNext = null;
        current.__texturedPrev = null;
        this.dirty = true;
    }

    public function split(current:ITextured):GLRenderBatch
    {
        this.dirty = true;

        var glBatch = new GLRenderBatch();
        glBatch.init(current);
        glBatch.texture = this.texture;
        glBatch.tail = this.tail;

        this.tail = current.__texturedPrev;
        this.tail.__texturedNext = null;

        current.__texturedPrev = null;
        // return a split glBatch!
        //current.__texturedPrev.__texturedNext = null;
        //current.__texturedPrev = null;

        // TODO this size is wrong!
        // need to recalculate :/ problem with a linked list!
        // unless it gets calculated in the "clean"?

        // need to loop through items as there is no way to know the length on a linked list :/
        var tempSize = 0;
        while (current != null) {
            tempSize++;
            current.__glBatch = glBatch;
            current = current.__texturedNext;
        }

        glBatch.size = tempSize;
        this.size -= tempSize;

        return glBatch;
    }

    public function merge(glBatch:GLRenderBatch):Void
    {
        this.dirty = true;

        this.tail.__texturedNext = glBatch.head;
        glBatch.head.__texturedPrev = this.tail;

        this.size += glBatch.size;

        this.tail = glBatch.tail;

        var current = glBatch.head;
        while (current != null) {
            current.__glBatch = this;
            current = current.__texturedNext;
        }
    }

    public function growBatch():Void
    {
        if (this.size == 1) {
            this.dynamicSize = 1;
        } else {
            this.dynamicSize = Math.round(this.size * 1.5);
        }

        // init and upload verticies
        this.verticies = [];
        for (i in 0...this.dynamicSize * 8) this.verticies[i] = 0.0; // preallocate
        GL.bindBuffer(GL.ARRAY_BUFFER, this.glBufferVertex);
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(this.verticies), GL.DYNAMIC_DRAW);

        // init and upload uvs
        this.uvs = [];
        for (i in 0...this.dynamicSize * 8) this.uvs[i] = 0.0; // preallocate
        GL.bindBuffer(GL.ARRAY_BUFFER, this.glBufferUv);
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(this.uvs), GL.DYNAMIC_DRAW);

        this.dirtyUvs = true;

        // init and upload colors
        this.colors = [];
        for (i in 0...this.dynamicSize * 4) this.colors[i] = 0.0; // preallocate
        GL.bindBuffer(GL.ARRAY_BUFFER, this.glBufferColor);
        GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(this.colors), GL.DYNAMIC_DRAW);

        this.dirtyColors = true;

        // init and upload indices
        this.indices = [];
        for (i in 0...this.dynamicSize * 6) this.indices[i] = 0; // preallocate
        var length = this.indices.length / 6;

        var i:Int = 0;
        while (i < length) {
            var index2 = i * 6;
            var index3 = i * 4;
            this.indices[index2 + 0] = index3 + 0;
            this.indices[index2 + 1] = index3 + 1;
            this.indices[index2 + 2] = index3 + 2;
            this.indices[index2 + 3] = index3 + 0;
            this.indices[index2 + 4] = index3 + 2;
            this.indices[index2 + 5] = index3 + 3;
            i++;
        };

        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.glBufferIndex);
        // TODO: Int16Array is the only thing I have to work with
        // This should really be unsigned
        GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(this.indices), GL.STATIC_DRAW);
    }

    public function render(renderer:GLRenderer, start:Int = 0, ?end:Int):Void
    {
        if (this.dirty) {
            _refreshBatch(this);
            this.dirty = false;
        }

        if (this.size == 0) return;

        _updateBatch(this);

        // TODO optimize this!
        // Is this even needed since this is already called in the renderer method?
        GL.useProgram(renderer.glShaderProgram.glProgram);

        // update verticies
        GL.bindBuffer(GL.ARRAY_BUFFER, this.glBufferVertex);
        GL.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(this.verticies));
        GL.vertexAttribPointer(renderer.glShaderProgram.vertexPositionAttribute, 2, GL.FLOAT, false, 0, 0);

        // update uvs
        GL.bindBuffer(GL.ARRAY_BUFFER, this.glBufferUv);
        if (this.dirtyUvs) {
            this.dirtyUvs = false;
            GL.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(this.uvs));
        }

        GL.vertexAttribPointer(renderer.glShaderProgram.textureCoordAttribute, 2, GL.FLOAT, false, 0, 0);
        GL.activeTexture(GL.TEXTURE0);
        GL.bindTexture(GL.TEXTURE_2D, this.texture.glTexture);

        // update colors
        GL.bindBuffer(GL.ARRAY_BUFFER, this.glBufferColor);
        if (this.dirtyColors) {
            this.dirtyColors = false;
            GL.bufferSubData(GL.ARRAY_BUFFER, 0, new Float32Array(this.colors));
        }

        // dont need to upload!
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, this.glBufferIndex);

        // DRAW!
        if (end == null) end = this.size;
        var len:Int = end - start;
        GL.drawElements(GL.TRIANGLES, len * 6, GL.UNSIGNED_SHORT, start * 2 * 6);
    }
}
