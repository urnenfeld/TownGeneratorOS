package com.watabou.towngenerator.model.edgefeatures;

import com.watabou.towngenerator.model.EdgeFeature;

enum RoadType {
  Alley;
  Street;
  Road;
  Avenue;
}

class RoadFeature extends EdgeFeature {
  public var type: RoadType;

  override public function get_width(): Float {
    switch (this.type) {
      case Alley: return 0.6;
      case Street: return 1;
      case Road, Avenue: return 2;
    }
  }

	public function new(offsets: {start: Float, end: Float}, type: RoadType) {
    super(offsets);
    this.type = type;
	}
}
