using SlimDX;
using SlimDX.DirectInput;
using Uno;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.GameController
{
    extern(DOTNET && HOST_WINDOWS)
    class SlimDXController : IDisposable
    {
        static DirectInput _dinput = new DirectInput();
        static readonly Dictionary<int, Button> _buttonMap = new Dictionary<int, Button>()
        {
            { 0, Button.A },
            { 1, Button.B },
            { 3, Button.X },
            { 4, Button.Y },
            { 6, Button.L1 },
            { 7, Button.R1 },
            { 8, Button.L2 },
            { 9, Button.R2 },
            { 10, Button.Select },
            { 11, Button.Start },
            { 13, Button.LeftThumb },
            { 14, Button.RightThumb },
            // - DPad buttons are detected from PointOfViewController data.
            // - Home and Back buttons are hijacked by the OS and we get no data from DirectInput.
        };

        class DPadState
        {
            public readonly Button Button;
            public readonly int POV0;
            public bool Pressed;

            public DPadState(Button button, int pov0)
            {
                Button = button;
                POV0 = pov0;
            }
        }

        readonly DPadState[] _dpadStates = new[]
        {
            new DPadState(Button.DPadUp, 0),
            new DPadState(Button.DPadDown, 18000),
            new DPadState(Button.DPadLeft, 27000),
            new DPadState(Button.DPadRight, 9000),
        };

        Joystick _joystick;
        float _leftX, _leftY;
        float _rightX, _rightY;
        bool[] _buttons;

        public SlimDXController()
        {
            foreach (var device in _dinput.GetDevices(DeviceClass.GameController, DeviceEnumerationFlags.AttachedOnly))
            {
                try
                {
                    _joystick = new Joystick(_dinput, device.InstanceGuid);
                    break;
                }
                catch (DirectInputException)
                {
                }
            }

            if (_joystick == null)
            {
                debug_log "SlimDXController: There are no joysticks attached to the system.";
                return;
            }

            foreach (var deviceObject in _joystick.GetObjects())
            {
                if ((deviceObject.ObjectType & ObjectDeviceType.Axis) != 0)
                    _joystick.GetObjectPropertiesById((int)deviceObject.ObjectType).SetRange(-1000, 1000);
            }

            _joystick.Acquire();
        }

        public void Dispose()
        {
            if (_joystick != null)
            {
                _joystick.Unacquire();
                _joystick.Dispose();
            }

            _joystick = null;
        }

        public void Update()
        {
            if (_joystick == null ||
                _joystick.Acquire().IsFailure ||
                _joystick.Poll().IsFailure)
                return;

            var state = _joystick.GetCurrentState();
            if (Result.Last.IsFailure)
                return;

            var buttons = state.GetButtons();

            for (int i = 0; i < buttons.Length; i++)
            {
                var lastState = _buttons != null && _buttons[i];
                var currState = buttons[i];

                Button b = 0;
                if (lastState != currState && _buttonMap.TryGetValue(i, out b))
                    GameController.OnButtonEvent(b, currState);
            }

            _buttons = buttons;

            if (state.X != _leftX)
                GameController.OnMotionEvent(Axis.LeftX, (_leftX = state.X) * .001f);
            if (state.Y != _leftY)
                GameController.OnMotionEvent(Axis.LeftY, (_leftY = state.Y) * .001f);
            if (state.Z != _rightX)
                GameController.OnMotionEvent(Axis.RightX, (_rightX = state.Z) * .001f);
            if (state.RotationZ != _rightY)
                GameController.OnMotionEvent(Axis.RightY, (_rightY = state.RotationZ) * .001f);

            // Detect DPad events
            var pov0 = state.GetPointOfViewControllers()[0];
            
            foreach (var dpad in _dpadStates)
            {
                if (pov0 == dpad.POV0)
                {
                    if (!dpad.Pressed)
                    {
                        GameController.OnButtonEvent(dpad.Button, true);
                        dpad.Pressed = true;
                    }
                }
                else if (dpad.Pressed)
                {
                    GameController.OnButtonEvent(dpad.Button, false);
                    dpad.Pressed = false;
                }
            }
        }
    }
}

