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
    private static inline var GRAVITY:Float = 0.75;
    private static inline var TIME_SCALE:Float = 0.5;
    private static inline var AMOUNT_TO_ADD:Int =#if mobile 10#else 50#end;
    private static inline var MAX_NUM_OF_OBJS:Int = 200000;

    private var bgBitmapData:BitmapData;
    private var createMarkObj:Void -> IMarkObj;
    private var dpiHeight:Int;
    private var dpiWidth:Int;
    private var isAdding:Bool = false;
    private var markObjs:Array <IMarkObj>;
    private var maxX:Int;
    private var maxY:Int;
    private var minX:Int = 0;
    private var minY:Int = -100;
    private var numOfMarkObjs:Int = 0;
    private var objBitmapData:BitmapData;
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
        for (i in 0...10) {
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
        maxX = Std.int(dpiWidth - objBitmapData.width);
        maxY = Std.int(dpiHeight - objBitmapData.height);
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
        stats = new Stats();
        statsTimer = new Timer(1000);
        bgBitmapData = Assets.getBitmapData('bg.png', true);
        objBitmapData = Assets.getBitmapData('obj.png', true);

        dpiWidth = Std.int(stage.stageWidth / pixelDensity);
        dpiHeight = Std.int(stage.stageHeight / pixelDensity);
        maxX = Std.int(dpiWidth - objBitmapData.width);
        maxY = Std.int(dpiHeight - objBitmapData.height);

        init();
        resize();
    }

    private function this_onEnterFrame(event:Event):Void
    {
        stats.start();

        if (isAdding && numOfMarkObjs < MAX_NUM_OF_OBJS) {
            for (i in 0...AMOUNT_TO_ADD) {
                addMarkObj(createMarkObj());
                if (numOfMarkObjs >= MAX_NUM_OF_OBJS) {
                    break;
                }
            }
        }

        render();
        stats.end();
    }
}
