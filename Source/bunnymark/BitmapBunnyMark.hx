package bunnymark;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.Vector;
import openfl.Assets;

class BitmapBunnyMark extends Sprite {

    private var amount:Int = 10;
    private var bunnies:Vector <BitmapBunny>;
    private var container:Sprite;
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

        bunnies = new Vector <BitmapBunny> ();
        container = new Sprite ();
        maxX = stage.stageWidth - 26;
        maxY = stage.stageHeight - 37;
        wabbitTexture = Assets.getBitmapData ("images/bunny.png");

        for (i in 0...numOfBunniesStart) {
            addBunny();
        }
        addChild (container);

        stage.addEventListener (MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.addEventListener (MouseEvent.MOUSE_UP, stage_onMouseUp);
        stage.addEventListener (Event.RESIZE, stage_onResize);
        addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
    }

    private function addBunny ():Void
    {
        var bunny:BitmapBunny = new BitmapBunny(
            wabbitTexture,
            Math.random() * 10,
            (Math.random() * 10) - 5
        );
        bunnies[numOfBunnies] = bunny;
        container.addChild(bunny);
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

        i = 0;
        while(i < numOfBunnies) {
            var bunny:BitmapBunny = bunnies[i];

            bunny.x += bunny.speed.x;
            bunny.y += bunny.speed.y;
            bunny.speed.y += gravity;

            if (bunny.x > maxX) {
                bunny.speed.x *= -1;
                bunny.x = maxX;
            } else if (bunny.x < minX) {
                bunny.speed.x *= -1;
                bunny.x = minX;
            }

            if (bunny.y > maxY) {
                bunny.speed.y *= -0.85;
                bunny.y = maxY;
                if (Math.random() > 0.5) {
                    bunny.speed.y -= Math.random() * 6;
                }
            } else if (bunny.y < minY) {
                bunny.speed.y = 0;
                bunny.y = minY;
            }

            i++;
        }
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
