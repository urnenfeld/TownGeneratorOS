package com.watabou.towngenerator.medieval;

import com.watabou.utils.Random;
import com.watabou.towngenerator.medieval.generators.Generator as IGenerator;
import com.watabou.towngenerator.medieval.generators.*;

class Generator {
  public var model: Model = new Model();
  private var nPatches  : Int = 15;
  private var generators: Array<IGenerator>;

  public function new(nPatches = null, seed = -1) {
    if (seed > 0) Random.reset(seed);
    if (nPatches != null) this.nPatches = nPatches;

    this.generators = [
      new VoronoiGenerator(nPatches),
      new SpecialWardGenerator(),
      new RoadGenerator(),
      new WallGenerator(),
      new WardGenerator()
    ];

    generate();
  }

  public function generate():Void {
    for (g in generators) g.generate(model);
  }
}
