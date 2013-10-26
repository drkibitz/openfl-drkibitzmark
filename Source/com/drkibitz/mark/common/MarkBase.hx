package com.drkibitz.mark.common;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import openfl.Assets;

class MarkBase extends Sprite
{
    #if mobile
    private var amount:Int = 10;
    #else
    private var amount:Int = 50;
    #end
    private var createMarkObj:Void -> IMarkObj;
    private var dpiHeight:Int;
    private var dpiWidth:Int;
    private var gravity:Float = 0.75;
    private var isAdding:Bool = false;
    private var markObjs:Array <IMarkObj>;
    private var markObjBitmapData:BitmapData;
    private var maxNumOfMarkObjs:Int = 200000;
    private var maxX:Int;
    private var maxY:Int;
    private var minX:Int = 0;
    private var minY:Int = -100;
    private var numOfMarkObjs:Int = 0;
    private var numOfMarkObjsStart:Int = 10;
    private var patternBitmapData:BitmapData;
    private var pixelDensity:Float = 1;
    private var stats:Stats;
    private var statsTimer:Timer;

    public function new()
    {
        super();
        addEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
    }

    private function addMarkObj(obj:IMarkObj):Void
    {
        obj.speedX = Math.random() * 10;
        obj.speedY = (Math.random() * 10) - 5;
        markObjs[numOfMarkObjs] = obj;
        numOfMarkObjs++;
    }

    private function init():Void
    {
        for (i in 0...numOfMarkObjsStart) {
            addMarkObj(createMarkObj());
        }

        trace("CLICK AND HOLD TO ADD OBJECTS!");
        trace("stage: " + stage.stageWidth + "x" + stage.stageHeight + ", pixelDensity: " + pixelDensity);

        // addChild(stats); // rendering mixed contexts crashes ios, tracing should be enough for now
        statsTimer.start();

        statsTimer.addEventListener(TimerEvent.TIMER, statsTimer_onTimer);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
        stage.addEventListener(Event.RESIZE, stage_onResize);

        start();
    }

    private function render():Void {}

    private function resize():Void {}


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
        dpiWidth = Std.int(stage.stageWidth / pixelDensity);
        dpiHeight = Std.int(stage.stageHeight / pixelDensity);
        maxX = Std.int(dpiWidth - markObjBitmapData.width);
        maxY = Std.int(dpiHeight - markObjBitmapData.height);
        resize();
    }

    private function start():Void
    {
        addEventListener(Event.ENTER_FRAME, this_onEnterFrame);
    }

    private function statsTimer_onTimer(event:TimerEvent):Void
    {
        trace("FPS: " + stats.realFps + "/" + stage.frameRate + ", M: " + stats.memoryUsage + ", OBJECTS: " + numOfMarkObjs);
    }

    private function this_onAddedToStage(event:Event):Void
    {
        #if html5
        // pixelDensity = js.Browser.window.devicePixelRatio;
        #elseif !flash
        pixelDensity = stage.dpiScale;
        #end

        markObjs = new Array <IMarkObj>();
        patternBitmapData = Assets.getBitmapData("images/pattern64.png", true);
        stats = new Stats();
        statsTimer = new Timer(1000);
        markObjBitmapData = Assets.getBitmapData(
            #if MARK_IMAGE_WABBIT"images/wabbit_alpha.png"#else"images/drkibitz48.png"#end,
            true
        );

        dpiWidth = Std.int(stage.stageWidth / pixelDensity);
        dpiHeight = Std.int(stage.stageHeight / pixelDensity);
        maxX = Std.int(dpiWidth - markObjBitmapData.width);
        maxY = Std.int(dpiHeight - markObjBitmapData.height);

        init();
        resize();
    }

    private function this_onEnterFrame(event:Event):Void
    {
        stats.start();

        if (isAdding && amount > 0) {
            for (i in 0...amount) {
                addMarkObj(createMarkObj());
                if (numOfMarkObjs >= maxNumOfMarkObjs) {
                    amount = 0;
                    break;
                }
            }
        }

        render();
        stats.end();
    }
}