package pixi.texture;

import flash.geom.Rectangle;

class Texture implements ITexture
{
	public static var frameUpdates:Array <Texture> = [];

    public static function fromAsset(id:String):Texture
    {
        return new Texture(TextureBase.fromAsset(id));
    }

	public var frame:Rectangle;
	public var textureBase:TextureBase;
	public var updateFrame:Bool = false;

    public function new(texture:ITexture, ?frame:Rectangle)
    {
        textureBase = Std.is(texture, TextureBase) ? cast texture : (cast texture).textureBase;
        setFrame(frame == null ? new Rectangle(0, 0, textureBase.width, textureBase.height) : frame);
    }

    public function destroy(destroyTextureBase:Bool = false):Void
    {
        if (destroyTextureBase)
            textureBase.destroy();

    	frame = null;
    	textureBase = null;
    }

    public function setFrame(rect:Rectangle):Void
    {
        if (rect.x + rect.width > textureBase.width || rect.y + rect.height > textureBase.height)
            throw "Texture Error: Frame does not fit inside the TextureBase dimensions.";

        frame = rect;
        updateFrame = true;
        frameUpdates.push(this);
    }
}
