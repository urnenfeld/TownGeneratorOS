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

		// Fake a static constructor
        if (palettes.length == 0) {
            palettes.push(Palette.DEFAULT);
            palettes.push(Palette.BLUEPRINT);
            palettes.push(Palette.BW);
            palettes.push(Palette.INK);
            palettes.push(Palette.NIGHT);
            palettes.push(Palette.ANCIENT);
            palettes.push(Palette.COLOUR);
            palettes.push(Palette.SIMPLE);
            palettes.push(Palette.MOJEEB);
		}

		click.add( onClick );
	}

	private function onClick():Void {

        if (rotatorIndex < (palettes.length - 1))
            rotatorIndex++;
        else 
            rotatorIndex = 0;

        CityMap.palette = palettes[rotatorIndex];
        
        // "safe" place to invoke stage
        stage.color = CityMap.palette.paper;
        CityMap.instance.reDraw();
	}
}
