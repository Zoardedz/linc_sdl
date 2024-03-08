package sdl;

import cpp.UInt32;
import cpp.UInt8;
import cpp.Int32;
import cpp.Star;
import cpp.ConstStar;
import cpp.ConstCharStar;
import cpp.Pointer;
import cpp.ConstPointer;

enum abstract SDL_MessageBoxFlags(Int) from Int to Int{
    var SDL_MESSAGEBOX_ERROR = 0x00000010;
    var SDL_MESSAGEBOX_WARNING = 0x00000020;
    var SDL_MESSAGEBOX_INFORMATION = 0x00000040;
    var SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT = 0x00000080;
    var SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT = 0x00000100;
}

enum abstract SDL_MessageBoxButtonFlags(Int) from Int to Int {
    var SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT = 0x00000001;
    var SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT = 0x00000002;    
}

@:include('linc_sdl.h')
@:native('SDL_MessageBoxButtonData')
@:structAccess
extern class SDL_MessageBoxButtonData{
    @:native('flags')
    var flags:UInt32;
    
    @:native('buttonid')
    var buttonid:Int32;

    @:native('text')
    var text:ConstCharStar;
}

@:include('linc_sdl.h')
@:native('SDL_MessageBoxColor')
@:structAccess
extern class SDL_MessageBoxColor {
    @:native('r')
    var redChannel:UInt8;

    @:native('g')
    var greenChannel:UInt8;

    @:native('b')
    var blueChannel:UInt8;
}

@:include('linc_sdl.h')
@:native('SDL_MessageBoxColorType')
extern class SDL_MessageBoxColorType {}

enum MessageBoxColorType{
    SDL_MESSAGEBOX_COLOR_BACKGROUND;
    SDL_MESSAGEBOX_COLOR_TEXT;
    SDL_MESSAGEBOX_COLOR_BUTTON_BORDER;
    SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND;
    SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED;
    SDL_MESSAGEBOX_COLOR_MAX;
}

@:include('linc_sdl.h')
@:native('SDL_MessageBoxColorScheme')
@:structAccess
extern class SDL_MessageBoxColorScheme{
    @:native('colors')
    var colors:cpp.RawPointer<SDL_MessageBoxColor>; //copied this from yanni ngl
}

@:include('linc_sdl.h')
@:native('SDL_MessageBoxData')
@:structAccess
extern class SDL_MessageBoxData{
    @:native('flags')
    var flags:UInt32;

    @:native('window')
    var window:Window;

    @:native('title')
    var title:ConstCharStar;

    @:native('message')
    var message:ConstCharStar;

    @:native('numbuttons')
    var numbuttons:Int;

    @:native('buttons')
    var buttons:ConstStar<SDL_MessageBoxButtonData>;

    @:native('colorScheme')
    var colorScheme:ConstStar<SDL_MessageBoxColorScheme>;
}

typedef CallbackMessageBoxButton = { 
    var buttonData:SDL_MessageBoxButtonData;
    var callbackFunction:Void->Void;
}

class MessageBox{
    static var idIncrementation:Int = 0;

    public static function makeCallbackButton(name:ConstCharStar, onPress:Void->Void):CallbackMessageBoxButton{
        var rawdata:SDL_MessageBoxButtonData = untyped __cpp__('{0, ::sdl::MessageBox_obj::idIncrementation++, name}');
        return {
            buttonData: rawdata,
            callbackFunction: onPress
        };
    }

    public static function showCallbacksMessageBox(title:ConstCharStar, msg:ConstCharStar, window:Window, flags:SDL_MessageBoxFlags, buttons:Array<CallbackMessageBoxButton>):Int{
        var boxData:SDL_MessageBoxData = untyped __cpp__('{0, NULL, "", "", 0, NULL, NULL}');
        boxData.title = title;
        boxData.message = msg;
        boxData.window = window;
        boxData.flags = flags;

        final len:Int = buttons.length;

        /* var rawArr:Array<SDL_MessageBoxButtonData> = [];
        for(b in buttons) rawArr.push(b.rawData); */
        var btnArrayPtr:cpp.Star<SDL_MessageBoxButtonData> = cpp.Native.malloc(cpp.Native.sizeof(SDL_MessageBoxButtonData) * len);
        // btnArrayPtr = untyped __cpp__('(SDL_MessageBoxButtonData *) {0}->Pointer()', rawArr); // Seems pointless with custom data. Whyever it does that!!
        for(i in 0...len) {
            var data:SDL_MessageBoxButtonData = buttons[len - (i+1)].buttonData;
            untyped __cpp__('
                *btnArrayPtr = data;
                btnArrayPtr++;
            ');
        }
        untyped __cpp__('btnArrayPtr -= {0}', len);

        var const_btnArrayPtr:cpp.ConstStar<SDL_MessageBoxButtonData> = untyped __cpp__ ('const_cast<const SDL_MessageBoxButtonData*>({0})', btnArrayPtr);

        boxData.buttons = const_btnArrayPtr;
        boxData.numbuttons = buttons.length;
        boxData.colorScheme = untyped __cpp__('NULL');

        var btnPressed:Int = 0;
        var boxResult:Int = 0;
        untyped __cpp__('
            const SDL_MessageBoxData* data = &{0};

            boxResult = SDL_ShowMessageBox(
                data,
                &btnPressed
            );
        ', boxData);

        buttons[btnPressed].callbackFunction();
        idIncrementation = 0;
        return boxResult;
    }
}