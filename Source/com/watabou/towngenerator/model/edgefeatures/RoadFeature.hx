package com.watabou.towngenerator.model.edgefeatures;

import com.watabou.towngenerator.model.EdgeFeature;

enum RoadType {
  Road;
  Street;
  Avenue;
}

class RoadFeature implements EdgeFeature {
  public var type: RoadType;

  public var width(get,null): Float;
  public function get_width(): Float {
    return 5;
  }

	public function new(type: RoadType) {
    this.type = type;
	}
}
