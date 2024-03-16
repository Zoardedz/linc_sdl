package sdl;

@:unreflective
@:native("SDL_GLContext")
@:include('linc_sdl.h')
extern class GLContext {
    inline function isnull():Bool return this == untyped 0;
    inline function compare(toCompare:GLContext):Bool { return (hndl(this) == hndl(toCompare)); }
    inline function rawString():String { return '${hndl(this)}'; }

    private inline function toString():String { return 'SDL_GLContext: ' + rawString(); }
    private inline static function hndl(c:GLContext) { return untyped __cpp__('{0}', c); }
}
