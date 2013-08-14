package pixi.renderer.gl;

import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.gl.GL;
import pixi.display.Scene;
import pixi.texture.Texture;
import pixi.texture.TextureBase;

class GLRenderer
{
    private static function _updateTextureBase(textureBase:TextureBase):Void
    {
        GL.bindTexture(GL.TEXTURE_2D, textureBase.glTexture);
        #if html5
        GL.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
        #end

        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, textureBase.width, textureBase.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, textureBase.source);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR); // or GL.NEAREST
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR); // or GL.NEAREST

        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);

        GL.bindTexture(GL.TEXTURE_2D, null);
    }

    private static function _destroyTextureBase(textureBase:TextureBase):Void
    {
        GL.deleteTexture(textureBase.glTexture);
        textureBase.glTexture = null;
    }

    public var height:Int;
    public var width:Int;
    public var projection:Point;
    public var glShaderProgram:GLShaderProgram;
    public var sceneGLRenderGroup:GLRenderGroup;

    public function new()
    {
        // Compile
        glShaderProgram = new GLShaderProgram();

        // Activate
        GL.enableVertexAttribArray(glShaderProgram.vertexPositionAttribute);
        GL.enableVertexAttribArray(glShaderProgram.textureCoordAttribute);

        GL.disable(GL.DEPTH_TEST);
        GL.disable(GL.CULL_FACE);
        GL.enable(GL.BLEND);

        projection = new Point();
        sceneGLRenderGroup = new GLRenderGroup();
    }

    public function render(rect:Rectangle, scene:Scene):Void
    {
        // if rendering a new scene clear the glBatches..
        if (sceneGLRenderGroup.root != scene)
            sceneGLRenderGroup.setRenderable(scene);

        updateTextures();
        // update the scene graph
        //if (scene._dirtyTransform)
            scene.updateTransform();

        GL.viewport(Std.int(rect.x), Std.int(rect.y), Std.int(rect.width), Std.int(rect.height));
        // GL.bindFramebuffer(GL.FRAMEBUFFER, null);

        projection.x = rect.width / 2;
        projection.y = rect.height / 2;
        GL.useProgram(glShaderProgram.glProgram);
        GL.uniform2f(glShaderProgram.projectionVector, projection.x, projection.y);

        #if html5
        GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
        #end

        sceneGLRenderGroup.render(this);

        // after rendering lets confirm all frames that have been uodated..
        if (Texture.frameUpdates.length > 0) {
            for (texture in Texture.frameUpdates) {
                texture.updateFrame = false;
            }
            Texture.frameUpdates = [];
        }
    }

    public function updateTextures():Void
    {
        for (toUpdate in TextureBase.toUpdate)
            _updateTextureBase(toUpdate);
        for (toDestroy in TextureBase.toDestroy)
            _destroyTextureBase(toDestroy);
        TextureBase.toUpdate = [];
        TextureBase.toDestroy = [];
    }
}
