Elm.Native.Bits = function(elm){
    'use strict';
    var module = "Bits";

    elm.Native = elm.Native || {};
    if (elm.Native[module]) return elm.Native[module];

    // var Maybe = Elm.Maybe(elm);
    // var Utils = Elm.Native.Utils(elm);
    // var List = Elm.Native.List(elm);
    // var C = ElmRuntime.use(ElmRuntime.Render.Collage);
    function leftShift(a, b){
        return a << b;
    }

    function rightShift(a, b){
        return a >> b;
    }

    function and(a, b){
        return a & b;
    }

    function or(a, b){
        return a | b;
    }

    var B = [0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF],
        S = [1, 2, 4, 8];
    function zorder(tuple){
        var x = tuple._0, // Interleave lower 16 bits of x and y, so the bits of x
            y = tuple._1; // are in the even positions and bits from y in the odd;
                          // z gets the resulting 32-bit Morton Number.
                          // x and y must initially be less than 65536.

        x = (x | (x << S[3])) & B[3];
        x = (x | (x << S[2])) & B[2];
        x = (x | (x << S[1])) & B[1];
        x = (x | (x << S[0])) & B[0];

        y = (y | (y << S[3])) & B[3];
        y = (y | (y << S[2])) & B[2];
        y = (y | (y << S[1])) & B[1];
        y = (y | (y << S[0])) & B[0];

        return x | (y << 1);
    }

    return elm.Native[module] = {
        "<<": leftShift,
        ">>": rightShift,
        and: and,
        or: or,
        zorder: zorder
    }
};