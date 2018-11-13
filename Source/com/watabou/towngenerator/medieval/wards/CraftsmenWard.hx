package com.watabou.towngenerator.medieval.wards;

import com.watabou.utils.Random;

import com.watabou.towngenerator.medieval.Patch;
import com.watabou.towngenerator.medieval.Model;

class CraftsmenWard extends CommonWard {

	public function new( model:Model, patch:Patch )
		super( model, patch,
			10 + 80 * Random.float() * Random.float(),	// small to large
			0.5 + Random.float() * 0.2, 0.6 );			// moderately regular

	override public inline function getLabel() return "Craftsmen";
}
