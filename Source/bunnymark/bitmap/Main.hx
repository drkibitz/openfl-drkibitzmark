package bunnymark.bitmap;

import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import openfl.Assets;
import bunnymark.Stats;

class Main extends Sprite
{
    // common

    private var amount:Int = 10;
    private var bunnies:Array <Bunny>;
    private var gravity:Float = 0.75;
    private var isAdding:Bool = false;
    private var maxX:Int;
    private var maxY:Int;
    private var minX:Int = 0;
    private var minY:Int = -100;
    private var numOfBunnies:Int = 0;
    private var numOfBunniesStart:Int = 10;
    private var pixelDensity:Float = 1;
    private var stats:Stats;
    private var statsTimer:Timer;

    // implementation

    private var container:Sprite;
    private var wabbitTexture:BitmapData;

    public function new()
    {
        // common

        #if html5
        // pixelDensity = js.Browser.window.devicePixelRatio;
        #else
        pixelDensity = stage.dpiScale;
        #end

        var w:Int = Std.int(stage.stageWidth / pixelDensity);
        var h:Int = Std.int(stage.stageHeight / pixelDensity);

        bunnies = new Array <Bunny>();
        maxX = w - 26;
        maxY = h - 37;
        stats = new Stats();
        statsTimer = new Timer(1000);

        statsTimer.addEventListener(TimerEvent.TIMER, statsTimer_timer);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
        stage.addEventListener(Event.RESIZE, stage_onResize);

        // implementation

        super();
        scaleX = scaleY = pixelDensity;

        container = new Sprite();
        wabbitTexture = Assets.getBitmapData("images/bunny.png", true);

        for (i in 0...numOfBunniesStart) {
            addBunny();
        }

        addChild(container);
        //addChild(stats); tracing should be enough for now
        addEventListener(Event.ENTER_FRAME, this_onEnterFrame);
        statsTimer.start();

        trace("-------------CLICK AND HOLD TO ADD BUNNIES!");
        trace("stage: " + stage.stageWidth + "x" + stage.stageHeight + ", pixelDensity: " + pixelDensity);
    }

    // common

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
        var w:Int = Std.int(stage.stageWidth / pixelDensity);
        var h:Int = Std.int(stage.stageHeight / pixelDensity);
        maxX = w - 26;
        maxY = h - 37;
    }

    private function statsTimer_timer(event:TimerEvent):Void
    {
        trace("FPS: " + stats.realFps + "/" + stage.frameRate + ", M: " + stats.memoryUsage + ", BUNNIES: " + numOfBunnies);
    }

    // implementation

    private function addBunny ():Void
    {
        var bunny:Bunny = new Bunny(wabbitTexture, PixelSnapping.ALWAYS, false);
        bunny.speedX = Math.random() * 10;
        bunny.speedY = (Math.random() * 10) - 5;
        bunnies[numOfBunnies] = bunny;
        container.addChild(bunny);
        numOfBunnies++;
    }

    private function this_onEnterFrame(event:Event):Void
    {
        stats.start();

        if (isAdding && amount > 0) {
            for (i in 0...amount) {
                addBunny();
                if (numOfBunnies >= 16500) {
                    amount = 0;
                    break;
                }
            }
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

        stats.end();
    }
}
