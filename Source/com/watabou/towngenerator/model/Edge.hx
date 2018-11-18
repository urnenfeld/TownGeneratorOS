package com.watabou.towngenerator.model;

import openfl.geom.Point;
import com.watabou.geom.Segment;

class Edge extends Segment {
  public var features: Array<EdgeFeature> = [];
  public var mainFeature: EdgeFeature;
  public var width(get,null): Float;
  public function get_width(): Float {
    var width: Float = 0;
    for (feature in features) {
      width += feature.width;
    }
    return width;
  }
}
