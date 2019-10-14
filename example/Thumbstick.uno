using Fuse;
using Fuse.Controls;
using Fuse.Controls.Graphics;
using Fuse.Elements;
using Fuse.GameController;
using Fuse.Input;
using Fuse.Input.UX;
using Fuse.Reactive;
using Uno.Collections;
using Uno.Math;
using Uno.Vector;
using Uno.UX;

public class Thumbstick : Panel
{
    const float DesiredSize = 300f;
    const float FixedSize = 150f;

    static readonly texture2D InnerTexture = TextureHelper.Load2D(import("@//assets/inner.png"));
    static readonly texture2D OuterTexture = TextureHelper.Load2D(import("@//assets/outer.png"));
    static readonly Selector HideActionsSelector = "HideActions";
    static readonly Selector DisabledSelector = "Disabled";
    static readonly Selector PressedSelector = "Pressed";
    static readonly Selector ValueSelector = "Value";

    bool _hideActions;
    public bool HideActions
    {
        get { return _hideActions; }
        private set
        {
            if (_hideActions == value)
                return;

            _hideActions = value;
            OnPropertyChanged(HideActionsSelector, this);
            OnCallback();
        }
    }

    bool _disabled;
    public bool Disabled
    {
        get { return _disabled; }
        set
        {
            if (_disabled == value)
                return;

            _disabled = value;
            OnPropertyChanged(DisabledSelector, this);
            OnCallback();
        }
    }

    bool _pressed;
    public bool Pressed
    {
        get { return _pressed; }
        private set
        {
            if (_pressed == value)
                return;

            _pressed = value;
            OnPropertyChanged(PressedSelector, this);
            OnCallback();
        }
    }

    float2 _value;
    public float2 Value
    {
        get { return _value; }
        private set
        {
            if (_value == value)
                return;

            _value = value;
            OnPropertyChanged(ValueSelector, this);
            OnCallback();
        }
    }

    public new bool IsVisible
    {
        get { return Visibility == Visibility.Visible; }
        set { Visibility = value ? Visibility.Visible : Visibility.Hidden; }
    }

    public ThumbstickIndex Index { get; set; }
    public IEventHandler Callback { get; set; }

    class CallbackArgs : IEventRecord
    {
        readonly Thumbstick _self;

        public CallbackArgs(Thumbstick self)
        {
            _self = self;
        }

        public Node Node { get { return _self; } }
        public object Data { get { return null; } }
        public Selector Sender { get { return "Thumbstick"; } }
        public IEnumerable<KeyValuePair<string, object>> Args { get { return new[] {
            new KeyValuePair<string, object>("disabled", _self.Disabled),
            new KeyValuePair<string, object>("hide", _self.HideActions),
            new KeyValuePair<string, object>("pressed", _self.Pressed),
            new KeyValuePair<string, object>("x", _self.Value.X),
            new KeyValuePair<string, object>("y", _self.Value.Y)
        }; } }
    }

    readonly CallbackArgs _args;

    public Thumbstick()
    {
        Size = Size2.Percent(100, 100);
        HitTestMode = HitTestMode.LocalBounds;
        _args = new CallbackArgs(this);
    }

    void OnCallback()
    {
        if (Callback != null)
            Callback.Dispatch(_args);
    }

    void OnButton(ButtonArgs args)
    {
        switch (Index)
        {
            case ThumbstickIndex.Left:
            {
                switch (args.Button)
                {
                    case Fuse.GameController.Button.LeftThumb:
                        Pressed = args.Value;
                        break;
                }
                break;
            }
            case ThumbstickIndex.Right:
            {
                switch (args.Button)
                {
                    case Fuse.GameController.Button.RightThumb:
                        Pressed = args.Value;
                        break;
                }
                break;
            }
        }
    }

    void OnMotion(MotionArgs args)
    {
        switch (Index)
        {
            case ThumbstickIndex.Left:
            {
                switch (args.Axis)
                {
                    case Axis.LeftX:
                        Value = float2(args.Value, _value.Y);
                        break;
                    case Axis.LeftY:
                        Value = float2(_value.X, -args.Value);
                        break;
                }
                break;
            }
            case ThumbstickIndex.Right:
            {
                switch (args.Axis)
                {
                    case Axis.RightX:
                        Value = float2(args.Value, _value.Y);
                        break;
                    case Axis.RightY:
                        Value = float2(_value.X, -args.Value);
                        break;
                }
                break;
            }
        }
    }

