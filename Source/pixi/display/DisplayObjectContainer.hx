package pixi.display;

class DisplayObjectContainer extends DisplayObject
{
    public var children:Array <DisplayObject>;

    public function new()
    {
        super();
        this.children = [];
    }

    public function addChild(child:DisplayObject):Void
    {
        if (child.parent != null)
            child.parent.removeChild(child);

        child.parent = this;
        this.children.push(child);

        if (this.scene != null) {
            var tmpChild = child;
            while (tmpChild != null) {
                tmpChild.scene = this.scene;
                tmpChild = tmpChild._iNext;
            }
        }

        // LINKED LIST //

        // modify the list..
        var childFirst = child.first;
        var childLast = child.last;
        var previousObject = this.last;
        var nextObject = previousObject._iNext;

        // always true in this case
        //this.last = child.last;
        // need to make sure the parents last is updated too
        var updateLast = this;
        var prevLast = previousObject;

        while (updateLast != null) {
            if (updateLast.last == prevLast) {
                updateLast.last = child.last;
            }
            updateLast = updateLast.parent;
        }

        if (nextObject != null) {
            nextObject._iPrev = childLast;
            childLast._iNext = nextObject;
        }

        childFirst._iPrev = previousObject;
        previousObject._iNext = childFirst;

        // need to remove any render groups..
        if (this.__glRenderGroup != null) {
            // being used by a renderTexture.. if it exists then it must be from a render texture;
            if (child.__glRenderGroup != null)
                child.__glRenderGroup.removeDisplayObjectAndChildren(child);
            // add them to the new render group..
            this.__glRenderGroup.addDisplayObjectAndChildren(child);
        }
    };

    public function addChildAt(child:DisplayObject, index:Int):Void
    {
        if (index < 0 && index > this.children.length)
            throw child + " The index " + index + " supplied is out of bounds " + this.children.length;

        if (child.parent != null)
            child.parent.removeChild(child);

        child.parent = this;

        if (this.scene != null) {
            var tmpChild = child;
            do {
                tmpChild.scene = this.scene;
                tmpChild = tmpChild._iNext;
            } while (tmpChild != null);
        }

        // modify the list..
        var childFirst = child.first;
        var childLast = child.last;
        var nextObject;
        var previousObject;

        if (index == this.children.length) {
            previousObject =  this.last;
            var updateLast = this;//.parent;
            var prevLast = this.last;
            while (updateLast != null) {
                if (updateLast.last == prevLast) {
                    updateLast.last = child.last;
                }
                updateLast = updateLast.parent;
            }
        } else if (index == 0) {
            previousObject = this;
        } else {
            previousObject = this.children[index-1].last;
        }

        nextObject = previousObject._iNext;

        // always true in this case
        if (nextObject != null) {
            nextObject._iPrev = childLast;
            childLast._iNext = nextObject;
        }

        childFirst._iPrev = previousObject;
        previousObject._iNext = childFirst;

        this.children.insert(index, child);
        // need to remove any render groups..
        if (this.__glRenderGroup != null) {
            // being used by a renderTexture.. if it exists then it must be from a render texture;
            if (child.__glRenderGroup != null)
                child.__glRenderGroup.removeDisplayObjectAndChildren(child);
            // add them to the new render group..
            this.__glRenderGroup.addDisplayObjectAndChildren(child);
        }
    };

    public function getChildAt(index:Int):DisplayObject
    {
        if (index < 0 && index >= this.children.length)
            throw "Child index is out of bounds.";
        return this.children[index];
    }

    public function removeChild(child:DisplayObject):Void
    {
        var index:Int = Lambda.indexOf(this.children, child);
        if ( index > -1 )
            throw "The supplied DisplayObject must be a child of the caller.";

        // unlink //
        // modify the list..
        var childFirst = child.first;
        var childLast = child.last;

        var nextObject = childLast._iNext;
        var previousObject = childFirst._iPrev;

        if (nextObject != null)
            nextObject._iPrev = previousObject;
        previousObject._iNext = nextObject;

        if (this.last == childLast) {
            var tempLast =  childFirst._iPrev;
            // need to make sure the parents last is updated too
            var updateLast = this;
            while (updateLast.last == childLast.last) {
                updateLast.last = tempLast;
                updateLast = updateLast.parent;
                if (updateLast == null)
                    break;
            }
        }

        childLast._iNext = null;
        childFirst._iPrev = null;

        // update the scene reference..
        if (this.scene != null) {
            var tmpChild = child;
            do {
                tmpChild.scene = null;
                tmpChild = tmpChild._iNext;
            } while (tmpChild != null);
        }

        // GL trim
        if (child.__glRenderGroup != null) {
            child.__glRenderGroup.removeDisplayObjectAndChildren(child);
        }

        child.parent = null;
        this.children.splice(index, 1);
    }

    override public function updateTransform():Void
    {
        if (!this.visible) return;
        super.updateTransform();
        for (i in 0...this.children.length) {
            this.children[i].updateTransform();
        }
    }
}
