package bunnymark;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.Vector;
import openfl.Assets;

class BlitBunnyMark extends Sprite {

    private var amount:Int = 10;
    private var bunnies:Vector <BlitBunny>;
    private var bitmap:Bitmap;
    private var gravity:Float = 0.75;
    private var isAdding:Bool = false;
    private var maxX:Int;
    private var maxY:Int;
    private var minX:Int = 0;
    private var minY:Int = 0;
    private var numOfBunnies:Int = 0;
    private var numOfBunniesStart:Int = 10;
    private var wabbitTexture:BitmapData;

    public function new ()
    {
        super ();

        bunnies = new Vector <BlitBunny> ();
        maxX = stage.stageWidth - 26;
        maxY = stage.stageHeight - 37;
        wabbitTexture = Assets.getBitmapData ("images/bunny.png");

        bitmap = new Bitmap(new BitmapData(maxX + 26, maxY + 37));
        addChild(bitmap);

        for (i in 0...numOfBunniesStart) {
            addBunny();
        }

        stage.addEventListener (MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.addEventListener (MouseEvent.MOUSE_UP, stage_onMouseUp);
        stage.addEventListener (Event.RESIZE, stage_onResize);
        addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
    }

    private function addBunny ():Void
    {
        var bunny:BlitBunny = new BlitBunny(
            wabbitTexture,
            Math.random() * 10,
            (Math.random() * 10) - 5
        );
        bunnies[numOfBunnies] = bunny;
        numOfBunnies++;
    }

    // Event Handlers

    private function this_onEnterFrame (event:Event):Void
    {
        var i:Int;

        if (isAdding && amount > 0) {
            // add 10 at a time :)
            i = 0;
            while(i < amount) {
                addBunny();
                i++;
            }
            if (numOfBunnies >= 16500) {
                amount = 0;
            }
            trace(numOfBunnies + ' BUNNIES');
        }

        bitmap.bitmapData.lock();
        bitmap.bitmapData.fillRect(new Rectangle(0, 0, maxX + 26, maxY + 37), 0);
        var sourceRect:Rectangle = new Rectangle(0, 0, 26, 37);

        i = 0;
        while(i < numOfBunnies) {
            var bunny:BlitBunny = bunnies[i];

            bunny.position.x += bunny.speed.x;
            bunny.position.y += bunny.speed.y;
            bunny.speed.y += gravity;

            if (bunny.position.x > maxX) {
                bunny.speed.x *= -1;
                bunny.position.x = maxX;
            } else if (bunny.position.x < minX) {
                bunny.speed.x *= -1;
                bunny.position.x = minX;
            }

            if (bunny.position.y > maxY) {
                bunny.speed.y *= -0.85;
                bunny.position.y = maxY;
                if (Math.random() > 0.5) {
                    bunny.speed.y -= Math.random() * 6;
                }
            } else if (bunny.position.y < minY) {
                bunny.speed.y = 0;
                bunny.position.y = minY;
            }
            bitmap.bitmapData.copyPixels(bunny.bitmapData, sourceRect, bunny.position, null, null, true);

            i++;
        }

        bitmap.bitmapData.unlock();
    }

    private function stage_onMouseDown (event:MouseEvent):Void
    {
        isAdding = true;
    }

    private function stage_onMouseUp (event:MouseEvent):Void
    {
        isAdding = false;
    }

    private function stage_onResize (event:Event):Void
    {
        maxX = stage.stageWidth - 26;
        maxY = stage.stageHeight - 37;
    }
}
