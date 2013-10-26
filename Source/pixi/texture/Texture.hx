package pixi.texture;

import flash.geom.Rectangle;

class Texture implements ITexture
{
    public static var frameUpdates:Array <Texture> = [];

    public static function fromAsset(id:String, ?useCache:Bool, ?frameRect:Rectangle):Texture
    {
        return new Texture(TextureBase.fromAsset(id, useCache), frameRect);
    }

    public var frame(default,set):Rectangle;
    public var textureBase:TextureBase;
    public var updateFrame:Bool = false;
    public var width(get,set):Float;
    public var height(get,set):Float;

    public function new(texture:ITexture, ?frameRect:Rectangle)
    {
        textureBase = Std.is(texture, TextureBase) ? cast texture : (cast texture).textureBase;
        frame = (frameRect == null) ? new Rectangle(0, 0, textureBase.width, textureBase.height) : frameRect;
    }

    public function destroy(destroyTextureBase:Bool = false):Void
    {
        if (destroyTextureBase)
            textureBase.destroy();

        frame = null;
        textureBase = null;
    }

    public function set_frame(rect:Rectangle):Rectangle
    {
        // if (rect.x + rect.width > textureBase.width || rect.y + rect.height > textureBase.height)
            // throw "Texture Error: Frame does not fit inside the TextureBase dimensions.";

        frame = rect;
        updateFrame = true;
        frameUpdates.push(this);
        return frame;
    }

    public function get_width():Float
    {
        return frame.width;
    }

    public function set_width(value:Float):Float
    {
        return frame.width = value;
    }

    public function get_height():Float
    {
        return frame.height;
    }

    public function set_height(value:Float):Float
    {
        return frame.height = value;
    }
}
