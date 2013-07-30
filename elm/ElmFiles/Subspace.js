
Elm.Subspace = function(elm){
  var N = Elm.Native, _N = N.Utils(elm), _L = N.List(elm), _E = N.Error(elm), _J = N.JavaScript(elm), _str = _J.toString;
  var $op = {};
  var _ = Elm.Text(elm); var Text = _; var hiding={link:1, color:1, height:1}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Prelude(elm); var Prelude = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Signal(elm); var Signal = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.List(elm); var List = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Maybe(elm); var Maybe = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Time(elm); var Time = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Element(elm); var Graphics = Graphics||{};Graphics.Element = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Color(elm); var Color = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Collage(elm); var Graphics = Graphics||{};Graphics.Collage = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Keyboard(elm); var Keyboard = _;
  var arrows = _.arrows;
  var _ = Elm.Window(elm); var Window = _;
  var dimensions = _.dimensions;
  var T = Elm.Text(elm);
  var _ = Elm.Random(elm); var Random = _;
  var _ = Elm.Json(elm); var Json = _;
  var _ = Elm.Http(elm); var Http = _;
  var Waiting = _.Waiting, Failure = _.Failure, Success = _.Success;
  var _ = Elm.Loader(elm); var Loader = _;
  var getJson = _.getJson;
  var _ = Elm.Starfield(elm); var Starfield = _;
  var starLayer = _.starLayer, tileLevel1 = _.tileLevel1, tileLevel2 = _.tileLevel2;
  var _ = Elm.Map(elm); var Map = _;
  var mapLayer = _.mapLayer, viewPort = _.viewPort, tiles = _.tiles;
  var UserInput_5 = function(a1){
    return {ctor:"UserInput", _0:a1};};
  var Input_7 = F2(function(a1, a2){
    return {ctor:"Input", _0:a1, _1:a2};});
  var clamp_4 = F3(function(min_20, max_21, x_22){
    return ((_N.cmp(x_22,min_20).ctor==='LT') ? min_20 : ((_N.cmp(x_22,max_21).ctor==='LT') ? x_22 : max_21));});
  var GameState_8 = F6(function(x_23, y_24, angle_25, dx_26, dy_27, t_28){
    return {
      _:{
      },
      angle:angle_25,
      dx:dx_26,
      dy:dy_27,
      t:t_28,
      x:x_23,
      y:y_24};});
  var stepGame_10 = F2(function(_50000_29, gs_30){
    return function(){ 
    switch (_50000_29.ctor) {
      case 'Input':
        switch (_50000_29._1.ctor) {
          case 'UserInput':
            return function(){
              var _44000_33 = gs_30;
              var x_34 = _44000_33.x;
              var y_35 = _44000_33.y;
              var angle_36 = _44000_33.angle;
              var dx_37 = _44000_33.dx;
              var dy_38 = _44000_33.dy;
              return _N.replace([['dx',A3(clamp_4, (0-1000), 1000, (dx_37+((toFloat((0-_50000_29._1._0.y))*10)*sin(angle_36))))],['dy',A3(clamp_4, (0-1000), 1000, (dy_38+((toFloat(_50000_29._1._0.y)*10)*cos(angle_36))))],['angle',(angle_36+((_50000_29._0*(0-3))*toFloat(_50000_29._1._0.x)))],['x',A2(clamp_4, 0, mapW_0)((x_34+(_50000_29._0*dx_37)))],['y',A2(clamp_4, 0, mapH_1)((y_35+(_50000_29._0*dy_38)))],['t',_50000_29._0]], gs_30);}();
        }break;
    }_E.Case('Line 44, Column 3') }();});
  var ship_11 = function(angle_39){
    return A2(scale, 0.25, A2(rotate, angle_39, A4(sprite, shipW_2, shipH_3, {ctor:"Tuple2", _0:0, _1:0}, _str('/assets/ship2.png'))));};
  var scene_12 = F4(function(_76000_40, gs_41, debugging_42, forms_43){
    return function(){ 
    switch (_76000_40.ctor) {
      case 'Tuple2':
        return function(){
          var sceneElement_46 = A3(collage, _76000_40._0, _76000_40._1, forms_43);
          var window_47 = {ctor:"Tuple2", _0:_76000_40._0, _1:_76000_40._1};
          return A4(container, _76000_40._0, _76000_40._1, topLeft, layers(_J.toList([sceneElement_46,A2(flow, down, _J.toList([A2(debug_14, _str('db'), debugging_42)]))])));}();
    }_E.Case('Line 61, Column 3') }();});
  var whiteTextForm_13 = function(string_48){
    return function(x){
      return text(A2(T.color, white, x));}(toText(string_48));};
  var debug_14 = F2(function(key_49, value_50){
    return whiteTextForm_13(_L.append(key_49,_L.append(_str(': '),show(value_50))));});
  var display_15 = F5(function(window_51, gs_52, tile1_53, tile2_54, _96000_55){
    return function(){ 
    switch (_96000_55.ctor) {
      case 'Tuple2':
        return function(){
          var vp_58 = A2(viewPort, window_51, {ctor:"Tuple2", _0:gs_52.x, _1:gs_52.y});
          var _88000_59 = A2(mapLayer, vp_58, _96000_55._1);
          var mapl_60 = function(){ 
          switch (_88000_59.ctor) {
            case 'Tuple2':
              return _88000_59._0;
          }_E.Case('Line 88, Column 23') }();
          var tiles_61 = function(){ 
          switch (_88000_59.ctor) {
            case 'Tuple2':
              return _88000_59._1;
          }_E.Case('Line 88, Column 23') }();
          var sl2_62 = A2(starLayer, vp_58, tile2_54);
          var sl1_63 = A2(starLayer, vp_58, tile1_53);
          return A4(scene_12, window_51, gs_52, length(tiles_61), _J.toList([sl2_62,sl1_63,mapl_60,ship_11(gs_52.angle)]));}();
    }_E.Case('Line 87, Column 3') }();});
  var mapW_0 = 16384;
  var mapH_1 = 16384;
  var shipW_2 = 170;
  var shipH_3 = 166;
  var userInput_6 = A2(lift, UserInput_5, arrows);
  var defaultGame_9 = {
    _:{
    },
    angle:0.0,
    dx:0.0,
    dy:0.0,
    t:0.0,
    x:8384.0,
    y:10048.0};
  var delta_16 = A2(lift, inSeconds, fps(60));
  var input_17 = A2(sampleOn, delta_16, A3(lift2, Input_7, delta_16, userInput_6));
  var gameState_18 = A3(foldp, stepGame_10, defaultGame_9, input_17);
  var main_19 = A6(lift5, display_15, dimensions, gameState_18, tileLevel1, tileLevel2, constant({ctor:"Tuple2", _0:Map.tiles, _1:Map.mapTree(Map.tiles)}));
  elm.Native = elm.Native||{};
  var _ = elm.Native.Subspace||{};
  _.$op = {};
  _.mapW = mapW_0;
  _.mapH = mapH_1;
  _.shipW = shipW_2;
  _.shipH = shipH_3;
  _.clamp = clamp_4;
  _.UserInput = UserInput_5;
  _.userInput = userInput_6;
  _.Input = Input_7;
  _.GameState = GameState_8;
  _.defaultGame = defaultGame_9;
  _.stepGame = stepGame_10;
  _.ship = ship_11;
  _.scene = scene_12;
  _.whiteTextForm = whiteTextForm_13;
  _.debug = debug_14;
  _.display = display_15;
  _.delta = delta_16;
  _.input = input_17;
  _.gameState = gameState_18;
  _.main = main_19
  return elm.Subspace = _;
  };
