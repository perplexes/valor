var sf = sf || {};

// CLASSES

sf.Vector2D = function(x, y) {
  this.x = typeof x === 'undefined' ? 0 : x;
  this.y = typeof y === 'undefined' ? 0 : y;
  
  this.add = function(v) {
    this.x += v.x;
    this.y += v.y;
    return this;
  };
  
  this.subtract = function(v) {
    this.x -= v.x;
    this.y -= v.y;
    return this;
  };
  
  this.multiply = function(v) {
    this.x *= v.x;
    this.y *= v.y;
    return this;
  };
  
  // Calculate the perpendicular vector (normal)
  // http://en.wikipedia.org/wiki/Perpendicular_vector
  // @param void
  // @return vector
  this.perp = function() {
    this.y = -this.y;
    return this;
  };
  
  // Calculate the length of a the vector
  this.getLength = function() {
    return Math.sqrt((this.x * this.x) + (this.y * this.y));
  };
  
  /**
   * Sets the length which will change x and y, but not the angle.
   */
  this.setLength = function(value) {
    var _angle = angle;
    this.x = Math.cos(_angle) * value;
    this.y = Math.sin(_angle) * value;
    if (Math.abs(this.x) < 0.00000001) this.x = 0;
    if (Math.abs(this.y) < 0.00000001) this.y = 0;
  };
  
  this.getAngle = function() {
    return Math.atan2(this.y, this.x);
  };
  
  /**
   * Calculate the length of a the vector.
   * @param {Number} value 
   */
  this.setAngle = function(value) {
    var len = this.getLength();
    this.x = Math.cos(value) * len;
    this.y = Math.sin(value) * len;
  };
  
  /**
   * Calculate angle between any two vectors.
   * Warning: creates two new Vector2D objects! EXPENSIVE
   * @param {Vector2D} v1   First vec
   * @param {Vector2D} v2   Second vec
   * @return {Number} Angle between vectors.
   */
  this.angleBetween = function(v1, v2) {
    v1 = v1.clone().normalize();
    v2 = v2.clone().normalize();
    return Math.acos(v1.dotProduct(v2));
  };
  
  /**
   * Calculate a vector dot product.
   * @param {Vector2D} v A vector
   * @return {Number} The dot product
   */
  this.dotProduct = function(v) {
    return (this.x * v.x + this.y * v.y);
  };
  
  /**
   * Calculate the cross product of this and another vector.
   * @param {Vector2D} v A vector
   * @return {Number} The cross product
   */
  this.crossProd = function(v) {
    return this.x * v.y - this.y * v.x;
  }
  
  this.truncate = function(max) {
    var l = this.getLength();
    if (l > max) this.setLength(l);
    return this;
  };
  
  /**
   * Normalize the vector
   * @return {Vector2D}
   */
  this.normalize = function() {
    var length = this.getLength();
    this.x = this.x / length;
    this.y = this.y / length;
    return this;
  };
  
  this.reset = function(x, y) {
    this.x = typeof x === 'undefined' ? 0 : x;
    this.y = typeof y === 'undefined' ? 0 : y;
    return this;
  };
  
  this.copy = function(v) {
    this.x = v.x;
    this.y = v.y;
    return this;
  };
  
  this.clone = function() {
    return new sf.Vector2D(this.x, this.y);
  };
  
  /**
   * Visualize this vector.
   * @param {type} context      HTML canvas 2D context to draw to.
   * @param {type} [startX]       X offset to draw from.
   * @param {type} [startY]       Y offset to draw from.
   * @param {type} [drawingColor]   CSS-compatible color to use.
   */
  this.draw = function(context, startX, startY, drawingColor) {
    startX = typeof startX === 'undefined' ? 0 : startX;
    startY = typeof startY === 'undefined' ? 0 : startY;
    drawingColor = typeof drawingColor === 'undefined' ? 'rgb(0, 250, 0)' : drawingColor;
    context.strokeStyle = drawingColor;
    context.beginPath();
    context.moveTo(startX, startY);
    context.lineTo(startX+this.x, startY+this.y);
    context.stroke();
  };
};

sf.Manifold = function() {
  this.a = null; // AABB
  this.b = null; // AABB
  this.penetration = 0;
  this.normal = null; // Vector2D
};

