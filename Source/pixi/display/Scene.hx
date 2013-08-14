package pixi.display;

class Scene extends DisplayObjectContainer
{
    public function new()
    {
        super();
        //the scene is it's own scene
        this.scene = this;
        this.worldVisible = true;
    }

    override public function updateTransform():Void
    {
        this.worldAlpha = 1;
        for (i in 0...this.children.length) {
            //if (this.children[i]._dirtyTransform)
                this.children[i].updateTransform();
        }
        //this._dirtyTransform = false;
    }
}
