package pixi.display;

import pixi.renderer.gl.ITextured;
import pixi.renderer.gl.GLRenderBatch;
import pixi.texture.Texture;

class Sprite extends DisplayObjectContainer implements ITextured
{
    public var __glBatch:GLRenderBatch;
    public var __texturedNext:ITextured;
    public var __texturedPrev:ITextured;
    public var texture:Texture;
    public var updateFrame:Bool = true;

    public var height(get,set):Float;
    public var width(get,set):Float;

    private var _width:Float = 0;
    private var _height:Float = 0;

    public function new(texture:Texture)
    {
        super();
        this.renderable = true;
        this.texture = texture;
    }

    private function get_width():Float
    {
        return _width;
    }

    private function set_width(value:Float):Float
    {
        this.scale.x = value / this.texture.frame.width;
        return _width = value;
    }

    private function get_height():Float
    {
        return _height;
    }

    private function set_height(value:Float):Float
    {
        this.scale.y = value / this.texture.frame.height;
        return _height = value;
    }
}