    protected override void OnRooted()
    {
        base.OnRooted();
        Children.Insert(0, new Visual());
        GameController.Motion += OnMotion;
        GameController.Button += OnButton;
    }

    protected override void OnUnrooted()
    {
        RemoveAllChildren<Visual>();
        base.OnUnrooted();
        GameController.Motion -= OnMotion;
        GameController.Button -= OnButton;
    }

    class Visual : ControlVisual<Thumbstick>
    {
        float2 _innerPosition;
        float2 _innerSize;
        float2 _outerPosition;
        float2 _outerSize;

        int _pointIndex = -1;
        float2 _pointOrigin;
        float2 _pointFactor;
        float2 _drawOffset;

        void PointerPressed(object sender, PointerEventArgs args)
        {
            if (_pointIndex != -1)
                return;

            var radius = FixedSize * .5f;
            var factor = 2f / radius;
            _pointFactor = float2(factor, -factor);
            _pointOrigin = args.WindowPoint;
            _drawOffset = _pointOrigin - radius;

            for (Element e = Control; e != null; e = e.Parent as Element)
                _drawOffset -= e.ActualPosition;

            _pointIndex = args.PointIndex;
            Control.HideActions = true;
            InvalidateVisual();
        }

        void PointerMoved(object sender, PointerEventArgs args)
        {
            if (args.PointIndex != _pointIndex)
                return;

            var p = (args.WindowPoint - _pointOrigin) * _pointFactor;
            var l = Length(p);

            if (l > 1.0f)
                p *= 1.0f / l;

            Control.Value = p;
        }

        void PointerReleased(object sender, PointerEventArgs args)
        {
            if (args.PointIndex != _pointIndex)
                return;

            Control.HideActions = false;
            Control.Value = float2(0);
            _pointIndex = -1;
            InvalidateVisual();
        }

        protected override void Attach()
        {
            Control.AddPropertyListener(this);
            Pointer.AddHandlers(Control,
                PointerPressed, null, null);
            Pointer.AddHandlers(App.Current.RootViewport,
                null, PointerMoved, PointerReleased);
        }

        protected override void Detach()
        {
            Control.RemovePropertyListener(this);
            Pointer.RemoveHandlers(Control,
                PointerPressed, null, null);
            Pointer.RemoveHandlers(App.Current.RootViewport,
                null, PointerMoved, PointerReleased);
        }

        protected sealed override float2 OnArrangeMarginBox(float2 position, LayoutParams lp)
        {
            var size = base.OnArrangeMarginBox(position, lp);
            var scale = FixedSize / DesiredSize;

            _innerSize = (float2) InnerTexture.Size * scale;
            _outerSize = (float2) OuterTexture.Size * scale;

            _innerPosition = (FixedSize - _innerSize) * .5f;
            _outerPosition = (FixedSize - _outerSize) * .5f;

            return size;
        }

        public override void OnPropertyChanged(PropertyObject obj, Selector property)
        {
            if (property == ValueSelector)
                InvalidateVisual();
            if (property == PressedSelector)
                InvalidateVisual();
        }

        public sealed override void Draw(DrawContext dc)
        {
            var drawOffset = _drawOffset;
            var color = float4(1);

            // Default to BottomCenter when not pressed.
            if (_pointIndex == -1)
            {
                drawOffset.X = (Control.ActualSize.X - FixedSize) * .5f;
                drawOffset.Y = (Control.ActualSize.Y - FixedSize);
                color.W = .75f;
            }

            var value = Control.Value;

            if (Length(value) > .1f)
                color.W = 1f;

            var outerSize = _outerSize * (Control.Pressed ? .7f : 1f);
            var outerPosition = (FixedSize - outerSize) * .5f;
            var outerOffset = float2(value.X, -value.Y) * outerSize * .5f;
            DrawHelper.Instance.Draw(dc, this, _innerPosition + drawOffset, _innerSize, InnerTexture, color);
            DrawHelper.Instance.Draw(dc, this, outerPosition + outerOffset + drawOffset, outerSize, OuterTexture, color);
        }
    }
}

public enum ThumbstickIndex
{
    Left,
    Right
}
