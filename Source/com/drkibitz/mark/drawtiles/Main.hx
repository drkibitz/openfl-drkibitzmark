package com.drkibitz.mark.drawtiles;

import com.drkibitz.mark.common.MarkBase;
import flash.display.Shape;
import flash.geom.Rectangle;
import openfl.display.Tilesheet;

class Main extends MarkBase
{
    private static inline var TILE_FIELDS:Int = 3;

    private var drawList:Array<Float>;
    private var smooth:Bool = false;
    private var shape:Shape;
    private var tilesheet:Tilesheet;

    private function this_createMarkObj():MarkObj
    {
        return new MarkObj();
    }

    override private function init():Void
    {
        drawList = new Array<Float>();
        shape = new Shape();
        addChild(shape);
        tilesheet = new Tilesheet(markObjBitmapData);
        tilesheet.addTileRect(
            new Rectangle(0, 0, markObjBitmapData.width, markObjBitmapData.height));

        scaleX = scaleY = pixelDensity;

        createMarkObj = this_createMarkObj;

        super.init();
    }

    override private function render():Void
    {
        for (i in 0...numOfMarkObjs) {
            var obj:MarkObj = cast markObjs[i];
            var x:Float = obj.x;
            var y:Float = obj.y;

            x += obj.speedX * MarkBase.TIME_SCALE;
            y += obj.speedY * MarkBase.TIME_SCALE;
            obj.speedY += MarkBase.GRAVITY * MarkBase.TIME_SCALE;

            if (x > maxX) {
                obj.speedX *= -1;
                x = maxX;
            } else if (x < minX) {
                obj.speedX *= -1;
                x = minX;
            }

            if (y > maxY) {
                obj.speedY *= -0.85;
                y = maxY;
                if (Math.random() > 0.5) {
                    obj.speedY -= Math.random() * 6;
                }
            } else if (y < minY) {
                obj.speedY = 0;
                y = minY;
            }

            obj.x = x;
            obj.y = y;

            var index = i * TILE_FIELDS;
            drawList[index] = Math.round(x); // snap
            drawList[index + 1] = Math.round(y); // snap
            drawList[index + 2] = 0; // obj index
            // drawList[index + 3] = obj.scale;
            // drawList[index + 4] = obj.rotation;
            // drawList[index + 5] = obj.alpha;
        }

        shape.graphics.clear();
        tilesheet.drawTiles(shape.graphics, drawList, smooth);
    }

    override private function resize():Void
    {
        graphics.beginBitmapFill(patternBitmapData, null, true, false);
        graphics.drawRect(0, 0, dpiWidth, dpiHeight);
        graphics.endFill();
    }
}

