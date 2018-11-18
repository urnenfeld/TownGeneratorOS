package com.watabou.towngenerator.medieval;

import Type;
import openfl.geom.Point;
import openfl.errors.Error;

import com.watabou.geom.Polygon;
import com.watabou.geom.Segment;
import com.watabou.geom.Voronoi;
import com.watabou.utils.MathUtils;
import com.watabou.utils.Random;

import com.watabou.towngenerator.medieval.wards.*;
import com.watabou.towngenerator.model.Edge;

using com.watabou.utils.PointExtender;
using com.watabou.utils.ArrayExtender;

class Generator {

  public var model: Model;

	// Small Town	6
	// Large Town	10
	// Small City	15
	// Large City	24
	// Metropolis	40
	private var nPatches	: Int;

	private var plazaNeeded		: Bool;
	private var citadelNeeded	: Bool;
	private var wallsNeeded		: Bool;

	public static var WARDS:Array<Class<Ward>> = [
		CraftsmenWard, CraftsmenWard, MerchantWard, CraftsmenWard, CraftsmenWard, Cathedral,
		CraftsmenWard, CraftsmenWard, CraftsmenWard, CraftsmenWard, CraftsmenWard,
		CraftsmenWard, CraftsmenWard, CraftsmenWard, AdministrationWard, CraftsmenWard,
		Slum, CraftsmenWard, Slum, PatriciateWard, Market,
		Slum, CraftsmenWard, CraftsmenWard, CraftsmenWard, Slum,
		CraftsmenWard, CraftsmenWard, CraftsmenWard, MilitaryWard, Slum,
		CraftsmenWard, Park, PatriciateWard, Market, MerchantWard];

	public function new( nPatches=-1, seed=-1 ) {
		if (seed > 0) Random.reset( seed );
		this.nPatches = nPatches != -1 ? nPatches : 15;

		plazaNeeded		= Random.bool();
		citadelNeeded	= Random.bool();
		wallsNeeded		= Random.bool();

    this.model = new Model();
    generate();
  }

	public function generate():Void {
		buildPatches();
		optimizeJunctions();
    buildWalls();
    buildStreets();
    createWards();
    buildGeometry();
	}

	private function buildPatches():Void {
		var sa = Random.float() * 2 * Math.PI;
		var points = [for (i in 0...nPatches * 8) {
			var a = sa + Math.sqrt( i ) * 5;
			var r = (i == 0 ? 0 : 10 + i * (2 + Random.float()));
			new Point( Math.cos( a ) * r, Math.sin( a ) * r );
		}];
		var voronoi = Voronoi.build( points );

		// Relaxing central wards
		for (i in 0...3) {
			var toRelax = [for (j in 0...3) voronoi.points[j]];
			toRelax.push( voronoi.points[nPatches] );
			voronoi = Voronoi.relax( voronoi, toRelax );
		}

		voronoi.points.sort( function( p1:Point, p2:Point )
			return MathUtils.sign( p1.length - p2.length ) );
		var regions = voronoi.partioning();

		var count = 0;
		for (r in regions) {
      var shape = new Polygon([for (tr in r.vertices) tr.c]);
      var edges = [];

      shape.forEdge(function (p1, p2) {
        var edge = this.model.findEdge(p1, p2);
        if (edge == null) edge = this.model.addEdge(p1, p2);
        edges.push(edge);
      });

      var patch = new Patch(shape, edges);
			this.model.patches.push( patch );

			if (count == 0) {
				this.model.center = patch.shape.min( function( p:Point ) return p.length );
				if (plazaNeeded)
					this.model.plaza = patch;
			} else if (count == nPatches && citadelNeeded) {
				this.model.citadel = patch;
				patch.withinCity = true;
			}

			if (count < nPatches) {
				patch.withinCity = true;
				patch.withinWalls = wallsNeeded;
				this.model.inner.push( patch );
			}

			count++;
		}
	}

	private function buildWalls():Void {
		var reserved = this.model.citadel != null ? this.model.citadel.shape.copy() : [];

		this.model.border = new CurtainWall( wallsNeeded, this.model, this.model.inner, reserved );
		if (wallsNeeded) {
			this.model.wall = this.model.border;
			this.model.wall.buildTowers();
		}

		var radius = this.model.border.getRadius();
		this.model.patches = this.model.patches.filter( function( p:Patch ) return p.shape.distance( this.model.center ) < radius * 3 );

		this.model.gates = this.model.border.gates;

		if (this.model.citadel != null) {
			var castle = new Castle( this.model, this.model.citadel );
			castle.wall.buildTowers();
			this.model.citadel.ward = castle;

			if (this.model.citadel.shape.compactness < 0.75)
				throw new Error( "Bad citadel shape!" );

			this.model.gates = this.model.gates.concat( castle.wall.gates );
		}
	}

	private function buildStreets():Void {

		function smoothStreet( street:Street ):Void {
			var smoothed = street.smoothVertexEq( 3 );
			for (i in 1...street.length-1)
				street[i].set( smoothed[i] );
		}

		var topology = new Topology(this.model);

		for (gate in this.model.gates) {
			// Each gate is connected to the nearest corner of the plaza or to the central junction
			var end:Point = this.model.plaza != null ?
				this.model.plaza.shape.min( function( v ) return Point.distance( v, gate ) ) :
				this.model.center;

			var street = topology.buildPath( gate, end, topology.outer );
			if (street != null) {
				this.model.streets.push( street );

				if (this.model.border.gates.contains( gate )) {
					var dir = gate.norm( 1000 );
					var start = null;
					var dist = Math.POSITIVE_INFINITY;
					for (p in topology.node2pt) {
						var d = Point.distance( p, dir );
						if (d < dist) {
							dist = d;
							start = p;
						}
					}

					var road = topology.buildPath( start, gate, topology.inner );
					if (road != null)
						this.model.roads.push( road );
				}
			} else
				throw new Error( "Unable to build a street!" );
		}

		tidyUpRoads();

		for (a in this.model.arteries)
			smoothStreet( a );
	}