namespace SlimDX.DirectInput
{
    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    class DirectInput
    {
        public extern DirectInput();
        public extern IList<DeviceInstance> GetDevices(DeviceClass deviceClass, DeviceEnumerationFlags enumerationFlags);
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    class DeviceInstance
    {
        public extern Guid InstanceGuid { get; }
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    abstract class Device : IDisposable
    {
        public extern void Dispose();
        public extern Result Acquire();
        public extern Result Poll();
        public extern Result Unacquire();
        public extern ObjectProperties GetObjectPropertiesById(int objectId);
        public extern IList<DeviceObjectInstance> GetObjects();
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    class ObjectProperties
    {
        public extern int Saturation { get; set; }
        public extern int LowerRange { get; }
        public extern int UpperRange { get; }
        public extern int Granularity { get; }
        public extern int DeadZone { get; set; }
        public extern object ApplicationData { get; set; }

        public extern void SetRange(int lowerRange, int upperRange);
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    struct DeviceObjectInstance
    {
        public extern int ReportId { get; set; }
        public extern int Exponent { get; set; }
        public extern int Dimension { get; set; }
        public extern int Usage { get; set; }
        public extern int UsagePage { get; set; }
        public extern int DesignatorIndex { get; set; }
        public extern int CollectionNumber { get; set; }
        public extern int ForceFeedbackResolution { get; set; }
        public extern int MaximumForceFeedback { get; set; }
        public extern int Offset { get; set; }
        public extern ObjectDeviceType ObjectType { get; set; }
        public extern string Name { get; set; }
        public extern Guid ObjectTypeGuid { get; set; }
    }

    [Flags]
    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    enum ObjectDeviceType
    {
        All = 0,
        RelativeAxis = 1,
        AbsoluteAxis = 2,
        Axis = 3,
        PushButton = 4,
        ToggleButton = 8,
        Button = 12,
        PointOfViewController = 16,
        Collection = 64,
        NoData = 128,
        NoCollection = 16776960,
        ForceFeedbackActuator = 16777216,
        ForceFeedbackEffectTrigger = 33554432,
        VendorDefined = 67108864,
        Alias = 134217728,
        Output = 268435456
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    class Joystick : Device
    {
        public extern Joystick(DirectInput directInput, Guid subsystem);

        public extern JoystickState GetCurrentState();
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    class JoystickState
    {
        public extern JoystickState();

        public extern int Z { get; }
        public extern int RotationX { get; }
        public extern int RotationY { get; }
        public extern int RotationZ { get; }
        public extern int VelocityX { get; }
        public extern int VelocityY { get; }
        public extern int VelocityZ { get; }
        public extern int AngularVelocityX { get; }
        public extern int AngularVelocityY { get; }
        public extern int AngularVelocityZ { get; }
        public extern int AccelerationX { get; }
        public extern int AccelerationY { get; }
        public extern int AccelerationZ { get; }
        public extern int AngularAccelerationX { get; }
        public extern int Y { get; }
        public extern int AngularAccelerationY { get; }
        public extern int ForceX { get; }
        public extern int ForceY { get; }
        public extern int ForceZ { get; }
        public extern int TorqueX { get; }
        public extern int TorqueY { get; }
        public extern int TorqueZ { get; }
        public extern int AngularAccelerationZ { get; }
        public extern int X { get; }

        public extern int[] GetAccelerationSliders();
        public extern bool[] GetButtons();
        public extern int[] GetForceSliders();
        public extern int[] GetPointOfViewControllers();
        public extern int[] GetSliders();
        public extern int[] GetVelocitySliders();
        public extern bool IsPressed(int button);
        public extern bool IsReleased(int button);
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    class DirectInputException : SlimDXException
    {
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    enum DeviceClass
    {
        All = 0,
        Device = 1,
        Pointer = 2,
        Keyboard = 3,
        GameController = 4
    }

    [Flags]
    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    enum DeviceEnumerationFlags
    {
        AllDevices = 0,
        AttachedOnly = 1,
        ForceFeedback = 256,
        IncludeAliases = 65536,
        IncludePhantoms = 131072,
        IncludeHidden = 262144
    }
}

namespace SlimDX
{
    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    struct Result
    {
        public extern static Result Last { get; }

        public extern bool IsFailure { get; }
    }

    [DotNetType]
    extern(DOTNET && HOST_WINDOWS)
    class SlimDXException : Exception
    {
        public extern Result ResultCode { get; }
    }
}
