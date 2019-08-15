package com.watabou.towngenerator.ui;

import com.watabou.coogee.Game;
import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Model;

import com.watabou.towngenerator.mapping.Palette;
import com.watabou.towngenerator.mapping.CityMap;

import openfl.errors.Error;


class CityStyleButton extends Button {

    static private var palettes	: Array<Palette> = [];
    static private var rotatorIndex: Int = 0;

	public function new( label:String, minSize:Int, maxSize:Int ) {
		super( label );
		click.add( onClick );
	}

	private function onClick():Void {

            trace("Changing palette");
            CityMap.palette = Palette.another();
            CityMap.instance.reDraw();
	}
}
