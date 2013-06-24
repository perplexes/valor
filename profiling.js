Array.prototype.max = function() {
  return Math.max.apply(null, this);
};

Array.prototype.min = function() {
  return Math.min.apply(null, this);
};

Object.prototype.foldl = function(f, a){
  for (var i in this) {
    if (this.hasOwnProperty(i)) {
      a = f(a, i, this[i]);  
    }
  };
  return a;
}

Object.prototype.map = function(f) {
  return this.foldl([], function(a, i, e){
    a.push(f(i, e));
    return a;
  });
}

Array.prototype.sum = function() {
  this.foldl(0, function(a, i, e){return a + e;});
}

Array.prototype.avg = function() {
  this.sum() / this.length;
}


function Profiling(keyFunc, pauseOn){
  this.keyFunc = keyfunc;
  this.pauseOn = pauseOn;
  this.samples = {};
  this.sampleCount = 0;
  this.profile = function(obj, func){
    if(typeof samples[keyFunc(obj)] == 'undefined'){
      samples[keyFunc(obj)] = [];
    }
    var start = window.performance.now()
    var result = func();
    samples[keyFunc(obj)].push(window.performance.now() - start);

    return result;
  }

  this.breakdown = function(){
    return samples.inject({}, function(a, i, e){
      a[i] = {sum: e.sum, avg: e.avg, max: e.max, min: e.min};
      return a;
    });
  }
}

    if(typeof window.profile_count == 'undefined'){
        window.profile_count = 0;
    }
    if(typeof window.profiles == 'undefined'){
        window.profiles = {};
    }
    if(!window.profiles[form.form.ctor]){
       window.profiles[form.form.ctor] = []; 
    }

        window.profiles[form.form.ctor].push(Date.now() - start);
    if(window.profile_count++ >= 10000){
        debugger;
    }