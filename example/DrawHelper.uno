using Uno;
using Uno.Graphics;
using Uno.Math;
using Uno.Vector;
using Fuse;
using Fuse.Drawing.Planar;

class DrawHelper
{
    public static readonly DrawHelper Instance = new DrawHelper();

    public void Draw(DrawContext dc, Visual visual, float2 position, float2 size, float4 color)
    {
        draw Rectangle
        {
            DrawContext:
                dc;
            Visual:
                visual;
            Position:
                position;
            Size:
                size;
            PixelColor:
                color;
        };
    }

    public void Draw(DrawContext dc, Visual visual, float2 position, float2 size, texture2D texture)
    {
        draw Rectangle
        {
            DrawContext:
                dc;
            Visual:
                visual;
            Position:
                Floor(position + .5f);
            Size:
                Floor(size + .5f);
            PixelColor:
                sample(texture, VertexData, SamplerState.LinearClamp);
        };
    }

    public void Draw(DrawContext dc, Visual visual, float2 position, float2 size, texture2D texture, float4 color)
    {
        draw Rectangle
        {
            DrawContext:
                dc;
            Visual:
                visual;
            Position:
                Floor(position + .5f);
            Size:
                Floor(size + .5f);
            PixelColor:
                sample(texture, VertexData, SamplerState.LinearClamp) * color;
        };
    }

    public void DrawClipped(DrawContext dc, Visual visual, float2 position, float2 size, texture2D texture, float4 uvClip)
    {
        var uvPosition = uvClip.XY;	
        var uvSize = uvClip.ZW - uvPosition;

        draw Rectangle
        {
            DrawContext:
                dc;
            Visual:
                visual;
            Position:
                Floor(position + .5f);
            Size:
                Floor(size + .5f);
            TexCoord:
                VertexData * uvSize + uvPosition;
            PixelColor:
                sample(texture, TexCoord, SamplerState.LinearClamp);
        };
    }

    public void DrawRotated(DrawContext dc, Visual visual, float2 position, float2 size, texture2D texture, float angle)
    {
        draw Rectangle
        {
            DrawContext:
                dc;
            Visual:
                visual;
            Position:
                Floor(position + .5f);
            Size:
                Floor(size + .5f);
            TexCoord:
                Rotate(VertexData * 2 - 1, angle) * .5f + .5f;
            PixelColor:
                sample(texture, TexCoord, SamplerState.LinearClamp);
        };
    }
}
