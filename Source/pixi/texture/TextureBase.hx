package pixi.texture;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.Assets;
#if html5
import js.html.Uint8Array;
#else
import openfl.utils.UInt8Array;
#end

import openfl.utils.*;

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

    public var glTexture:GLTexture = null;
    public var height:Int;
    public var width:Int;
    #if html5
    public var source:Uint8Array;
    #else
    public var source:UInt8Array;
    #end

    public function new(bitmapData:BitmapData)
    {
        #if html5
        var p = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
        source = new Uint8Array(p.length);
        p.position = 0;
        var i:UInt = 0;
        while (p.position < p.length) {
            source[i] = p.readUnsignedByte();
            i++;
        }
        #else
        source = new UInt8Array(BitmapData.getRGBAPixels(bitmapData));
        #end
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
