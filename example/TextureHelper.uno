using Uno.Compiler.ExportTargetInterop;
using Uno.Graphics;
using Uno.IO;
using Experimental.TextureLoader;
using OpenGL;

static class TextureHelper
{
    public static texture2D Load2D(BundleFile file)
    {
        return TextureLoader.ByteArrayToTexture2DFilename(file.ReadAllBytes(), file.Name);
    }

    public static texture2D Load2DMipmap(BundleFile file)
    {
        if defined(CPLUSPLUS)
            return Load2D(file.Name, file.ReadAllBytes(), true);
        else
            return TextureLoader.ByteArrayToTexture2DFilename(file.ReadAllBytes(), file.Name);
    }

    // Copied from Uno to support mipmap on C++.
    [Require("Source.Include", "uBase/Memory.h")]
    [Require("Source.Include", "XliPlatform/GL.h")]
    [Require("Source.Include", "uImage/Texture.h")]
    [Require("Source.Include", "Uno/Support.h")]
    extern(CPLUSPLUS) static texture2D Load2D(string filename, byte[] data, bool mipmap)
    @{
        uBase::Auto<uImage::Texture> tex = uLoadXliTexture(uCString($0).Ptr, $1);

        uGLTextureInfo info;
        GLuint handle = uCreateGLTexture(tex, $2, &info);

        if (info.GLTarget != GL_TEXTURE_2D)
            U_THROW_IOE("Invalid 2D texture");

        return @{texture2D(GLTextureHandle,int2,int,Format):New(handle, @{int2(int,int):New(info.Width, info.Height)}, info.MipCount, @{Format.Unknown})};
    @}
}
