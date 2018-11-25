package com.watabou.towngenerator.model.edgefeatures;

import com.watabou.towngenerator.model.EdgeFeature;

class WallFeature extends EdgeFeature {
  override public function get_width(): Float {
    return 2;
  }
}
