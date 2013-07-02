Elm.Native.Map = function(elm){
    'use strict';

    elm.Native = elm.Native || {};
    if (elm.Native.Map) return elm.Native.Map;

    var Maybe = Elm.Maybe(elm);
    var Utils = Elm.Native.Utils(elm);
    var List = Elm.Native.List(elm);
    var C = ElmRuntime.use(ElmRuntime.Render.Collage);

    // function Tuple3(x, y, z){
    //     return {ctor: 'Tuple3', _0: x, _1: y, _2: z};
    // }

    // function tileForIndex(tuple3){
    //     var tile = window.subspaceMap[tuple3._0];
    //     if(tile){
    //         return Maybe.Just(Tuple3(tile, tuple3._1, tuple3._2));
    //     } else {
    //         return Maybe.Nothing;
    //     }
    // }

    function renderBuffer(groupForm, whTuple, xyTuple){
        var div = document.createElement('div')
        var buffer = document.createElement('canvas');
        buffer.name = "renderBuffer";
        div.appendChild(buffer);
        C.update(div, null, {
            w: whTuple._0,
            h: whTuple._1,
            forms: groupForm.form._1
        });

        return {
            _: {},
            alpha: 1,
            form: {
                ctor: 'FImage',
                _0: whTuple._0,
                _1: whTuple._1,
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

    window.tiles = [];

    var width = 19, height = 10;
    for (var i = width - 1; i >= 0; i--) {
        for (var j = height - 1; j >= 0; j--) {
            window.tiles.push({x: i, y: j + 1024 - 10, tile: j * width + i});
        };
    };
    function tiles(){
        var a = [];
        for (var i = window.tiles.length - 1; i >= 0; i--) {
            var tile = window.tiles[i],
                elmTile = {
                    ctor: 'Tuple2',
                    _0: {
                        ctor: 'Tuple2',
                        _0: tile.x * 16,
                        _1: (1024 - tile.y) * 16
                    },
                    _1: tile.tile
                };
            a.push(elmTile);
        };
        window.preElmTiles = a;
        return window.elmTiles = List.fromArray(a);
    }

    return elm.Native.Map = {
        // tileForIndex: tileForIndex,
        renderBuffer: F3(renderBuffer),
        mapSprite: F3(mapSprite),
        tiles: tiles()
    }
};