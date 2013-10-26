package com.drkibitz.mark.pixi;

import com.drkibitz.mark.common.MarkBase;
import flash.geom.Rectangle;
import pixi.display.Scene;
import pixi.display.Sprite;
import pixi.renderer.gl.GLRenderer;
import pixi.texture.Texture;
import pixi.texture.TextureBase;

class Main extends MarkBase
{
    private var patternSprite:Sprite;
    private var renderer:GLRenderer;
    private var scene:Scene;
    private var texture:Texture;

    private function this_createMarkObj():MarkObj
    {
        var obj = new MarkObj(texture);
        scene.addChild(obj);
        return obj;
    }

    override private function init():Void
    {
        if (GLRenderer.isSupported) {

            scene = new Scene();
            renderer = new GLRenderer();
            texture = new Texture(new TextureBase(markObjBitmapData));
            addChild(renderer.view);

            createMarkObj = this_createMarkObj;

            patternSprite = new Sprite(new Texture(new TextureBase(patternBitmapData)));
            patternSprite.texture.textureBase.repeat = true;
            scene.addChild(patternSprite);

            super.init();
        }
    }

    override private function resize():Void
    {
        patternSprite.texture.frame = new Rectangle(0, 0, dpiWidth, dpiHeight);
    }

    override private function start():Void
    {
        renderer.view.render = renderView;
    }

    private function renderView(rect:Rectangle):Void
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

        for (i in 0...numOfMarkObjs) {
            var obj:MarkObj = cast markObjs[i];
            var x:Float = obj.position.x;
            var y:Float = obj.position.y;

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

            obj.position.x = x;
            obj.position.y = y;
        }

        renderer.render(rect, scene, pixelDensity);
        stats.end();
    }
}
