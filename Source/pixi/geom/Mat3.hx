package pixi.geom;

class Mat3
{
    public static function create():Array <Float>
    {
        var matrix:Array <Float> = [];
        matrix[0] = 1;
        matrix[1] = 0;
        matrix[2] = 0;
        matrix[3] = 0;
        matrix[4] = 1;
        matrix[5] = 0;
        matrix[6] = 0;
        matrix[7] = 0;
        matrix[8] = 1;
        return matrix;
    }
}
