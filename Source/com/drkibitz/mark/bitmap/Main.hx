package com.drkibitz.mark.bitmap;

import com.drkibitz.mark.common.MarkBase;
import flash.display.PixelSnapping;

class Main extends MarkBase
{
    private function this_createMarkObj():MarkObj
    {
        var obj = new MarkObj(objBitmapData, PixelSnapping.ALWAYS, false);
        addChild(obj);
        return obj;
    }

    override private function init():Void
    {
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
        }
    }

    override private function resize():Void
    {
        graphics.beginBitmapFill(bgBitmapData, null, true, false);
        graphics.drawRect(0, 0, dpiWidth, dpiHeight);
        graphics.endFill();
    }
}
