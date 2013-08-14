package pixi.renderer.gl;

import openfl.gl.GL;
import pixi.display.DisplayObject;
import pixi.display.DisplayObjectContainer;
import pixi.display.Sprite;

class GLRenderGroup
{
    static private function checkVisibility(container:DisplayObjectContainer, worldVisible:Bool):Void
    {
        for (child in container.children) {
            // TODO optimize... should'nt need to loop through everything all the time
            child.worldVisible = child.visible && worldVisible;
            if (Std.is(child, DisplayObjectContainer)) {
                var childContainer:DisplayObjectContainer = cast child;
                if (childContainer.children.length > 0)
                    checkVisibility(childContainer, childContainer.worldVisible);
            }
        }
    }

    public var glBatches:Array <GLRenderBatch>;
    public var root:DisplayObjectContainer;

    public function new()
    {
        this.glBatches = [];
    }

    public function setRenderable(displayObject:DisplayObject):Void
    {
        // has this changed??
        if (this.root != null)
            this.removeDisplayObjectAndChildren(this.root);

        displayObject.worldVisible = displayObject.visible;

        // soooooo //
        // to check if any glBatches exist already??

        // TODO what if its already has an object? should remove it
        this.root = cast displayObject;
        this.addDisplayObjectAndChildren(this.root);
    }

    public function render(renderer:GLRenderer):Void
    {
        // TODO remove this by replacing visible with getter setters..
        checkVisibility(this.root, this.root.visible);

        // will render all the elements in the group
        for (glBatch in this.glBatches) {
            glBatch.render(renderer);
        }
    }

    public function addDisplayObjectAndChildren(displayObject:DisplayObject):Void
    {
        if (displayObject.__glRenderGroup != null)
            displayObject.__glRenderGroup.removeDisplayObjectAndChildren(displayObject);

        // LOOK FOR THE PREVIOUS RENDERABLE
        // This part looks for the closest previous sprite that can go into a glBatch
        // It keeps going back until it finds a sprite or the scene

        var previousRenderable = displayObject.first;
        while (previousRenderable != this.root.first) {
            previousRenderable = previousRenderable._iPrev;
            if (previousRenderable.renderable && previousRenderable.__glRenderGroup != null)
                break;
        }

        // LOOK FOR THE NEXT SPRITE
        // This part looks for the closest next sprite that can go into a glBatch it
        // keeps looking until it finds a sprite or gets to the end of the display scene graph

        var nextRenderable = displayObject.last;
        while (nextRenderable._iNext != null) {
            nextRenderable = nextRenderable._iNext;
            if (nextRenderable.renderable && nextRenderable.__glRenderGroup != null)
                break;
        }

        // one the display object hits this. we can break the loop

        var tempObject:DisplayObject = displayObject.first;
        var testObject:DisplayObject = displayObject.last._iNext;
        while (tempObject != testObject) {
            tempObject.__glRenderGroup = this;
            if (tempObject.renderable) {
                this.insertObject(tempObject, previousRenderable, nextRenderable);
                previousRenderable = tempObject;
            }
            tempObject = tempObject._iNext;
        }
    }

    public function removeDisplayObjectAndChildren(displayObject:DisplayObject):Void
    {
        if (displayObject.__glRenderGroup != this)
            return;

        // var displayObject = displayObject.first;
        var lastObject = displayObject.last;
        do {
            displayObject.__glRenderGroup = null;
            if (displayObject.renderable)
                this.removeObject(displayObject);
            displayObject = displayObject._iNext;
        } while (displayObject != null);
    }

    public function insertObject(displayObject:DisplayObject, previousObject:Dynamic, ?nextObject:Dynamic):Void
    {
        if (Std.is(displayObject, Sprite) == false) {
            this.insertAfter(cast(displayObject, GLRenderBatch), previousObject);
        }

        // while looping below THE OBJECT MAY NOT HAVE BEEN ADDED
        // so now we have the next renderable and the previous renderable
        var sprite:Sprite = cast displayObject;

        var previousBatch:GLRenderBatch;
        if (Std.is(previousObject, Sprite)) {
            var previousSprite:Sprite = cast previousObject;
            previousBatch = previousSprite.__glBatch;
            // glBatch may not exist if item was added to the display list but not to GL
            if (previousBatch != null && previousBatch.texture == sprite.texture.textureBase) {
                previousBatch.insertAfter(sprite, previousSprite);

                return;
            }
        } else {
            previousBatch = cast previousObject;
        }

        var nextBatch:GLRenderBatch;
        if (nextObject != null && Std.is(nextObject, Sprite)) {
            var nextSprite:Sprite = cast nextObject;
            nextBatch = nextSprite.__glBatch;
            // glBatch may not exist if item was added to the display list but not to GL
            if (nextBatch != null) {
                if (nextBatch.texture == sprite.texture.textureBase) {
                    nextBatch.insertBefore(sprite, nextSprite);

                    return;
                } else if (nextBatch == previousBatch) {
                    // THERE IS A SPLIT IN THIS BATCH! //
                    var splitBatch:GLRenderBatch = previousBatch.split(nextSprite);
                    // COOL! add it back into the array

                    // OOPS!
                    // seems the new sprite is in the middle of a glBatch lets split it..
                    var glBatch:GLRenderBatch = GLRenderBatch.getBatch();
                    var index:Int = Lambda.indexOf(this.glBatches, previousBatch);
                    glBatch.init(sprite);
                    this.glBatches.insert(index + 1, splitBatch);
                    this.glBatches.insert(index + 1, glBatch);
                    return;
                }
            }
        }

        // looks like it does not belong to any glBatch!
        // but is also not intersecting one..
        // time to create anew one!
        var glBatch:GLRenderBatch = GLRenderBatch.getBatch();
        glBatch.init(sprite);

        // if this is invalid it means
        if (previousBatch != null) {
            var index:Int = Lambda.indexOf(this.glBatches, previousBatch);
            this.glBatches.insert(index + 1, glBatch);
        } else {
            this.glBatches.push(glBatch);
        }
    }

