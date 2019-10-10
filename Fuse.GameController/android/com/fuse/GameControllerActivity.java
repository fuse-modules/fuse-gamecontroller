package com.fuse;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.InputDevice;
import android.view.KeyEvent;
import android.view.MotionEvent;

import java.util.ArrayList;

public class GameControllerActivity extends AppCompatActivity {

    int motionAxes[] = new int[] {
        MotionEvent.AXIS_X,
        MotionEvent.AXIS_Y,
        MotionEvent.AXIS_RZ,
        MotionEvent.AXIS_Z,
        MotionEvent.AXIS_RTRIGGER,
        MotionEvent.AXIS_LTRIGGER
    };

    float motionValues[] = new float[6];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d("app", getGameControllerIds().size() + " game controller(s) are connected.");
    }

    ArrayList<Integer> getGameControllerIds() {
        ArrayList<Integer> gameControllerDeviceIds = new ArrayList<>();
        int[] deviceIds = InputDevice.getDeviceIds();
        for (int deviceId : deviceIds) {
            InputDevice dev = InputDevice.getDevice(deviceId);
            int sources = dev.getSources();

            if (isGameController(sources)) {
                // This device is a game controller. Store its device ID.
                if (!gameControllerDeviceIds.contains(deviceId)) {
                    gameControllerDeviceIds.add(deviceId);
                }
            }
        }
        return gameControllerDeviceIds;
    }

    boolean isGameController(int sources) {
        // Verify that the device has gamepad buttons, control sticks, or both.
        return ((sources & InputDevice.SOURCE_GAMEPAD) == InputDevice.SOURCE_GAMEPAD) ||
               ((sources & InputDevice.SOURCE_JOYSTICK) == InputDevice.SOURCE_JOYSTICK);
    }

    @Override
    public boolean dispatchGenericMotionEvent(MotionEvent event) {
        // Skip input not from a game controller.
        if (!isGameController(event.getSource()))
            return super.dispatchGenericMotionEvent(event);

        boolean retval = false;

        // Detect which axes have actually changed.
        for (int i = 0; i < 6; i++) {
            float value = event.getAxisValue(motionAxes[i]);
            if (value != motionValues[i]) {
                motionValues[i] = value;
                onMotionEvent(motionAxes[i], value);

                // Avoid receiving shadow DPad button events.
                retval = true;
            }
        }

        return retval;
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        // Skip input not from a game controller.
        if (!isGameController(event.getSource()))
            return super.dispatchKeyEvent(event);

        // Notify native code about the event.
        onButtonEvent(event.getKeyCode(), event.getAction() == KeyEvent.ACTION_DOWN);
        return true;
    }

    public native void onButtonEvent(int button, boolean value);
    public native void onMotionEvent(int button, float value);
}
