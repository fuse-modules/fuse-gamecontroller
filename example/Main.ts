import GameController from "FuseJS/GameController"

export default class Main {
    names = {};
    pressed: string[] = [];

    constructor() {
        this.names[GameController.BUTTON_HOME] = "HOME";
        this.names[GameController.BUTTON_BACK] = "BACK";
        this.names[GameController.BUTTON_DPAD_UP] = "UP";
        this.names[GameController.BUTTON_DPAD_DOWN] = "DOWN";
        this.names[GameController.BUTTON_DPAD_LEFT] = "LEFT";
        this.names[GameController.BUTTON_DPAD_RIGHT] = "RIGHT";
        this.names[GameController.BUTTON_A] = "A";
        this.names[GameController.BUTTON_B] = "B";
        this.names[GameController.BUTTON_X] = "X";
        this.names[GameController.BUTTON_Y] = "Y";
        this.names[GameController.BUTTON_L1] = "L1";
        this.names[GameController.BUTTON_R1] = "R1";
        this.names[GameController.BUTTON_L2] = "L2";
        this.names[GameController.BUTTON_R2] = "R2";
        this.names[GameController.BUTTON_LEFT_THUMB] = "LTHUMB";
        this.names[GameController.BUTTON_RIGHT_THUMB] = "RTHUMB";
        this.names[GameController.BUTTON_START] = "START";
        this.names[GameController.BUTTON_SELECT] = "SELECT";
        
        GameController.on("button", (args: GameController.ButtonArgs) => {
            var button = this.names[args.button];
            console.log(button, args.value, args.repeated);
    
            if (args.value) {
                if (args.repeated)
                    return;
                this.addPressed(button);
            }
            else {
                this.removePressed(button);
            }
        });
    }

    // Manipulate 'this.pressed' array in direct member methods for
    // change detection to work robustly.

    addPressed(button: string): void {
        this.pressed.push(button);
    }

    removePressed(button: string): void {
        for (;;) {
            var i = this.pressed.indexOf(button);
            if (i == -1)
                break;
            this.pressed.splice(i, 1);
        }
    }
}
