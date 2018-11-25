package com.watabou.towngenerator.model;

class EdgeFeature {
  public var width(get,null): Float;
  public function get_width(): Float { return 0; }

  public var offsets: {start: Float, end: Float};

  public function new(offsets: {start: Float, end: Float}) {
    this.offsets = offsets;
  }
}
