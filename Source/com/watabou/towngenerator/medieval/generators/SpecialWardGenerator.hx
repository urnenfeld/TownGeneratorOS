package com.watabou.towngenerator.medieval.generators;

import openfl.errors.Error;
import com.watabou.utils.Random;

import com.watabou.towngenerator.medieval.Model;
import com.watabou.towngenerator.medieval.wards.*;

class SpecialWardGenerator implements Generator {
  private var plazaNeeded: Bool;
  private var citadelNeeded: Bool;

  public function new() {
    this.plazaNeeded = Random.bool();
    this.citadelNeeded = Random.bool();
  }

  public function generate(model: Model): Void {
    if (plazaNeeded)
      model.plaza = model.inner[0];

    if (citadelNeeded) {
      model.citadel = model.inner.pop();

      if (model.citadel.shape.compactness < 0.75)
        throw new Error( "Bad citadel shape!" );

      var castle = new Castle(model, model.citadel);
      castle.wall.buildTowers();
      model.citadel.ward = castle;
    }
  }
}
