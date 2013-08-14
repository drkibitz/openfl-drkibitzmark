package pixi.renderer.gl;

import pixi.renderer.gl.GLRenderBatch;
import pixi.texture.Texture;

interface ITextured
{
    public var __glBatch:GLRenderBatch; // public protected
    public var __texturedNext:ITextured; // public protected
    public var __texturedPrev:ITextured; // public protected

    public var texture:Texture;
    public var updateFrame:Bool;
}