    public function insertAfter(item:GLRenderBatch, displayObject:DisplayObject):Void
    {
        if (Std.is(displayObject, Sprite)) {
            var sprite:Sprite = cast displayObject;
            var previousBatch = sprite.__glBatch;

            if (previousBatch != null) {
                // so this object is in a glBatch!

                // is it not? need to split the glBatch
                if (previousBatch.tail == sprite) {
                    // is it tail? insert in to glBatches
                    var index:Int = Lambda.indexOf(this.glBatches, previousBatch);
                    this.glBatches.insert(index + 1, item);
                } else {
                    // TODO MODIFY ADD / REMOVE CHILD TO ACCOUNT FOR FILTERS (also get prev and next) //

                    // THERE IS A SPLIT IN THIS BATCH! //
                    var splitBatch = previousBatch.split(sprite.__texturedNext);
                    // COOL! add it back into the array

                    // OOPS!
                    // seems the new sprite is in the middle of a glBatch lets split it..
                    var index:Int = Lambda.indexOf(this.glBatches, previousBatch);
                    this.glBatches.insert(index + 1, splitBatch);
                    this.glBatches.insert(index + 1, item);
                }
            } else {
                this.glBatches.push(item);
            }
        } else {
            var index:Int = Lambda.indexOf(this.glBatches, cast displayObject);
            this.glBatches.insert(index + 1, item);
        }
    }

    public function removeObject(displayObject:Dynamic):Void
    {
        // loop through children..
        // display object //

        // add a child from the render group..
        // remove it and all its children!
        //displayObject.cacheVisible = false;//displayObject.visible;

        // removing is a lot quicker..
        var glBatchToRemove:GLRenderBatch = null;

        if (Std.is(displayObject, Sprite)) {
            // should always have a glBatch!
            var sprite:Sprite = cast displayObject;
            var glBatch = sprite.__glBatch;
            if (glBatch ==  null)
                return; // this means the display list has been altered before rendering

            glBatch.remove(sprite);

            if (glBatch.size == 0)
                glBatchToRemove = glBatch;
        } else {
            glBatchToRemove = cast displayObject;
        }

        // Looks like there is somthing that needs removing!
        if (glBatchToRemove != null) {
            var index:Int = Lambda.indexOf(this.glBatches, glBatchToRemove);
            if (index == -1)
                return;// this means it was added then removed before rendered

            // ok so.. check to see if you adjacent glBatches should be joined.
            // TODO may optimise?
            if (index == 0 || index == this.glBatches.length - 1) {
                // wha - eva! just get of the empty glBatch!
                this.glBatches.splice(index, 1);
                if (Std.is(glBatchToRemove, GLRenderBatch))
                    GLRenderBatch.returnBatch(glBatchToRemove);

                return;
            }

            var prevBatch = this.glBatches[index - 1];
            var nextBatch = this.glBatches[index + 1];
            if (Std.is(prevBatch, GLRenderBatch) && Std.is(nextBatch, GLRenderBatch)) {
                if (prevBatch.texture == nextBatch.texture) {
                    prevBatch.merge(this.glBatches[index + 1]);

                    if (Std.is(glBatchToRemove, GLRenderBatch))
                        GLRenderBatch.returnBatch(glBatchToRemove);

                    GLRenderBatch.returnBatch(nextBatch);
                    this.glBatches.splice(index, 2);
                    return;
                }
            }

            this.glBatches.splice(index, 1);
            if (Std.is(glBatchToRemove, GLRenderBatch))
                GLRenderBatch.returnBatch(glBatchToRemove);
        }
    }
}
