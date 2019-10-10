declare module "FuseJS/GameController" {
    const AXIS_LEFT_X: number;
    const AXIS_LEFT_Y: number;
    const AXIS_RIGHT_X: number;
    const AXIS_RIGHT_Y: number;
    const AXIS_LEFT_TRIGGER: number;
    const AXIS_RIGHT_TRIGGER: number;

    const BUTTON_HOME: number;
    const BUTTON_BACK: number;
    const BUTTON_DPAD_UP: number;
    const BUTTON_DPAD_DOWN: number;
    const BUTTON_DPAD_LEFT: number;
    const BUTTON_DPAD_RIGHT: number;
    const BUTTON_A: number;
    const BUTTON_B: number;
    const BUTTON_X: number;
    const BUTTON_Y: number;
    const BUTTON_L1: number;
    const BUTTON_R1: number;
    const BUTTON_L2: number;
    const BUTTON_R2: number;
    const BUTTON_LEFT_THUMB: number;
    const BUTTON_RIGHT_THUMB: number;
    const BUTTON_START: number;
    const BUTTON_SELECT: number;

    class ButtonArgs {
        button: number;
        value: boolean;
        repeated: boolean;
    }

    class MotionArgs {
        axis: number;
        value: number;
    }

    type Event = "button" | "motion";
    type Callback = (args: ButtonArgs | MotionArgs) => void;

    function on(event: Event, callback: Callback): void;
}
