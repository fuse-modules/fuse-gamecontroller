using Uno;

namespace Fuse.GameController
{
    public enum Axis
    {
        LeftX = 0,
        LeftY = 1,
        RightX = 11,
        RightY = 14,
        LeftTrigger = 17,
        RightTrigger = 18,
    }

    public enum Button
    {
        Home = 3,
        Back = 4,
        DPadUp = 19,
        DPadDown = 20,
        DPadLeft = 21,
        DPadRight = 22,
        A = 96,
        B = 97,
        X = 99,
        Y = 100,
        L1 = 102,
        R1 = 103,
        L2 = 104,
        R2 = 105,
        LeftThumb = 106,
        RightThumb = 107,
        Start = 108,
        Select = 109,
    }

    public class ButtonArgs
    {
        public Button Button;
        public bool Value;
        public bool Repeated;
    }

    public class MotionArgs
    {
        public Axis Axis;
        public float Value;
    }

    public class GameController
    {
        public static event Action<ButtonArgs> Button;
        public static event Action<MotionArgs> Motion;
        
        static readonly bool[] _buttons = new bool[128];
        static readonly ButtonArgs _buttonArgs = new ButtonArgs();
        static readonly MotionArgs _motionArgs = new MotionArgs();

        internal static void OnButtonEvent(Button button, bool value)
        {
            var repeated = false;
            if (button < _buttons.Length)
            {
                repeated = value && _buttons[button];
                _buttons[button] = value;
            }

            if (Button != null)
            {
                _buttonArgs.Button = button;
                _buttonArgs.Value = value;
                _buttonArgs.Repeated = repeated;
                Button(_buttonArgs);
            }
        }

        internal static void OnMotionEvent(Axis axis, float value)
        {
            if (Motion != null)
            {
                _motionArgs.Axis = axis;
                _motionArgs.Value = value;
                Motion(_motionArgs);
            }
        }

        // Windows/.NET implementation

        extern(DOTNET && HOST_WIN32)
        static readonly SlimDXController _slimDXController = new SlimDXController();

        extern(DOTNET && HOST_WIN32)
        static GameController()
        {
            Uno.Platform.Displays.MainDisplay.Tick += (sender, args) => _slimDXController.Update();
        }
    }
}
