package com.watabou.towngenerator.medieval;

import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Voronoi.Region;

import com.watabou.towngenerator.model.Edge;
import com.watabou.towngenerator.medieval.wards.Ward;

class Patch {

  public var edges  : Array<Edge>;
	public var shape	: Polygon;
	public var ward 	: Ward;

	public var withinWalls	: Bool = false;
	public var withinCity	: Bool = false;

	public inline function new(vertices: Array<Point>, edges: Array<Edge>) {
		this.shape = new Polygon( vertices );
    this.edges = edges;
	}
}
