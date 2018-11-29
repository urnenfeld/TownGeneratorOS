package com.watabou.towngenerator.medieval.generators;

import com.watabou.utils.Random;

import com.watabou.towngenerator.medieval.Model;
import com.watabou.towngenerator.model.edgefeatures.*;

class WallGenerator implements Generator {
  private var wallNeeded    : Bool;

  public function new() {
    this.wallNeeded = Random.bool();
  }

  public function generate(model: Model): Void {
    if (wallNeeded) {
      for (i in 0...model.inner.length) {
        model.inner[i].withinWalls = this.wallNeeded;
      }

      var reserved = model.citadel != null ? model.citadel.shape.copy() : [];

      model.wall = new CurtainWall(true, model, model.inner, reserved);
      model.wall.buildTowers();

      model.wall.shape.forEdge(function(p1, p2) {
        var edge = model.findEdge(p1, p2);
        model.addEdgeFeature(p1, p2, new WallFeature({start: 0, end: 0}));
        model.addEdgeFeature(p1, p2, new RoadFeature({start: 1.5, end: 1.5}, Street));
      });
    }
  }
}
