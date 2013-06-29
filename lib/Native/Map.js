Elm.Native.Map = function(elm){
    'use strict';

    elm.Native = elm.Native || {};
    if (elm.Native.Map) return elm.Native.Map;

    var Maybe = Elm.Maybe(elm);
    var Utils = Elm.Native.Utils(elm);
    var List = Elm.Native.List(elm);
    var C = ElmRuntime.use(ElmRuntime.Render.Collage);

    function Tuple3(x, y, z){
        return {ctor: 'Tuple3', _0: x, _1: y, _2: z};
    }

    function tileForIndex(tuple3){
        var tile = window.subspaceMap[tuple3._0.toString()];
        if(tile){
            return Maybe.Just(Tuple3(tile, tuple3._1, tuple3._2));
        } else {
            return Maybe.Nothing;
        }
    }

    function renderBuffer(groupForm, width, height, xyTuple){
        var div = document.createElement('div')
        var buffer = document.createElement('canvas');
        div.appendChild(buffer);
        C.update(div, null, {
            w: width,
            h: height,
            forms: groupForm.form._1
        });

        return {
            _: {},
            alpha: 1,
            form: {
                ctor: 'FImage',
                _0: width,
                _1: height,
                _2: xyTuple,
                _3: {
                    _0: buffer,
                    ctor: 'FBuffer'
                }
            },
            scale: 1,
            theta: 0,
            x: 0,
            y: 0
        };
    }

    function mapSprite(width, height, xyTuple){
        var image = {
            ctor: 'FImage',
            _0: width,
            _1: height,
            _2: xyTuple,
            _3: {
                _0: window.tileset,
                ctor: 'FBuffer'
            }
        };

        return {
            _: {},
            alpha: 1,
            form: image,
            scale: 1,
            theta: 0,
            x: 0,
            y: 0
        };
    }

    return elm.Native.Map = {
        tileForIndex: tileForIndex,
        renderBuffer: F4(renderBuffer),
        mapSprite: F3(mapSprite)
    }
};