package com.drkibitz.mark.blit;

import com.drkibitz.mark.common.MarkBase;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.events.Event;

class Main extends MarkBase
{
    private var bitmap:Bitmap;

    private function this_createMarkObj():MarkObj
    {
        return new MarkObj();
    }

    override private function init():Void
    {
        bitmap = new Bitmap(new BitmapData(dpiWidth, dpiHeight), PixelSnapping.ALWAYS, false);
        addChild(bitmap);

        scaleX = scaleY = pixelDensity;

        createMarkObj = this_createMarkObj;

        super.init();
    }

    override private function render():Void
    {
        bitmap.bitmapData.lock();
        bitmap.bitmapData.fillRect(bitmap.bitmapData.rect, 0);

        for (i in 0...numOfMarkObjs) {
            var obj:MarkObj = cast markObjs[i];
            var x:Float = obj.x;
            var y:Float = obj.y;

            x += obj.speedX;
            y += obj.speedY;
            obj.speedY += gravity;

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

            bitmap.bitmapData.copyPixels(
                markObjBitmapData,
                markObjBitmapData.rect,
                obj, null, null, true);
        }

        bitmap.bitmapData.unlock();
    }

    override private function resize():Void
    {
        graphics.beginBitmapFill(patternBitmapData, null, true, false);
        graphics.drawRect(0, 0, dpiWidth, dpiHeight);
        graphics.endFill();
        bitmap.bitmapData = new BitmapData(dpiWidth, dpiHeight);
    }
}
