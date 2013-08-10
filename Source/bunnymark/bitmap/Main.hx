package bunnymark.bitmap;

import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import openfl.Assets;

import bunnymark.Fps;

class Main extends Sprite
{
    private var amount:Int = 10;
    private var bunnies:Array <Bunny>;
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

    public function new()
    {
        super();

        bunnies = new Array <Bunny>();
        container = new Sprite ();
        maxX = stage.stageWidth - 26;
        maxY = stage.stageHeight - 37;
        wabbitTexture = Assets.getBitmapData("images/bunny.png");

        for (i in 0...numOfBunniesStart) {
            addBunny();
        }

        addChild(container);
        addChild(new Fps());

        stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
        stage.addEventListener(Event.RESIZE, stage_onResize);
        addEventListener(Event.ENTER_FRAME, this_onEnterFrame);
    }

    private function addBunny ():Void
    {
        var bunny:Bunny = new Bunny(wabbitTexture, PixelSnapping.ALWAYS, false);
        bunny.speedX = Math.random() * 10;
        bunny.speedY = (Math.random() * 10) - 5;
        bunnies[numOfBunnies] = bunny;
        container.addChild(bunny);
        numOfBunnies++;
    }

    // Event Handlers

    private function this_onEnterFrame(event:Event):Void
    {
        if (isAdding && amount > 0) {
            for (i in 0...amount) {
                addBunny();
                if (numOfBunnies >= 16500) {
                    amount = 0;
                    break;
                }
            }
            trace(numOfBunnies + ' BUNNIES');
        }

        for (i in 0...numOfBunnies) {
            var bunny:Bunny = bunnies[i];
            var x = bunny.x + bunny.speedX;
            var y = bunny.y + bunny.speedY;
            bunny.speedY += gravity;

            if (x > maxX) {
                bunny.speedX *= -1;
                x = maxX;
            } else if (x < minX) {
                bunny.speedX *= -1;
                x = minX;
            }

            if (y > maxY) {
                bunny.speedY *= -0.85;
                y = maxY;
                if (Math.random() > 0.5) {
                    bunny.speedY -= Math.random() * 6;
                }
            } else if (y < minY) {
                bunny.speedY = 0;
                y = minY;
            }

            bunny.x = x;
            bunny.y = y;
        }
    }

    private function stage_onMouseDown(event:MouseEvent):Void
    {
        isAdding = true;
    }

    private function stage_onMouseUp(event:MouseEvent):Void
    {
        isAdding = false;
    }

    private function stage_onResize(event:Event):Void
    {
        maxX = stage.stageWidth - 26;
        maxY = stage.stageHeight - 37;
    }
}