Elm.Starfield = function(elm){
  var N = Elm.Native, _N = N.Utils(elm), _L = N.List(elm), _E = N.Error(elm), _J = N.JavaScript(elm), _str = _J.toString;
  var $op = {};
  var _ = Elm.Text(elm); var Text = _; var hiding={link:1, color:1, height:1}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Prelude(elm); var Prelude = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Signal(elm); var Signal = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.List(elm); var List = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Maybe(elm); var Maybe = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Time(elm); var Time = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Element(elm); var Graphics = Graphics||{};Graphics.Element = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Color(elm); var Color = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Collage(elm); var Graphics = Graphics||{};Graphics.Collage = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Random(elm); var Random = _;
  var _ = Elm.Map(elm); var Map = _;
  var ViewPort = _.ViewPort, tilesInViewBruteforce = _.tilesInViewBruteforce, renderBuffer = _.renderBuffer, extract = _.extract;
  var randomList_4 = function(ratio_10){
    return function(){
      var lower_11 = A2(div, (0-starTilesize_0), 2);
      var upper_12 = A2(div, starTilesize_0, 2);
      var density_13 = (starDensity_1*Math.pow(ratio_10,2));
      return combine(A2(map, function(x){
        return A3(Random.range, lower_11, upper_12, constant(x));}, _L.range(0,density_13)));}();};
  var randomTile_5 = function(ratio_14){
    return A3(lift2, zip, randomList_4(ratio_14), randomList_4(ratio_14));};
  var makeStarTile_6 = F3(function(color_15, moveRatio_16, points_17){
    return function(){
      var filledRect_19 = function(color_23){
        return A2(filled, color_23, shape_18);};
      var moved_20 = F2(function(color_24, _27000_25){
        return function(){ 
        switch (_27000_25.ctor) {
          case 'Tuple2':
            return A2(move, {ctor:"Tuple2", _0:_27000_25._0, _1:_27000_25._1}, filledRect_19(color_24));
        }_E.Case('Line 27, Column 27') }();});
      var star_21 = F2(function(color_28, _28000_29){
        return function(){ 
        switch (_28000_29.ctor) {
          case 'Tuple2':
            return A2(moved_20, color_28, {ctor:"Tuple2", _0:_28000_29._0, _1:_28000_29._1});
        }_E.Case('Line 28, Column 26') }();});
      var shape_18 = A2(rect, 1, 1);
      var stars_22 = A2(map, function(_0_32){
        return function(){ 
        switch (_0_32.ctor) {
          case 'Tuple2':
            return A2(star_21, color_15, {ctor:"Tuple2", _0:_0_32._0, _1:_0_32._1});
        }_E.Case('Line 29, Column 30') }();}, points_17);
      return {ctor:"Tuple2", _0:A3(renderBuffer, group(stars_22), {ctor:"Tuple2", _0:starTilesize_0, _1:starTilesize_0}, {ctor:"Tuple2", _0:0, _1:0}), _1:moveRatio_16};}();});
  var starLayer_9 = F2(function(_51000_35, tile_36){
    return function(){ 
    switch (_51000_35.ctor) {
      case 'ViewPort':
        return function(){
          var xy_50 = F2(function(c_59, r_60){
            return {ctor:"Tuple2", _0:toFloat(round((toFloat((c_59*starTilesize_0))+x_48))), _1:toFloat(round((toFloat((r_60*starTilesize_0))+y_49)))};});
          var _43000_38 = _51000_35._0;
          var vw_39 = _43000_38.vw;
          var vh_40 = _43000_38.vh;
          var sx_41 = _43000_38.sx;
          var sy_42 = _43000_38.sy;
          var _44000_43 = tile_36;
          var f_44 = function(){ 
          switch (_44000_43.ctor) {
            case 'Tuple2':
              return _44000_43._0;
          }_E.Case('Line 44, Column 20') }();
          var ratio_45 = function(){ 
          switch (_44000_43.ctor) {
            case 'Tuple2':
              return _44000_43._1;
          }_E.Case('Line 44, Column 20') }();
          var coords_46 = A4(tilesInViewBruteforce, ViewPort(_51000_35._0), starTilesize_0, starTilesize_0, ratio_45);
          var _46000_47 = {ctor:"Tuple2", _0:((0-sx_41)/ratio_45), _1:(0-(sy_42/ratio_45))};
          var x_48 = function(){ 
          switch (_46000_47.ctor) {
            case 'Tuple2':
              return _46000_47._0;
          }_E.Case('Line 46, Column 17') }();
          var y_49 = function(){ 
          switch (_46000_47.ctor) {
            case 'Tuple2':
              return _46000_47._1;
          }_E.Case('Line 46, Column 17') }();
          return group(A2(map, function(_0_61){
            return function(){ 
            switch (_0_61.ctor) {
              case 'Tuple2':
                return A2(move, A2(xy_50, _0_61._0, _0_61._1), f_44);
            }_E.Case('Line 51, Column 30') }();}, coords_46));}();
    }_E.Case('Line 43, Column 3') }();});
  var starTilesize_0 = 1024;
  var starDensity_1 = 31;
  var l1color_2 = A3(rgb, 184, 184, 184);
  var l2color_3 = A3(rgb, 96, 96, 96);
  var tileLevel1_7 = A2(lift, A2(makeStarTile_6, l1color_2, 2.0), randomTile_5(2));
  var tileLevel2_8 = A2(lift, A2(makeStarTile_6, l2color_3, 3.0), randomTile_5(3));
  elm.Native = elm.Native||{};
  var _ = elm.Native.Starfield||{};
  _.$op = {};
  _.tileLevel1 = tileLevel1_7;
  _.tileLevel2 = tileLevel2_8;
  _.starLayer = starLayer_9
  return elm.Starfield = _;
  };