	private function tidyUpRoads() {
		var segments = new Array<Segment>();
		function cut2segments( street:Street ) {
			var v0:Point = null;
			var v1:Point = street[0];
			for (i in 1...street.length) {
				v0 = v1;
				v1 = street[i];

				// Removing segments which go along the plaza
				if (this.model.plaza != null && this.model.plaza.shape.contains( v0 ) && this.model.plaza.shape.contains( v1 ))
					continue;

				var exists = false;
				for (seg in segments)
					if (seg.start == v0 && seg.end == v1) {
						exists = true;
						break;
					}

				if (!exists)
					segments.push( new Segment( v0, v1 ) );
			}
		}

		for (street in this.model.streets)
			cut2segments( street );
		for (road in this.model.roads)
			cut2segments( road );

		while (segments.length > 0) {
			var seg = segments.pop();

			var attached = false;
			for (a in this.model.arteries)
				if (a[0] == seg.end) {
					a.unshift( seg.start );
					attached = true;
					break;
				} else if (a.last() == seg.start) {
					a.push( seg.end );
					attached = true;
					break;
				}

			if (!attached)
				this.model.arteries.push( [seg.start, seg.end] );
		}
	}

	private function optimizeJunctions():Void {

		var patchesToOptimize:Array<Patch> =
			this.model.citadel == null ? this.model.inner : this.model.inner.concat( [this.model.citadel] );

		var wards2clean:Array<Patch> = [];
		for (w in patchesToOptimize) {
			var index = 0;
			while (index < w.shape.length) {

				var v0:Point = w.shape[index];
				var v1:Point = w.shape[(index + 1) % w.shape.length];

				if (v0 != v1 && Point.distance( v0, v1 ) < 8) {
					for (w1 in this.model.patchByVertex( v1 )) if (w1 != w) {
						w1.shape[w1.shape.indexOf( v1 )] = v0;
						wards2clean.push( w1 );
					}

					v0.addEq( v1 );
					v0.scaleEq( 0.5 );

					w.shape.remove( v1 );
				}
				index++;
			}
		}

		// Removing duplicate vertices
		for (w in wards2clean)
			for (i in 0...w.shape.length) {
				var v = w.shape[i];
				var dupIdx;
				while ((dupIdx = w.shape.indexOf( v, i + 1 )) != -1)
					w.shape.splice( dupIdx, 1 );
			}
	}

	private function createWards():Void {
		var unassigned = this.model.inner.copy();
		if (this.model.plaza != null) {
			this.model.plaza.ward = new Market( this.model, this.model.plaza );
			unassigned.remove( this.model.plaza );
		}

		// Assigning inner city gate wards
    if (this.model.border != null)
  		for (gate in this.model.border.gates)
  			for (patch in this.model.patchByVertex( gate ))
  				if (patch.withinCity && patch.ward == null && Random.bool( this.model.wall == null ? 0.2 : 0.5 )) {
  					patch.ward = new GateWard( this.model, patch );
  					unassigned.remove( patch );
  				}

		var wards = WARDS.copy();
		// some shuffling
		for (i in 0...Std.int(wards.length / 10)) {
			var index = Random.int( 0, (wards.length - 1) );
			var tmp = wards[index];
			wards[index] = wards[index + 1];
			wards[index+1] = tmp;
		}

		// Assigning inner city wards
		while (unassigned.length > 0) {
			var bestPatch:Patch = null;

			var wardClass = wards.length > 0 ? wards.shift() : Slum;
			var rateFunc = Reflect.field( wardClass, "rateLocation" );

			if (rateFunc == null)
				do
					bestPatch = unassigned.random()
				while (bestPatch.ward != null);
			else
				bestPatch = unassigned.min( function( patch:Patch ) {
					return patch.ward == null ? Reflect.callMethod( wardClass, rateFunc, [this.model, patch] ) : Math.POSITIVE_INFINITY;
				} );

			bestPatch.ward = Type.createInstance( wardClass, [this.model, bestPatch] );

			unassigned.remove( bestPatch );
		}

		// Outskirts
		if (this.model.wall != null)
			for (gate in this.model.wall.gates) if (!Random.bool( 1 / (nPatches - 5) )) {
				for (patch in this.model.patchByVertex( gate ))
					if (patch.ward == null) {
						patch.withinCity = true;
						patch.ward = new GateWard( this.model, patch );
					}
			}

		// Calculating radius and processing countryside
		for (patch in this.model.patches)
      if (!patch.withinCity && patch.ward == null)
				patch.ward = Random.bool( 0.2 ) && patch.shape.compactness >= 0.7 ?
					new Farm( this.model, patch ) :
					new Ward( this.model, patch );
	}

	private function buildGeometry()
		for (patch in this.model.patches)
      if (patch.ward != null)
			  patch.ward.createGeometry();
}
