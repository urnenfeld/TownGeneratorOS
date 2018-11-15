package com.watabou.towngenerator.model.edgefeatures;

import com.watabou.towngenerator.model.EdgeFeature;

class NullFeature implements EdgeFeature {
  public var original: EdgeFeature

  public var width(get,null): Float;
  public function get_width(): Float {
    return this.original.width;
  }

  public function new(original: EdgeFeature) {
    this.original = original;
  }
}