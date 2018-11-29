package com.watabou.towngenerator.medieval.generators;

import openfl.errors.Error;
import com.watabou.utils.Random;

import com.watabou.towngenerator.medieval.Model;
import com.watabou.towngenerator.medieval.wards.*;

using com.watabou.utils.ArrayExtender;

class WardGenerator implements Generator {
  public static var WARDS:Array<Class<Ward>> = [
    CraftsmenWard, CraftsmenWard, MerchantWard, CraftsmenWard, CraftsmenWard, Cathedral,
    CraftsmenWard, CraftsmenWard, CraftsmenWard, CraftsmenWard, CraftsmenWard,
    CraftsmenWard, CraftsmenWard, CraftsmenWard, AdministrationWard, CraftsmenWard,
    Slum, CraftsmenWard, Slum, PatriciateWard, Market,
    Slum, CraftsmenWard, CraftsmenWard, CraftsmenWard, Slum,
    CraftsmenWard, CraftsmenWard, CraftsmenWard, MilitaryWard, Slum,
    CraftsmenWard, Park, PatriciateWard, Market, MerchantWard];

  public function new() {}

  public function generate(model: Model): Void {
    var unassigned = model.inner.copy();
    if (model.plaza != null) {
      model.plaza.ward = new Market(model, model.plaza);
      unassigned.remove(model.plaza);
    }

    // Assigning inner city gate wards
    if (model.wall != null)
      for (gate in model.gates)
        for (patch in model.patchByVertex(gate))
          if (patch.withinCity && patch.ward == null && Random.bool(0.5)) {
            patch.ward = new GateWard(model, patch);
            unassigned.remove(patch);
          }

    var wards = WARDS.copy();
    // some shuffling
    for (i in 0...Std.int(wards.length / 10)) {
      var index = Random.int(0, (wards.length - 1));
      var tmp = wards[index];
      wards[index] = wards[index + 1];
      wards[index+1] = tmp;
    }

    // Assigning inner city wards
    while (unassigned.length > 0) {
      var bestPatch:Patch = null;

      var wardClass = wards.length > 0 ? wards.shift() : Slum;
      var rateFunc = Reflect.field(wardClass, "rateLocation");

      if (rateFunc == null)
        do
          bestPatch = unassigned.random()
        while (bestPatch.ward != null);
      else
        bestPatch = unassigned.min(function(patch) {
          return patch.ward == null ? Reflect.callMethod(wardClass, rateFunc, [model, patch]) : Math.POSITIVE_INFINITY;
        });

      bestPatch.ward = Type.createInstance(wardClass, [model, bestPatch]);

      unassigned.remove(bestPatch);
    }

    // Outskirts
    // if (model.wall != null)
    //   for (gate in model.wall.gates)
    //     if (!Random.bool( 1 / (nPatches - 5) )) {
    //       for (patch in this.model.patchByVertex( gate ))
    //         if (patch.ward == null) {
    //           patch.withinCity = true;
    //           patch.ward = new GateWard( this.model, patch );
    //         }
    //   }

    // Calculating radius and processing countryside
    for (patch in model.patches)
      if (!patch.withinCity && patch.ward == null)
        patch.ward = Random.bool(0.2) && patch.shape.compactness >= 0.7 ?
          new Farm(model, patch) :
          new Ward(model, patch);

    for (patch in model.patches)
      if (patch.ward != null)
        patch.ward.createGeometry();
  }
}