Elm.Map = function(elm){
  var N = Elm.Native, _N = N.Utils(elm), _L = N.List(elm), _E = N.Error(elm), _J = N.JavaScript(elm), _str = _J.toString;
  var $op = {};
  var _ = Elm.Text(elm); var Text = _; var hiding={link:1, color:1, height:1}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Prelude(elm); var Prelude = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Signal(elm); var Signal = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.List(elm); var List = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Time(elm); var Time = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Element(elm); var Graphics = Graphics||{};Graphics.Element = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Color(elm); var Color = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Collage(elm); var Graphics = Graphics||{};Graphics.Collage = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Dict(elm); var Dict = _;
  var RBEmpty = _.RBEmpty, RBNode = _.RBNode;
  var _ = Elm.Json(elm); var Json = _;
  var Object = _.Object;
  var _ = Elm.Maybe(elm); var Maybe = _;
  var Just = _.Just, Nothing = _.Nothing, justs = _.justs;
  var _ = Elm.Bits(elm); var Bits = _;
  var N = Elm.Native.Map(elm);
  var ViewPort_8 = function(a1){
    return {ctor:"ViewPort", _0:a1};};
  var viewPort_9 = F2(function(_44001_22, _44000_23){
    return function(){ 
    switch (_44001_22.ctor) {
      case 'Tuple2':
        return function(){ 
        switch (_44000_23.ctor) {
          case 'Tuple2':
            return function(){
              var vw_28 = toFloat(_44001_22._0);
              var vh_29 = toFloat(_44001_22._1);
              return ViewPort_8({
                _:{
                },
                maxCoord:{ctor:"Tuple2", _0:ceiling((_44000_23._0+(vw_28/2))), _1:ceiling((_44000_23._1+(vh_29/2)))},
                minCoord:{ctor:"Tuple2", _0:floor((_44000_23._0-(vw_28/2))), _1:floor((_44000_23._1-(vh_29/2)))},
                sx:_44000_23._0,
                sy:_44000_23._1,
                vh:vh_29,
                vw:vw_28});}();
        }_E.Case('Line 36, Column 3') }();
    }_E.Case('Line 36, Column 3') }();});
  var extract_10 = function(vp_30){
    return function(){
      var _46000_31 = vp_30;
      var vw_32 = _46000_31.vw;
      var vh_33 = _46000_31.vh;
      var sx_34 = _46000_31.sx;
      var sy_35 = _46000_31.sy;
      return {ctor:"Tuple4", _0:vw_32, _1:vh_33, _2:sx_34, _3:sy_35};}();};
  var indexToSpriteCoord_11 = function(index_36){
    return function(){
      var index$_37 = (index_36-1);
      var row_38 = A2(div, index$_37, spriteWidth_2);
      var col_39 = A2(rem, index$_37, spriteWidth_2);
      return A2(scale_12, {ctor:"Tuple2", _0:toFloat(col_39), _1:toFloat(row_38)}, {ctor:"Tuple2", _0:tileWidth_0, _1:tileHeight_1});}();};
  var scale_12 = F2(function(_69001_40, _69000_41){
    return function(){ 
    switch (_69001_40.ctor) {
      case 'Tuple2':
        return function(){ 
        switch (_69000_41.ctor) {
          case 'Tuple2':
            return {ctor:"Tuple2", _0:(_69001_40._0*_69000_41._0), _1:(_69001_40._1*_69000_41._1)};
        }_E.Case('Line 69, Column 26') }();
    }_E.Case('Line 69, Column 26') }();});
  var project_13 = F2(function(_75001_46, _75000_47){
    return function(){ 
    switch (_75001_46.ctor) {
      case 'ViewPort':
        return function(){ 
        switch (_75000_47.ctor) {
          case 'Tuple2':
            return {ctor:"Tuple2", _0:(_75000_47._0-_75001_46._0.sx), _1:(_75000_47._1-_75001_46._0.sy)};
        }_E.Case('Line 75, Column 32') }();
    }_E.Case('Line 75, Column 32') }();});
  var tilesInViewBruteforce_14 = F4(function(_94000_51, w_52, h_53, ratio_54){
    return function(){ 
    switch (_94000_51.ctor) {
      case 'ViewPort':
        return function(){
          var _81000_56 = _94000_51._0;
          var vw_57 = _81000_56.vw;
          var vh_58 = _81000_56.vh;
          var sx_59 = _81000_56.sx;
          var sy_60 = _81000_56.sy;
          var tileHeight_61 = toFloat(w_52);
          var tileWidth_62 = toFloat(h_53);
          var l_63 = floor((((sx_59/ratio_54)-(vw_57/2))/tileWidth_62));
          var t_64 = floor((((sy_60/ratio_54)-(vh_58/2))/tileHeight_61));
          var r_65 = ceiling((((sx_59/ratio_54)+(vw_57/2))/tileWidth_62));
          var b_66 = ceiling((((sy_60/ratio_54)+(vh_58/2))/tileHeight_61));
          var ltr_67 = _L.range(l_63,r_65);
          var ttb_68 = _L.range(t_64,b_66);
          return A3(foldl, function(r_69){
            return function(a_70){
              return A3(foldl, function(c_71){
                return function(a2_72){
                  return _L.Cons({ctor:"Tuple2", _0:c_71, _1:r_69},a2_72);};}, a_70, ltr_67);};}, _J.toList([]), ttb_68);}();
    }_E.Case('Line 81, Column 3') }();});
  var mapTree_15 = function(ts_73){
    return function(){
      var collapse_74 = function(_102000_76){
        return function(){ 
        switch (_102000_76.ctor) {
          case 'Tuple2':
            return {ctor:"Tuple2", _0:Bits.zorder(_102000_76._0), _1:{ctor:"Tuple2", _0:_102000_76._0, _1:_102000_76._1}};
        }_E.Case('Line 102, Column 25') }();};
      var zs_75 = A2(map, collapse_74, ts_73);
      return Dict.fromList(zs_75);}();};
  var tilesInView_16 = F2(function(_108000_79, tree_80){
    return function(){ 
    switch (_108000_79.ctor) {
      case 'ViewPort':
        return A5(naiveQueryFold_18, function(x_82){
          return function(y_83){
            return _L.Cons(x_82,y_83);};}, _J.toList([]), tree_80, _108000_79._0.minCoord, _108000_79._0.maxCoord);
    }_E.Case('Line 108, Column 3') }();});
  var naiveQuery_17 = F3(function(tree_84, minCoord_85, maxCoord_86){
    return function(){
      var between_95 = function(_122000_105){
        return function(){ 
        switch (_122000_105.ctor) {
          case 'Tuple2':
            switch (_122000_105._0.ctor) {
              case 'Tuple2':
                return ((_N.cmp(_122000_105._0._1,y2_92).ctor==='GT') ? false : ((_N.cmp(_122000_105._0._1,y1_89).ctor==='LT') ? false : ((_N.cmp(_122000_105._0._0,x2_91).ctor==='GT') ? false : ((_N.cmp(_122000_105._0._0,x1_88).ctor==='LT') ? false : true))));
            }break;
        }_E.Case('Line 118, Column 9') }();};
      var query$_96 = function(t_108){
        return function(){ 
        switch (t_108.ctor) {
          case 'RBEmpty':
            return _J.toList([]);
          case 'RBNode':
            return function(){
              var v$_113 = t_108._2;
              return ((_N.cmp(t_108._1,minz_93).ctor==='LT') ? query$_96(t_108._4) : ((_N.cmp(t_108._1,maxz_94).ctor==='GT') ? query$_96(t_108._3) : function(){
                var lft_114 = query$_96(t_108._3);
                var rgt_115 = query$_96(t_108._4);
                return (between_95(t_108._2) ? _L.append(lft_114,_L.append(_J.toList([v$_113]),rgt_115)) : _L.append(lft_114,rgt_115));}()));}();
        }_E.Case('Line 123, Column 18') }();};
      var _113000_87 = minCoord_85;
      var x1_88 = function(){ 
      switch (_113000_87.ctor) {
        case 'Tuple2':
          return _113000_87._0;
      }_E.Case('Line 113, Column 18') }();
      var y1_89 = function(){ 
      switch (_113000_87.ctor) {
        case 'Tuple2':
          return _113000_87._1;
      }_E.Case('Line 113, Column 18') }();
      var _114000_90 = maxCoord_86;
      var x2_91 = function(){ 
      switch (_114000_90.ctor) {
        case 'Tuple2':
          return _114000_90._0;
      }_E.Case('Line 114, Column 18') }();
      var y2_92 = function(){ 
      switch (_114000_90.ctor) {
        case 'Tuple2':
          return _114000_90._1;
      }_E.Case('Line 114, Column 18') }();
      var minz_93 = Bits.zorder(minCoord_85);
      var maxz_94 = Bits.zorder(maxCoord_86);
      return query$_96(tree_84);}();});
  var naiveQueryFold_18 = F5(function(f_116, a_117, tree_118, minCoord_119, maxCoord_120){
    return function(){
      var between_129 = function(_150000_139){
        return function(){ 
        switch (_150000_139.ctor) {
          case 'Tuple2':
            switch (_150000_139._0.ctor) {
              case 'Tuple2':
                return ((_N.cmp(_150000_139._0._1,y2_126).ctor==='GT') ? false : ((_N.cmp(_150000_139._0._1,y1_123).ctor==='LT') ? false : ((_N.cmp(_150000_139._0._0,x2_125).ctor==='GT') ? false : ((_N.cmp(_150000_139._0._0,x1_122).ctor==='LT') ? false : true))));
            }break;
        }_E.Case('Line 146, Column 9') }();};
      var query$_130 = F3(function(f_142, a_143, t_144){
        return function(){ 
        switch (t_144.ctor) {
          case 'RBEmpty':
            return a_143;
          case 'RBNode':
            return function(){
              var v$_149 = t_144._2;
              return ((_N.cmp(t_144._1,minz_127).ctor==='LT') ? A3(query$_130, f_142, a_143, t_144._4) : ((_N.cmp(t_144._1,maxz_128).ctor==='GT') ? A3(query$_130, f_142, a_143, t_144._3) : (between_129(t_144._2) ? A3(query$_130, f_142, A2(f_142, v$_149, A3(query$_130, f_142, a_143, t_144._3)), t_144._4) : A3(query$_130, f_142, A3(query$_130, f_142, a_143, t_144._3), t_144._4))));}();
        }_E.Case('Line 151, Column 22') }();});
      var _141000_121 = minCoord_119;
      var x1_122 = function(){ 
      switch (_141000_121.ctor) {
        case 'Tuple2':
          return _141000_121._0;
      }_E.Case('Line 141, Column 18') }();
      var y1_123 = function(){ 
      switch (_141000_121.ctor) {
        case 'Tuple2':
          return _141000_121._1;
      }_E.Case('Line 141, Column 18') }();
      var _142000_124 = maxCoord_120;
      var x2_125 = function(){ 
      switch (_142000_124.ctor) {
        case 'Tuple2':
          return _142000_124._0;
      }_E.Case('Line 142, Column 18') }();
      var y2_126 = function(){ 
      switch (_142000_124.ctor) {
        case 'Tuple2':
          return _142000_124._1;
      }_E.Case('Line 142, Column 18') }();
      var minz_127 = Bits.zorder(minCoord_119);
      var maxz_128 = Bits.zorder(maxCoord_120);
      return A3(query$_130, f_116, a_117, tree_118);}();});
  var tileToForm_19 = F2(function(vp_150, _163000_151){
    return function(){ 
    switch (_163000_151.ctor) {
      case 'Tuple2':
        return function(){
          var form_154 = A3(N.mapSprite, tileWidth_0, tileHeight_1, indexToSpriteCoord_11(_163000_151._1));
          return A2(move, A2(project_13, vp_150, _163000_151._0), form_154);}();
    }_E.Case('Line 162, Column 3') }();});
  var dimensions_20 = function(_167000_155){
    return function(){ 
    switch (_167000_155.ctor) {
      case 'ViewPort':
        return function(){
          var _166000_157 = _167000_155._0;
          var vw_158 = _166000_157.vw;
          var vh_159 = _166000_157.vh;
          return {ctor:"Tuple2", _0:vw_158, _1:vh_159};}();
    }_E.Case('Line 166, Column 3') }();};
  var mapLayer_21 = F2(function(vp_160, tree_161){
    return function(){
      var tiles_162 = A2(tilesInView_16, vp_160, tree_161);
      var tileForms_163 = A2(map, tileToForm_19(vp_160), tiles_162);
      return {ctor:"Tuple2", _0:group(tileForms_163), _1:tiles_162};}();});
  var tileWidth_0 = 16;
  var tileHeight_1 = tileWidth_0;
  var spriteWidth_2 = 19;
  var spriteHeight_3 = 10;
  var mapWidth_4 = 1024;
  var mapHeight_5 = mapWidth_4;
  var mapWidthP_6 = (mapWidth_4*tileWidth_0);
  var mapHeightP_7 = (mapHeight_5*tileHeight_1);
  elm.Native = elm.Native||{};
  var _ = elm.Native.Map||{};
  _.$op = {};
  _.ViewPort = ViewPort_8;
  _.viewPort = viewPort_9;
  _.extract = extract_10;
  _.tilesInViewBruteforce = tilesInViewBruteforce_14;
  _.mapTree = mapTree_15;
  _.tilesInView = tilesInView_16;
  _.mapLayer = mapLayer_21
  return elm.Map = _;
  };
