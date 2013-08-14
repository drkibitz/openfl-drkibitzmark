package pixi.renderer.gl;

import openfl.gl.GL;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;

class GLShaderProgram
{
    private static function _compileGlShader(shaderSrc, shaderType):GLShader
    {
        var glShader:GLShader = GL.createShader(shaderType);
        GL.shaderSource(glShader, shaderSrc);
        GL.compileShader(glShader);

        if (GL.getShaderParameter(glShader, GL.COMPILE_STATUS) == 0)
            throw GL.getShaderInfoLog(glShader);

        return glShader;
    }

    private static function _compileGlProgram():GLProgram
    {
        var fragmentShader:GLShader = _compileGlShader(
            #if html5
            "precision mediump float;" +
            #end
            "varying vec2 vTextureCoord;
            uniform sampler2D uSampler;
            void main(void) {
                gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.x, vTextureCoord.y));
            }",
            GL.FRAGMENT_SHADER
        );
        var vertexShader:GLShader = _compileGlShader(
            "attribute vec2 aVertexPosition;
            attribute vec2 aTextureCoord;
            uniform vec2 uProjectionVector;
            varying vec2 vTextureCoord;
            void main(void) {
                gl_Position = vec4(aVertexPosition.x / uProjectionVector.x -1.0, aVertexPosition.y / -uProjectionVector.y + 1.0 , 0.0, 1.0);
                vTextureCoord = aTextureCoord;
            }",
            GL.VERTEX_SHADER
        );
        var glProgram:GLProgram = GL.createProgram();

        GL.attachShader(glProgram, vertexShader);
        GL.attachShader(glProgram, fragmentShader);
        GL.linkProgram(glProgram);

        if (GL.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
            throw "Could not initialise shaders";

        return glProgram;
    }

    public var glProgram:GLProgram;
    public var vertexPositionAttribute:Int;
    public var textureCoordAttribute:Int;
    public var projectionVector:GLUniformLocation;
    public var sampler:GLUniformLocation;

    public function new()
    {
        // Compile
        glProgram = _compileGlProgram();
        // Initiate
        GL.useProgram(glProgram);
        vertexPositionAttribute = GL.getAttribLocation(glProgram, "aVertexPosition");
        textureCoordAttribute = GL.getAttribLocation(glProgram, "aTextureCoord");
        projectionVector = GL.getUniformLocation(glProgram, "uProjectionVector");
        sampler = GL.getUniformLocation(glProgram, "uSampler");
    }
}
