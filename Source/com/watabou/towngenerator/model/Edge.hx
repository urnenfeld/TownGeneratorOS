package com.watabou.towngenerator.model;

import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Segment;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

class Edge extends Segment {
  public var features: Array<EdgeFeature> = [];
  public var width(get,null): Float;
  public function get_width(): Float {
    var width: Float = 0;
    for (feature in features) {
      width += feature.width;
    }
    return width;
  }

  public var left(get,null): Segment;
  public function get_left(): Segment {
    if (this.features.length == 0) return new Segment(this.start, this.end);

    var normal = this.vector.rotate90().scale(-1);
    var feature = this.features.min(function(f) return f.offsets.start);
    var startOffset = feature.offsets.start - (feature.width / 2);
    var endOffset = feature.offsets.end - (feature.width / 2);
    var startNormal = normal.scale(Math.abs(startOffset) / this.length);
    var endNormal = normal.scale(Math.abs(endOffset) / this.length);

    return new Segment(this.start.add(startNormal), this.end.add(endNormal));
  }


  public var right(get,null): Segment;
  public function get_right(): Segment {
    if (this.features.length == 0) return new Segment(this.start, this.end);

    var normal = this.vector.rotate90();
    var feature = this.features.max(function(f) return f.offsets.start);
    var startOffset = feature.offsets.start + (feature.width / 2);
    var endOffset = feature.offsets.end + (feature.width / 2);
    var startNormal = normal.scale(Math.abs(startOffset) / this.length);
    var endNormal = normal.scale(Math.abs(endOffset) / this.length);

    return new Segment(this.start.add(startNormal), this.end.add(endNormal));
  }
}
