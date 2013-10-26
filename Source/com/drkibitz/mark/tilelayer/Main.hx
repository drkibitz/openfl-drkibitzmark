package com.drkibitz.mark.tilelayer;

import aze.display.TileLayer;
import aze.display.TilesheetEx;
import com.drkibitz.mark.common.MarkBase;
import flash.geom.Rectangle;
import flash.geom.Point;

class Main extends MarkBase
{
    private var layer:TileLayer;

    private function this_createMarkObj():MarkObj
    {
        var obj = new MarkObj(layer, "obj");
        layer.addChild(obj);
        return obj;
    }

    override private function init():Void
    {
        scaleX = scaleY = pixelDensity;

        var r:Rectangle = cast objBitmapData.rect.clone();
        var sheet:TilesheetEx = new TilesheetEx(objBitmapData);
        #if flash
        sheet.addDefinition("obj", r, objBitmapData);
        #else
        sheet.addDefinition("obj", r, r, new Point());
        #end

        layer = new TileLayer(sheet, false);
        addChild(layer.view);

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
        }

        layer.render();
    }

    override private function resize():Void
    {
        graphics.beginBitmapFill(bgBitmapData, null, true, false);
        graphics.drawRect(0, 0, dpiWidth, dpiHeight);
        graphics.endFill();
    }
}
