package pixi.display;

import flash.geom.Point;
// import openfl.utils.UInt8Array;
import pixi.geom.Mat3;
import pixi.renderer.gl.GLRenderGroup;

class DisplayObject
{
    public var __glRenderGroup:GLRenderGroup; // public protected

    // linked list
    public var last:DisplayObject = null;
    public var first:DisplayObject = null;
    public var _iNext:DisplayObject = null;
    public var _iPrev:DisplayObject = null;

    // display list
    public var parent:DisplayObjectContainer = null;
    public var scene:Scene = null;

    // color & visibility
    public var alpha:Float = 1;
    // public var color:UInt8Array;
    public var visible:Bool = true;
    public var renderable:Bool = false;
    public var worldAlpha:Float = 1;
    public var worldVisible:Bool = false;

    // transform
    public var pivot:Point;
    public var position:Point;
    public var scale:Point;
    public var rotation:Float = 0;
    public var worldTransform:Array <Float>;
    public var localTransform:Array <Float>;
    //public var _dirtyTransform:Bool = true;

    // caches
    public var _prevAlpha:Float = -1;

    private var _prevRotation:Float = -1;
    private var _sr:Float = 0;
    private var _cr:Float = 1;

    public function new()
    {
        // linked list
        last = this;
        first = this;

        // color & visibility
        //color = new UInt8Array();

        // transform
        pivot = new Point();
        position = new Point();
        scale = new Point(1, 1);
        worldTransform = Mat3.create();
        localTransform = Mat3.create();
    }

    public function updateTransform():Void
    {
        if (!visible) return;

        // TODO OPTIMIZE THIS!! with dirty
        if (rotation != _prevRotation) {
            _prevRotation = rotation;
            _sr = Math.sin(rotation);
            _cr = Math.cos(rotation);
        }

        localTransform[0] = _cr * scale.x;
        localTransform[1] = -_sr * scale.y;
        localTransform[3] = _sr * scale.x;
        localTransform[4] = _cr * scale.y;

        // TODO --> do we even need a local matrix???

        var px = pivot.x;
        var py = pivot.y;
        var parentTransform = parent.worldTransform;

        // Cache the matrix values (makes for huge speed increases!)
        var a00 = localTransform[0],
            a01 = localTransform[1],
            a02 = position.x - localTransform[0] * px - py * localTransform[1],
            a10 = localTransform[3],
            a11 = localTransform[4],
            a12 = position.y - localTransform[4] * py - px * localTransform[3],

            b00 = parentTransform[0],
            b01 = parentTransform[1],
            b02 = parentTransform[2],
            b10 = parentTransform[3],
            b11 = parentTransform[4],
            b12 = parentTransform[5];

        localTransform[2] = a02;
        localTransform[5] = a12;

        worldTransform[0] = b00 * a00 + b01 * a10;
        worldTransform[1] = b00 * a01 + b01 * a11;
        worldTransform[2] = b00 * a02 + b01 * a12 + b02;

        worldTransform[3] = b10 * a00 + b11 * a10;
        worldTransform[4] = b10 * a01 + b11 * a11;
        worldTransform[5] = b10 * a02 + b11 * a12 + b12;

        worldAlpha = alpha * parent.worldAlpha;
        //_dirtyTransform = false;
    }
}
