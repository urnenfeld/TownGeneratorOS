package com.watabou.towngenerator.model.edgefeatures;

import com.watabou.towngenerator.model.EdgeFeature;

enum RoadType {
  Road;
  Street;
  Avenue;
}

class RoadFeature implements EdgeFeature {
  public var type: RoadType;

	public function new(type: RoadType) {
    this.type = type;
	}
}
