package com.watabou.towngenerator.model;

import openfl.geom.Point;
import com.watabou.geom.Segment;

class Edge extends Segment {
  public var features: Array<EdgeFeature> = [];
  public var mainFeature: EdgeFeature;

  public function new(start: Point, end: Point, feature: EdgeFeature) {
    super(start, end);
    this.mainFeature = feature;
  }
}