sf.AABB = function(_x, _y, _settings) {
  this.x = _x;
  this.y = _y;
  this.width = 50;
  this.height = 50;
  
  this.min = new sf.Vector2D();
  this.max = new sf.Vector2D();
  
  this.mass = 100; // 0 is immobile
  this.invmass = 0;
  this.restitution = 0.4; // bounciness
  this.velocity = new sf.Vector2D(Math.random()*70 - 35, Math.random()*70 - 35);
  
  // this.scratchVec = new sf.Vector2D();
  
  // internal
  var _self = this;
  
  this.update = function() {    
    _self.x += _self.velocity.x * sf.elapsed;
    _self.y += _self.velocity.y * sf.elapsed;
    
    if (_self.x < 0) {
      _self.x = 0;
      _self.velocity.x = -_self.velocity.x;
    } else if (_self.x+_self.width > sf.worldWidth) {
      _self.x = sf.worldWidth-_self.width;
      _self.velocity.x = -_self.velocity.x;
    }
    if (_self.y < 0) {
      _self.y = 0;
      _self.velocity.y = -_self.velocity.y;
    } else if (_self.y+_self.height > sf.worldHeight) {
      _self.y = sf.worldHeight-_self.height;
      _self.velocity.y = -_self.velocity.y;
    }
    
    _self.min.reset(_self.x, _self.y);
    _self.max.reset(_self.x+_self.width, _self.y+_self.height);
  };
  
  this.setMass = function(newMass) {
    this.mass = newMass;
    if (newMass <= 0) {
      this.invmass = 0;
    } else {
      this.invmass = 1/newMass;
    }
  };
  
  this.draw = function() {
    sf.ctx.fillStyle = 'rgba(0, 10, 150, 0.5)'; // DEBUG
      sf.ctx.fillRect(_self.x, _self.y, _self.width, _self.height); // DEBUG
  };
  
  if (typeof _settings !== 'undefined') {
    for (var attr in _settings) {
      if (_self.hasOwnProperty(attr)) _self[attr] = _settings[attr];
    }
  }
  
  _self.setMass(_self.mass); // make sure invmass is set
  // console.log(_self);
};

