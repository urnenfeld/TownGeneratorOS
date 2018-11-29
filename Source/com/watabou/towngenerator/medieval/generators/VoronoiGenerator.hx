package com.watabou.towngenerator.medieval.generators;

import openfl.geom.Point;
import com.watabou.geom.Polygon;
import com.watabou.geom.Voronoi;
import com.watabou.utils.Random;

import com.watabou.towngenerator.medieval.Model;

using com.watabou.utils.PointExtender;
using com.watabou.utils.ArrayExtender;

class VoronoiGenerator implements Generator {
  private var nPatches: Int;

  public function new(nPatches = -1) {
    this.nPatches = nPatches != -1 ? nPatches : 15;
  }

  public function generate(model: Model): Void {
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

    voronoi.points.sort(function(p1, p2) return p1.length - p2.length > 0 ? 1 : -1);
    // return MathUtils.sign( p1.length - p2.length ) );

    var regions = voronoi.partioning();
    var shapes = [for (r in regions) new Polygon([for (tr in r.vertices) tr.c])];

    this.optimizeShapes(shapes);

    var count = 0;
    for (shape in shapes) {
      var edges = [];

      shape.forEdge(function (p1, p2) {
        edges.push(model.findOrAddEdge(p1, p2));
      });

      var patch = new Patch(shape, edges);
      model.patches.push(patch);

      if (count == 0)
        model.center = patch.shape.min(function(p) return p.length);

      if (count <= nPatches) {
        model.inner.push(patch);
        patch.withinCity = true;
      }

      count++;
    }
  }

  private function optimizeShapes(shapes: Array<Polygon>):Void {
    var shapesToClean: Array<Polygon> = [];

    for (shape in shapes) {
      var idx = 0;
      while (idx < shape.length) {
        var p0 = shape[idx];
        var p1 = shape[(idx + 1) % shape.length];

        if (p0 != p1 && Point.distance(p0, p1) < 8) {
          var matchingShapes = shapes.filter(function(s){ return s.contains(p1); });

          for (matchingShape in matchingShapes) if (matchingShape != shape) {
            matchingShape[matchingShape.indexOf(p1)] = p0;
            shapesToClean.push(matchingShape);
          }

          p0.addEq(p1);
          p0.scaleEq(0.5);

          shape.remove(p1);
        }

        idx++;
      }
    }

    // Removing duplicate vertices
    for (shape in shapesToClean) {
      for (i in 0...shape.length) {
        var p = shape[i];
        var dupIdx;
        while ((dupIdx = shape.indexOf(p, i + 1)) != -1) {
          shape.splice(dupIdx, 1);
        }
      }
    }
  }
}
