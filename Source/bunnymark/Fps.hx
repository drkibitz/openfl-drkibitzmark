﻿package bunnymark;import flash.display.Sprite;import flash.system.System;import flash.text.TextField;import flash.text.TextFormat;import flash.Lib;import flash.Vector;class Fps extends Sprite{    private var fpsTxt:TextField;    private var memTxt:TextField;    private var frameStartTime:Int = 0;    private var frameEndTime:Int = 0;    private var fpsList:Vector <Float>;    public var realFps:Int;    function new()    {        super();        mouseChildren = false;        mouseEnabled = false;        fpsTxt = new TextField();        memTxt = new TextField();        fpsTxt.width = 90;        memTxt.width = 90;        addChild(fpsTxt);        fpsTxt.y = -2;        addChild(memTxt);        memTxt.y = 8;        graphics.beginFill(0x000000, 0.8);        graphics.drawRect(0, 0, 90, 24);        graphics.endFill();        fpsTxt.defaultTextFormat = new TextFormat("Arial", 10, 0xFFFFFF, true);        memTxt.defaultTextFormat = new TextFormat("Arial", 10, 0xFFFFFF, true);        fpsList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];    }    public function start():Void    {        frameEndTime = frameStartTime;        frameStartTime = Lib.getTimer();    }    public function end():Void    {        var fps:Float = 1000 / (frameStartTime - frameEndTime);        fpsList.unshift(fps);        fpsList.pop();        var total:Float = 0;        var i:Int = 0;        var l:Int = fpsList.length;        while (i < l) {            total += fpsList[i];            i++;        }        realFps = Math.round(total / 20);        fpsTxt.text = "FPS: " + realFps + " / " + stage.frameRate;        memTxt.text = "M: " + (System.totalMemory / 1048576);    }}