(function () {
var ctx, mouseX, mouseY, trackRect, numRects = 2,
  PI = Math.PI, halfPI = Math.PI/2, pi2 = PI*2, rad = 0.0174532925199, // Math.PI/180
  rects = [], _mark = 0;

sf.worldWidth = 400;
sf.worldHeight = 300;
// -------------------------------------
// DEBUG DRAWING

function debugDrawRect(x, y, width, height, rotation) {
  var halfWidth = width/2;
  var halfHeight = height/2;
  ctx.save();
    ctx.translate(x, y);
    ctx.rotate(rotation);
    
    ctx.fillStyle = 'rgba(50, 0, 50, 0.2)';
    ctx.fillRect(-halfWidth, -halfHeight, width, height);
    
    ctx.restore();
}

function debugDrawPoint(x, y, c) {
  c = typeof c === 'undefined' ? 'rgba(250, 0, 0, 3)' : c;
  ctx.fillStyle = c;
    ctx.fillRect(x-2, y-2, 4, 4);
}

function debugDrawVector(v, c) {
  c = typeof c === 'undefined' ? 'rgba(250, 0, 0, 0.3)' : c;
  ctx.fillStyle = c;
    ctx.fillRect(v.x-2, v.y-2, 4, 4);
}

// -------------------------------------
// COLLISION


function AABBvsAABB(a, b) {
  if (a.max.x < b.min.x || a.min.x > b.max.x) return false;
  if (a.max.y < b.min.y || a.min.y > b.max.y) return false;
  // if (a.max.z < b.min.z || a.min.z > b.max.z) return false;
  return true;
}

var normal = new sf.Vector2D();
var manifold = new sf.Manifold();
function overlapAABB(a, b) {
  // Vector from A to B
  normal.reset(b.x - a.x, b.y - a.y);
  
  // Calculate half extents along x axis for each object
  var a_extent = (a.max.x - a.min.x) / 2;
  var b_extent = (b.max.x - b.min.x) / 2;
  
  // Calculate overlap on x axis
  var x_overlap = a_extent + b_extent - Math.abs( normal.x );
 
  // SAT test on x axis
  if (x_overlap > 0) {
    a_extent = (a.max.y - a.min.y) / 2; // var
    b_extent = (b.max.y - b.min.y) / 2;
    
    // Calculate overlap on y axis
    var y_overlap = a_extent + b_extent - Math.abs( normal.y );
 
    // SAT test on y axis
    if (y_overlap > 0) {
      // Find out which axis is axis of least penetration
      if (x_overlap < y_overlap) {
        // Point towards B knowing that dist points from A to B
        if (normal.x < 0) {
          manifold.normal = normal.reset(-1, 0);
        } else {
          manifold.normal = normal.reset(1, 0);
        }
        manifold.penetration = x_overlap;
        return manifold;
      } else {
        // Point toward B knowing that dist points from A to B
        if (normal.y < 0) {
          manifold.normal = normal.reset(0, -1);
        } else {
          manifold.normal = normal.reset(0, 1);
        }
        manifold.penetration = y_overlap;
        return manifold;
      }
    }
  }
  return null;
}

var rv = new sf.Vector2D( );
var _impulse = new sf.Vector2D();
// var trac = 0;
function resolveCollision(a, b, m) {
  // Calculate relative velocity
  rv.reset( b.velocity.x - a.velocity.x, b.velocity.y - a.velocity.y );
  
  // Calculate relative velocity in terms of the normal direction
    var velAlongNormal = rv.dotProduct(m.normal);
  
  // Do not resolve if velocities are separating
  if (velAlongNormal > 0) {
         console.log( 'separating velocity' )
     return;
  }
  
  // Calculate restitution
  var e = Math.min(a.restitution, b.restitution);
  
  // Calculate impulse scalar
  var j = -(1 + e) * velAlongNormal;
  j /= a.invmass + b.invmass;
  
  // Apply impulse
  _impulse.reset(m.normal.x * j, m.normal.y * j);
  
  a.velocity.x -= (a.invmass * _impulse.x);
  a.velocity.y -= (a.invmass * _impulse.y);
  
  b.velocity.x += (b.invmass * _impulse.x);
  b.velocity.y += (b.invmass * _impulse.y);
  
  var percent = 0.8; // usually 20% to 80%
  var slop = 0.01; // usually 0.01 to 0.1
  var c = Math.max(m.penetration - slop, 0) / (a.invmass + b.invmass) * percent * m.normal;
  a.position -= a.invmass * c;
  b.position += b.invmass * c;
}

// -------------------------------------
// APP MANAGEMENT
var _drawVec = new sf.Vector2D();
function tick() {
  ctx.clearRect(0, 0, sf.worldWidth, sf.worldHeight);
  
  var now = Date.now(),
    dt = now - _mark;
  
  _mark = now;
  sf.elapsed = dt * 0.001;
  // console.log(sf.elapsed);
  var i, j, a, b;
  for (i = 0; i < numRects; ++i) {
    rects[i].update();
  }
  
  var m;
  for (i = 0; i < (numRects-1); ++i) {
    a = rects[i];
    
    for (j = i + 1; j < numRects; ++j) {
      b = rects[j];
      
      m = overlapAABB(a, b);
      if (m) {
                resolveCollision( a, b, m );
      }
    }
  }
  
  for (i = 0; i < numRects; ++i) {
    rects[i].draw();
  }
  
  window.webkitRequestAnimationFrame(tick);
}

function mouseMove(evt) {
  trackRect.x = evt.clientX - mouseX;
  trackRect.y = evt.clientY - mouseY;
}

// INITIALIZE 
  var canvas = document.getElementsByTagName('canvas')[0];
  canvas.width = sf.worldWidth;//window.innerWidth;
  canvas.height = sf.worldHeight;//window.innerHeight;
  sf.ctx = ctx = canvas.getContext('2d');
  
  var i, r,
    a = 0, ao = pi2 / numRects,
    wx = sf.worldWidth/2,
    wy = sf.worldHeight/2;
  
  for (i = 0; i < numRects; i++) {
    r = new sf.AABB(Math.cos(a) * 100 + wx,
            Math.sin(a) * 100 + wy,
            {});
    a += ao;
    rects[i] = r;
  }
  
  document.addEventListener('mousedown', function(evt){
    trackRect = null;
    mouseX = evt.clientX;
    mouseY = evt.clientY;
    for (i = 0; i < numRects; i++) {
      r = rects[i];
      if (mouseX < r.min.x || mouseX > r.max.x) continue;
      if (mouseY < r.min.y || mouseY > r.max.y) continue;
      trackRect = r;
      break;
    }
    if (trackRect) {
      mouseX -= trackRect.x;
      mouseY -= trackRect.y;
      document.addEventListener('mousemove', mouseMove, false);
    }
  }, false);
  
  document.addEventListener('mouseup', function(evt){
    if (trackRect) {
      document.removeEventListener('mousemove', mouseMove);
    }
  }, false);
  
  mouseX = wx;
  mouseY = wy;
  
  _mark = Date.now();
  tick();
  
}());
