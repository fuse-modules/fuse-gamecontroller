#include <jni.h>
@{Fuse.GameController.GameController:IncludeDirective}

extern "C"
{
    JNIEXPORT void JNICALL Java_com_fuse_GameControllerActivity_onButtonEvent
    (JNIEnv* env, jobject obj, jint button, jboolean value)
    {
        @{Fuse.GameController.GameController.OnButtonEvent(Fuse.GameController.Button,bool):Call(button, value)};
    }

    JNIEXPORT void JNICALL Java_com_fuse_GameControllerActivity_onMotionEvent
    (JNIEnv* env, jobject obj, jint axis, jfloat value)
    {
        @{Fuse.GameController.GameController.OnMotionEvent(Fuse.GameController.Axis,float):Call(axis, value)};
    }
}
