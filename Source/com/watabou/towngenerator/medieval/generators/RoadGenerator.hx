package com.watabou.towngenerator.medieval.generators;

import openfl.geom.Point;
import openfl.errors.Error;

import com.watabou.utils.Random;
import com.watabou.geom.Segment;

import com.watabou.towngenerator.medieval.Model;
import com.watabou.towngenerator.medieval.Topology;

import com.watabou.towngenerator.model.edgefeatures.RoadFeature;
import com.watabou.towngenerator.model.edgefeatures.RoadFeature.RoadType;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

class RoadGenerator implements Generator {
  public function new() {}

  public function generate(model: Model): Void {
    var topology = new Topology(model);
    var outerPerimeter = Model.findCircumference(model.patches);
    var innerPerimeter = Model.findCircumference(model.inner);
    var numberOfRoads = 2 + Math.round(Random.float());

    var entrances = innerPerimeter.filter(function(point) {
      if (model.citadel != null && model.citadel.shape.contains(point)) return false;

      var patchCount = model.patches.count(function(patch: Patch) { return patch.shape.contains(point); });
      var innerPatchCount = model.inner.count(function(patch: Patch) { return patch.shape.contains(point); });

      return innerPatchCount > 1 && (patchCount - innerPatchCount) > 1;
    }).shuffle().slice(0, numberOfRoads);

    if (entrances.length == 0) throw new Error("No valid city entrances");

    model.gates = entrances;

    var excludePoints = innerPerimeter.copy();
    if (model.citadel != null) excludePoints = excludePoints.concat(model.citadel.shape);

    for (entrance in entrances) {
      var start = outerPerimeter.min(function(p) { return Point.distance(p, entrance); });

      var end = model.plaza != null ?
        model.plaza.shape.min(function(p) { return Point.distance(p, entrance); }) :
        model.center;

      // If we just allow all entrances before the loop, some paths can trace back through the city
      // and out another entrance
      var allowEntrance = excludePoints.without(entrance);

      var road = topology.buildPath(start, entrance, allowEntrance);
      if (road == null) throw new Error("Unable to build road");
      addRoad(model, road, Road);
      model.roads.push(road);

      var street = topology.buildPath(entrance, end, allowEntrance);
      if (street == null) throw new Error("Unable to build street");
      addRoad(model, street, Avenue);
      model.streets.push(street);
    }

    for (patch in model.inner) {
      for (edge in patch.edges) {
        var isPerimeter = innerPerimeter.findEdge(edge.start, edge.end) != -1 || innerPerimeter.findEdge(edge.end, edge.start) != -1;
        if (!isPerimeter && edge.features.length == 0) {
          model.addEdgeFeature(edge.start, edge.end, new RoadFeature({start: 0, end: 0}, Street));
        }
      }
    }

    tidyUpRoads(model);

    for (a in model.arteries)
      smoothStreet(a);
  }

  private function smoothStreet(street: Street) {
    var smoothed = street.smoothVertexEq( 3 );
    for (i in 1...street.length-1)
      street[i].set(smoothed[i]);
  }

  private function addRoad(model: Model, points: Array<Point>, type: RoadType) {
    for (segment in points.eachCons(2)) {
      var edge = model.findOrAddEdge(segment[0], segment[1]);
      if (edge.features.length == 0) {
        model.addEdgeFeature(segment[0], segment[1], new RoadFeature({start: 0, end: 0}, type));
      }
    }
  }

  private function tidyUpRoads(model: Model) {
    var segments = new Array<Segment>();
    function cut2segments(street: Street) {
      var v0:Point = null;
      var v1:Point = street[0];
      for (i in 1...street.length) {
        v0 = v1;
        v1 = street[i];

        // Removing segments which go along the plaza
        if (model.plaza != null && model.plaza.shape.contains( v0 ) && model.plaza.shape.contains( v1 ))
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

    for (street in model.streets)
      cut2segments(street);

    for (road in model.roads)
      cut2segments(road);

    while (segments.length > 0) {
      var seg = segments.pop();

      var attached = false;
      for (a in model.arteries)
        if (a[0] == seg.end) {
          a.unshift(seg.start);
          attached = true;
          break;
        } else if (a.last() == seg.start) {
          a.push(seg.end);
          attached = true;
          break;
        }

      if (!attached)
        model.arteries.push([seg.start, seg.end]);
    }
  }
}
