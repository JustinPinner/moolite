/*

oolite-class-test-Vector3D.js
 

Oolite
Copyright © 2004-2013 Giles C Williams and contributors

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA.

*/


this.name			= "oolite-class-test-Vector3D";
this.author			= "Jens Ayton";
this.copyright		= "© 2010-2013 the Oolite team.";
this.description	= "Test cases for Vector3D.";
this.version		= "1.77";


this.startUp = function ()
{
	"use strict";
	
	var testRig = worldScripts["oolite-script-test-rig"];
	var require = testRig.$require;
	
	function degToRad(value)
	{
		return Math.PI * value / 180;
	}
	
	testRig.$registerTest("Vector3D constructor", function ()
	{
		var basic = new Vector3D(1, 2, 3);
		require.instance("basic", basic, Vector3D);
		
		var noNew = Vector3D(1, 2, 3);
		require.instance("noNew", noNew, Vector3D);
		
		var fromArray = Vector3D([1, 2, 3]);
		require.instance("fromArray", fromArray, Vector3D);
	});
	
	testRig.$registerTest("Vector3D properties", function ()
	{
		var v = new Vector3D(1, 2, 3);
		
		require.vector("v", v, [1, 2, 3]);
		
		v.x = 4;
		v.y = 5;
		v.z = 6;
		
		require.vector("v", v, [4, 5, 6]);
	});
	
	testRig.$registerTest("Vector3D.add", function ()
	{
		var v = new Vector3D(1, 2, 3);
		var u = new Vector3D(4, 5, 6);
		
		var sum = v.add(u);
		require.vector("sum", sum, [5, 7, 9]);
		
		var sum2 = u.add(v);
		require.vector("sum2", sum2, [5, 7, 9]);
		
		var sumCastFromArray = v.add([1, 1, 1]);
		require.vector("sumCastFromArray", sumCastFromArray, [2, 3, 4]);
	});
	
	testRig.$registerTest("Vector3D.angleTo", function ()
	{
		var v = new Vector3D(0, 1, 0);
		
		var ninetyDegrees = new Vector3D(1, 0, 0);
		require.near("ninetyDegrees", ninetyDegrees.angleTo(v), degToRad(90), 1e-6);
		
		var fortyfiveDegrees = new Vector3D(0, 100, 100);
		require.near("fortyfiveDegrees", fortyfiveDegrees.angleTo(v), degToRad(45), 1e-6);
		
		var opposite = new Vector3D(0, 0, 0).subtract(v).angleTo(v);
		require.near("opposite", opposite, Math.PI, 1e-6);
	});
	
	testRig.$registerTest("Vector3D.cross", function ()
	{
		var v = new Vector3D(1, 0, 0);
		var u = new Vector3D(0, 1, 0);
		
		var cross = v.cross(u);
		require.vector("cross", cross, [0, 0, 1]);
	});
	
	testRig.$registerTest("Vector3D.direction", function ()
	{
		var direction1 = new Vector3D(100, 0, 0).direction();
		require.vector("direction1", direction1, [1, 0, 0]);
		
		var direction2 = new Vector3D(13, -59, 62).direction();
		require.vector("direction2", direction2, [0.15017115046799, -0.681545990585492, 0.716200871462721]);
	});
	
	testRig.$registerTest("Vector3D.distanceTo", function ()
	{
		var v = new Vector3D(10, 10, 10);
		var u = new Vector3D(30, 20, 10);
		
		var distance = v.distanceTo(u);
		var correct = v.subtract(u).magnitude();	// Correct assuming subtract and magnitude work, tested elsewhere.
		require.near("distance", distance, correct, 1e-6);
	});
	
	testRig.$registerTest("Vector3D.dot", function ()
	{
		var v = new Vector3D(1, 0, 0);
		var u = new Vector3D(0, 0, 1);
		var w = new Vector3D(5, 5, 0);
		
		var dot1 = v.dot(v);
		require.near("dot1", dot1, 1, 1e-6);
		var dot2 = v.dot(u);
		require.near("dot2", dot2, 0, 1e-6);
		var dot3 = v.dot(w);
		require.near("dot3", dot3, Math.cos(degToRad(45)) * Math.sqrt(5 * 5 + 5 * 5), 1e-6);
	});
	
	// TODO: fromCoordinateSystem()
	
	testRig.$registerTest("Vector3D.magnitude", function ()
	{
		var magnitude1 = new Vector3D(0, 0, 0).magnitude();
		require.near("magnitude1", magnitude1, 0, 1e-6);
		
		var magnitude2 = new Vector3D(1, 0, 0).magnitude();
		require.near("magnitude2", magnitude2, 1, 1e-6);
		
		var magnitude3 = new Vector3D(10, 0, 0).magnitude();
		require.near("magnitude3", magnitude3, 10, 1e-6);
		
		var magnitude4 = new Vector3D(3, 4, 0).magnitude();
		require.near("magnitude4", magnitude4, 5, 1e-6);
	});
	
	testRig.$registerTest("Vector3D.multiply", function ()
	{
		var product1 = new Vector3D(1, 1, 0).multiply(5);
		require.vector("product1", product1, [5, 5, 0]);
		
		var product2 = new Vector3D(42, -3, 9).multiply(-3);
		require.vector("product2", product2, [-126, 9, -27]);
	});
	
	// TODO: rotateBy()
	
	testRig.$registerTest("Vector3D.rotationTo", function ()
	{
		var v = new Vector3D(1, 0, 0);
		var u = new Vector3D(0, 1, 0);
		var w = new Vector3D(0, Math.sqrt(0.5), Math.sqrt(0.5));
		
		var diff = v.rotationTo(u);
		require.quaternion("diff", diff, [Math.sqrt(0.5), 0, 0, Math.sqrt(0.5)], 1e-6);
		
		var diff2 = u.rotationTo(v);
		require.quaternion("diff2", diff2, [Math.sqrt(0.5), 0, 0, -Math.sqrt(0.5)], 1e-6);
		
		var diff3 = u.rotationTo(w);
		require.quaternion("diff3", diff3, [0.92388, 0.382683, 0, 0], 1e-6);
		
		var diff4 = v.rotationTo(u, Math.PI * 0.25);
		require.quaternion("diff4", diff4, [0.92388, 0, 0, 0.382683], 1e-6);
		
		var diffCastFromArray = v.rotationTo([0, 0, 1]);
		require.quaternion("diffCastFromArray", diffCastFromArray, [Math.sqrt(0.5), 0, -Math.sqrt(0.5), 0], 1e-6);
	});
	
	
	testRig.$registerTest("Vector3D.subtract", function ()
	{
		var v = new Vector3D(1, 2, 3);
		var u = new Vector3D(4, 5, 6);
		
		var diff = v.subtract(u);
		require.vector("diff", diff, [-3, -3, -3]);
		
		var diff2 = u.subtract(v);
		require.vector("diff2", diff2, [3, 3, 3]);
		
		var diffCastFromArray = v.subtract([1, 1, 1]);
		require.vector("diffCastFromArray", diffCastFromArray, [0, 1, 2]);
	});
	
	testRig.$registerTest("Vector3D.squaredDistanceTo", function ()
	{
		var v = new Vector3D(10, 10, 10);
		var u = new Vector3D(30, 20, 10);
		
		var sqDistance = v.squaredDistanceTo(u);
		var correct = v.subtract(u).squaredMagnitude();	// Correct assuming subtract and squaredMagnitude work, tested elsewhere.
		require.near("sqDistance", sqDistance, correct, 1e-6);
	});
	
	
	testRig.$registerTest("Vector3D.squaredMagnitude", function ()
	{
		var sqMagnitude1 = new Vector3D(0, 0, 0).squaredMagnitude();
		require.near("sqMagnitude1", sqMagnitude1, 0, 1e-6);
		
		var sqMagnitude2 = new Vector3D(1, 0, 0).squaredMagnitude();
		require.near("sqMagnitude2", sqMagnitude2, 1, 1e-6);
		
		var sqMagnitude3 = new Vector3D(10, 0, 0).squaredMagnitude();
		require.near("sqMagnitude3", sqMagnitude3, 100, 1e-6);
		
		var sqMagnitude4 = new Vector3D(3, 4, 0).squaredMagnitude();
		require.near("sqMagnitude4", sqMagnitude4, 25, 1e-6);
	});
	
	testRig.$registerTest("Vector3D.toArray", function ()
	{
		var array = new Vector3D(1, 2, 3).toArray();
		
		require.instance("array", array, Array);
		require.property("array", array, "length", 3);
		require.property("array", array, 0, 1);
		require.property("array", array, 1, 2);
		require.property("array", array, 2, 3);
	});
	
	// TODO: toCoordinateSystem()
	
	testRig.$registerTest("Vector3D.tripleProduct", function ()
	{
		var u = new Vector3D(5, 7, 3);
		var v = new Vector3D(1, 5, -6);
		var w = new Vector3D(2, -1, 4);
		
		var tripleProduct = u.tripleProduct(v, w);
		require.near("tripleProduct", tripleProduct, -75);
	});
	
	testRig.$registerTest("Vector3D.interpolate", function ()
	{
		var u = new Vector3D(-10, 6, 3);
		var v = new Vector3D(-1, 0, 0);
		
		var interp1 = Vector3D.interpolate(u, v, 0);
		require.vector("interp1", interp1, [-10, 6, 3]);
		
		var interp2 = Vector3D.interpolate(u, v, 1);
		require.vector("interp2", interp2, [-1, 0, 0]);
		
		var interp3 = Vector3D.interpolate(u, v, 1/3);
		require.vector("interp3", interp3, [-7, 4, 2]);
		
		var interp4 = Vector3D.interpolate(u, v, 2);
		require.vector("interp4", interp4, [8, -6, -3]);
	});
	
	testRig.$registerTest("Vector3D.random", function ()
	{
		// Doesn’t test distribution, just that results are in valid range.
		var i;
		for (i = 0; i < 20; i++)
		{
			var random = Vector3D.random(3);
			require.instance("random", random, Vector3D);
			require("random.magnitude() <= 3", random.magnitude() <= 3);
		}
	});
	
	testRig.$registerTest("Vector3D.randomDirection", function ()
	{
		// Doesn’t test distribution, just that results are in valid range.
		var i;
		for (i = 0; i < 20; i++)
		{
			var random = Vector3D.randomDirection(3);
			require.instance("random", random, Vector3D);
			require.near("random.magnitude()", random.magnitude(), 3);
		}
	});
	
	testRig.$registerTest("Vector3D.randomDirectionAndLength", function ()
	{
		// Doesn’t test distribution, just that results are in valid range.
		var i;
		for (i = 0; i < 20; i++)
		{
			var random = Vector3D.randomDirectionAndLength(3);
			require.instance("random", random, Vector3D);
			require("random.magnitude() <= 3", random.magnitude() <= 3);
		}
	});
	
	testRig.$registerTest("Vector3D.toString", function ()
	{
		var v = new Vector3D(42, 17, 163);
		var string = v.toString();
		
		require.value("string", string, "(42, 17, 163)");
	});
	
	testRig.$registerTest("Vector3D.toSource", function ()
	{
		var v = new Vector3D(42, 17, 163);
		var source = v.toSource();
		
		require.value("source", source, "Vector3D(42, 17, 163)");
	});
}
