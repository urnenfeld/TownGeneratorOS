package com.watabou.towngenerator.medieval;

import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Voronoi.Region;

import com.watabou.towngenerator.medieval.wards.Ward;

class Patch {

	public var shape	: Polygon;
	public var ward 	: Ward;

	public var withinWalls	: Bool = false;
	public var withinCity	: Bool = false;

	public inline function new( vertices:Array<Point> ) {
		this.shape = new Polygon( vertices );
	}
}
