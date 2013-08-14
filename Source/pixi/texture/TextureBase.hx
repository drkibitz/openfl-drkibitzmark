package pixi.texture;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.utils.UInt8Array;
import openfl.Assets;

class TextureBase implements ITexture
{
    private static var textureBaseCache:Map <String, TextureBase> = new Map <String, TextureBase>();

    public static var toUpdate:Array <TextureBase> = [];
    public static var toDestroy:Array <TextureBase> = [];

    public static function fromAsset(id:String):TextureBase
    {
        if (textureBaseCache.exists(id)) {
            return textureBaseCache.get(id);
        }
        var instance = new TextureBase(Assets.getBitmapData(id));
        textureBaseCache.set(id, instance);
        return instance;
    }

    public var glTexture:GLTexture;
    public var height:Int;
    public var width:Int;
    public var source:UInt8Array;

    public function new(bitmapData:BitmapData)
    {
        source = new UInt8Array(BitmapData.getRGBAPixels(bitmapData));
        glTexture = GL.createTexture();
        height = bitmapData.height;
        width = bitmapData.width;
        toUpdate.push(this);
    }

    public function destroy():Void
    {
        cast(source,ByteArray).clear();
        source = null;
        toDestroy.push(this);
    }
}
