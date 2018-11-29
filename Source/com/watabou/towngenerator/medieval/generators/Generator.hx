package com.watabou.towngenerator.medieval.generators;

import com.watabou.towngenerator.medieval.Model;

interface Generator {
  public function generate(model: Model): Void;
}
