using Fuse.Scripting;
using Uno.UX;

namespace Fuse.GameController
{
    [UXGlobalModule]
    public class GameControllerModule : NativeEventEmitterModule
    {
        static bool _inited;

        public GameControllerModule()
            : base(false, "button", "motion")
        {
            if (_inited)
                return;

            _inited = true;
            Resource.SetGlobalKey(this, "FuseJS/GameController");

            AddMember(new NativeProperty<int, int>("AXIS_LEFT_X", Axis.LeftX));
            AddMember(new NativeProperty<int, int>("AXIS_LEFT_Y", Axis.LeftX));
            AddMember(new NativeProperty<int, int>("AXIS_RIGHT_X", Axis.RightX));
            AddMember(new NativeProperty<int, int>("AXIS_RIGHT_Y", Axis.RightY));
            AddMember(new NativeProperty<int, int>("AXIS_LEFT_TRIGGER", Axis.LeftTrigger));
            AddMember(new NativeProperty<int, int>("AXIS_RIGHT_TRIGGER", Axis.RightTrigger));

            AddMember(new NativeProperty<int, int>("BUTTON_HOME", Button.Home));
            AddMember(new NativeProperty<int, int>("BUTTON_BACK", Button.Back));
            AddMember(new NativeProperty<int, int>("BUTTON_DPAD_UP", Button.DPadUp));
            AddMember(new NativeProperty<int, int>("BUTTON_DPAD_DOWN", Button.DPadDown));
            AddMember(new NativeProperty<int, int>("BUTTON_DPAD_LEFT", Button.DPadLeft));
            AddMember(new NativeProperty<int, int>("BUTTON_DPAD_RIGHT", Button.DPadRight));
            AddMember(new NativeProperty<int, int>("BUTTON_A", Button.A));
            AddMember(new NativeProperty<int, int>("BUTTON_B", Button.B));
            AddMember(new NativeProperty<int, int>("BUTTON_X", Button.X));
            AddMember(new NativeProperty<int, int>("BUTTON_Y", Button.Y));
            AddMember(new NativeProperty<int, int>("BUTTON_L1", Button.L1));
            AddMember(new NativeProperty<int, int>("BUTTON_R1", Button.R1));
            AddMember(new NativeProperty<int, int>("BUTTON_L2", Button.L2));
            AddMember(new NativeProperty<int, int>("BUTTON_R2", Button.R2));
            AddMember(new NativeProperty<int, int>("BUTTON_LEFT_THUMB", Button.LeftThumb));
            AddMember(new NativeProperty<int, int>("BUTTON_RIGHT_THUMB", Button.RightThumb));
            AddMember(new NativeProperty<int, int>("BUTTON_START", Button.Start));
            AddMember(new NativeProperty<int, int>("BUTTON_SELECT", Button.Select));

            GameController.Button += button => {
                EmitFactory((context, _) => {
                    var args = context.NewObject();
                    args["button"] = (int)button.Button;
                    args["value"] = button.Value;
                    args["repeated"] = button.Repeated;
                    return new object[] {"button", args};
                }, (object)null);
            };

            GameController.Motion += motion => {
                EmitFactory((context, _) => {
                    var args = context.NewObject();
                    args["axis"] = (int)motion.Axis;
                    args["value"] = motion.Value;
                    return new object[] {"motion", args};
                }, (object)null);
            };
        }
    }
}
