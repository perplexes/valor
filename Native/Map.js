
Elm.Native.Map = function(elm){
 'use strict';

 elm.Native = elm.Native || {};
 if (elm.Native.Map) return elm.Native.Map;

 var Maybe = Elm.Maybe(elm);
 var Utils = Elm.Native.Utils(elm);

 function Tuple3(x, y, z){
  return {ctor: 'Tuple3', _0: x, _1: y, _2: z};
 }

 return elm.Native.Map = {
   tileForIndex: function(tuple3){
     var tile = window.subspaceMap[tuple3._0.toString()];
     if(tile){
      return Maybe.Just(Tuple3(tile, tuple3._1, tuple3._2));
     } else {
      return Maybe.Nothing;
     }
   }
 }
};