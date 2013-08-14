package bunnymark.pixi;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;
import openfl.display.OpenGLView;
import pixi.display.DisplayObjectContainer;
import pixi.display.Scene;
import pixi.renderer.gl.GLRenderer;
import pixi.texture.Texture;
import bunnymark.Stats;

class Main extends flash.display.Sprite
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
    private var stats:Stats;
    private var statsTimer:Timer;

    // implementation

    private var container:DisplayObjectContainer;
    private var scene:Scene;
    private var renderer:GLRenderer;
    private var view:OpenGLView;
    private var wabbitTexture:Texture;

    public function new()
    {
        super();

        // common

        bunnies = new Array <Bunny>();
        maxX = stage.stageWidth - 26;
        maxY = stage.stageHeight - 37;
        stats = new Stats();
        statsTimer = new Timer(1000);

        statsTimer.addEventListener(TimerEvent.TIMER, statsTimer_timer);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
        stage.addEventListener(Event.RESIZE, stage_onResize);

        // implementation

        if (OpenGLView.isSupported) {
            container = new DisplayObjectContainer();
            scene = new Scene();
            renderer = new GLRenderer();
            view = new OpenGLView();
            wabbitTexture = Texture.fromAsset("images/bunny.png");

            for (i in 0...numOfBunniesStart) {
                addBunny();
            }

            scene.addChild(container);
            addChild(view);
            view.render = renderView;
        }

        // addChild(stats); // rendering mixed contexts crashes ios, tracing should be enough for now
        statsTimer.start();

        trace("-------------CLICK AND HOLD TO ADD BUNNIES!");
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
        maxX = stage.stageWidth - 26;
        maxY = stage.stageHeight - 37;
    }

    private function statsTimer_timer(event:TimerEvent):Void
    {
        trace("FPS: " + stats.realFps + "/" + stage.frameRate + ", M: " + stats.memoryUsage + ", BUNNIES: " + numOfBunnies);
    }

    // implementation

    private function addBunny ():Void
    {
        var bunny:Bunny = new Bunny(wabbitTexture);
        bunny.speedX = Math.random() * 10;
        bunny.speedY = (Math.random() * 10) - 5;
        bunnies[numOfBunnies] = bunny;
        container.addChild(bunny);
        numOfBunnies++;
    }

    private function renderView(rect:Rectangle):Void
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
            var x = bunny.position.x + bunny.speedX;
            var y = bunny.position.y + bunny.speedY;
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

            bunny.position.x = x;
            bunny.position.y = y;
        }

        renderer.render(rect, scene);
        stats.end();
    }
}