Elm.Bits = function(elm){
  var N = Elm.Native, _N = N.Utils(elm), _L = N.List(elm), _E = N.Error(elm), _J = N.JavaScript(elm), _str = _J.toString;
  var $op = {};
  var _ = Elm.Text(elm); var Text = _; var hiding={link:1, color:1, height:1}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Prelude(elm); var Prelude = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Signal(elm); var Signal = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.List(elm); var List = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Maybe(elm); var Maybe = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Time(elm); var Time = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Element(elm); var Graphics = Graphics||{};Graphics.Element = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Color(elm); var Color = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Collage(elm); var Graphics = Graphics||{};Graphics.Collage = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var N = Elm.Native.Bits(elm);
  elm.Native = elm.Native||{};
  var _ = elm.Native.Bits||{};
  _.$op = {}
  return elm.Bits = _;
  };
Elm.Loader = function(elm){
  var N = Elm.Native, _N = N.Utils(elm), _L = N.List(elm), _E = N.Error(elm), _J = N.JavaScript(elm), _str = _J.toString;
  var $op = {};
  var _ = Elm.Text(elm); var Text = _; var hiding={link:1, color:1, height:1}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Prelude(elm); var Prelude = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Signal(elm); var Signal = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.List(elm); var List = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Time(elm); var Time = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Element(elm); var Graphics = Graphics||{};Graphics.Element = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Color(elm); var Color = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Graphics.Collage(elm); var Graphics = Graphics||{};Graphics.Collage = _; var hiding={}; for(var k in _){if(k in hiding)continue;eval('var '+k+'=_["'+k+'"]')}
  var _ = Elm.Http(elm); var Http = _;
  var Success = _.Success, sendGet = _.sendGet;
  var _ = Elm.Json(elm); var Json = _;
  var JsonValue = _.JsonValue, Null = _.Null, toJSObject = _.toJSObject, findNumber = _.findNumber, fromString = _.fromString;
  var _ = Elm.Maybe(elm); var Maybe = _;
  var Just = _.Just, Nothing = _.Nothing, maybe = _.maybe;
  var JS = Elm.JavaScript.Experimental(elm);
  var stringToJson_0 = function(string_3){
    return function(){ 
    var case0 = fromString(string_3);
    switch (case0.ctor) {
      case 'Just':
        return JS.toRecord(toJSObject(case0._0));
      case 'Nothing':
        return JS.fromRecord({
          _:{
          }});
    }_E.Case('Line 8, Column 23') }();};
  var httpToJson_1 = function(response_5){
    return function(){ 
    switch (response_5.ctor) {
      case 'Success':
        return Success(stringToJson_0(response_5._0));
    }
    return response_5; }();};
  var getJson_2 = function(url_7){
    return A2(lift,httpToJson_1,sendGet(constant(url_7)));};
  elm.Native = elm.Native||{};
  var _ = elm.Native.Loader||{};
  _.$op = {};
  _.stringToJson = stringToJson_0;
  _.httpToJson = httpToJson_1;
  _.getJson = getJson_2
  return elm.Loader = _;
  };Elm.Native.Map = function(elm){
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

    // window.tiles = [];

    // var width = 19, height = 10;
    // for (var i = width - 1; i >= 0; i--) {
    //     for (var j = height - 1; j >= 0; j--) {
    //         window.tiles.push({x: i, y: j + 1024 - 10, tile: j * width + i});
    //     };
    // };
    function tiles(){
        var a = [];
        var x = 524,
            y = 396;
        // The stack size limit in chrome is about 25k
        // var limit = (window.tiles.length/10)|0;
        for (var i = window.tiles.length - 1; i >= 0; i--) {
            var tile = window.tiles[i];
            if(Math.abs(tile.x - x) < 52 && Math.abs(tile.y - y) < 52){
                var elmTile = {
                    ctor: 'Tuple2',
                    _0: {
                        ctor: 'Tuple2',
                        _0: tile.x * 16,
                        _1: (1024 - tile.y) * 16
                    },
                    _1: tile.tile
                };
                a.push(elmTile);
            }
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
};Elm.Native.Bits = function(elm){
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