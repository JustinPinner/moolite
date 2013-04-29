/*

oolite-class-test-Quaternion.js
 

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


this.name			= "oolite-class-test-Quaternion";
this.author			= "Jens Ayton";
this.copyright		= "© 2010-2013 the Oolite team.";
this.description	= "Test cases for Quaternion.";
this.version		= "1.77";


this.startUp = function ()
{
	"use strict";
	
	var testRig = worldScripts["oolite-script-test-rig"];
	var require = testRig.$require;
	
	testRig.$registerTest("Quaternion constructor", function ()
	{
		var basic = new Quaternion(1, 2, 3, 4);
		require.instance("basic", basic, Quaternion);
		
		var noNew = Quaternion(1, 2, 3, 4);
		require.instance("noNew", noNew, Quaternion);
		
		var fromArray = Quaternion([1, 2, 3, 4]);
		require.instance("fromArray", fromArray, Quaternion);
	});
	
	testRig.$registerTest("Quaternion properties", function ()
	{
		var q = new Quaternion(1, 2, 3, 4);
		
		require.quaternion("q", q, [1, 2, 3, 4]);
		
		q.w = 5;
		q.x = 6;
		q.y = 7;
		q.z = 8;
		
		require.quaternion("q", q, [5, 6, 7, 8]);
	});
	
	testRig.$registerTest("Quaternion.dot", function ()
	{
		var q = new Quaternion(Math.random(), Math.random(), Math.random(), Math.random());
		var p = new Quaternion(Math.random(), Math.random(), Math.random(), Math.random());
		var dotProduct = q.dot(p);
		
		require.near("dotProduct", dotProduct, q.w * p.w + q.x * p.x + q.y * p.y + q.z * p.z);
	});
	
	function quatMult(p, q)
	{
		var w = p.w * q.w - p.x * q.x - p.y * q.y - p.z * q.z;
		var x = p.w * q.x + p.x * q.w + p.y * q.z - p.z * q.y;
		var y = p.w * q.y + p.y * q.w + p.z * q.x - p.x * q.z;
		var z = p.w * q.z + p.z * q.w + p.x * q.y - p.y * q.x;
		return [w, x, y, z];
	}
	testRig.$registerTest("Quaternion.multiply", function ()
	{
		var q = new Quaternion(Math.random(), Math.random(), Math.random(), Math.random());
		var p = new Quaternion(Math.random(), Math.random(), Math.random(), Math.random());
		var product = p.multiply(q);
		
		require.quaternion("product", product, quatMult(p, q));
	});
	
	testRig.$registerTest("Quaternion.normalize", function ()
	{
		var q = new Quaternion(Math.random(), Math.random(), Math.random(), Math.random());
		var normalized = q.normalize();
		var weight = Math.sqrt(q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z);
		
		require.quaternion("normalized", normalized, [q.w / weight, q.x / weight, q.y / weight, q.z / weight]);
	});
	
	testRig.$registerTest("Quaternion.rotate", function ()
	{
		var angle = (Math.random() - 0.5) * Math.PI * 2;
		var q = Quaternion.random();
		var rotated = q.rotate(Vector3D.randomDirection(), angle);
		var rotAngle = Math.acos(rotated.dot(q)) * 2;
		
		require.near("rotAngle", rotAngle, Math.abs(angle), 1e-4);
	});
	
	testRig.$registerTest("Quaternion.rotateX", function ()
	{
		var angle = (Math.random() - 0.5) * Math.PI * 2;
		var q = Quaternion.random();
		var rotated = q.rotateX(angle);
		var rotAngle = Math.acos(rotated.dot(q)) * 2;
		
		require.near("rotAngle", rotAngle, Math.abs(angle), 1e-4);
	});
	
	testRig.$registerTest("Quaternion.rotateY", function ()
	{
		var angle = (Math.random() - 0.5) * Math.PI * 2;
		var q = Quaternion.random();
		var rotated = q.rotateY(angle);
		var rotAngle = Math.acos(rotated.dot(q)) * 2;
		
		require.near("rotAngle", rotAngle, Math.abs(angle), 1e-4);
	});
	
	testRig.$registerTest("Quaternion.rotateZ", function ()
	{
		var angle = (Math.random() - 0.5) * Math.PI * 2;
		var q = Quaternion.random();
		var rotated = q.rotateZ(angle);
		var rotAngle = Math.acos(rotated.dot(q)) * 2;
		
		require.near("rotAngle", rotAngle, Math.abs(angle), 1e-4);
	});
	
	testRig.$registerTest("Quaternion.toArray", function ()
	{
		var q = Quaternion.random();
		require.quaternion("q", q, q.toArray());
	});
	
	testRig.$registerTest("Quaternion.vectorForward", function ()
	{
		var q = Quaternion.random();
		var vectorForward = q.vectorForward();
		var reference = new Vector3D(0, 0, 1).rotateBy(q);
		
		require.vector("vectorForward", vectorForward, reference.toArray());
	});
	
	testRig.$registerTest("Quaternion.vectorRight", function ()
	{
		var q = Quaternion.random();
		var vectorRight = q.vectorRight();
		var reference = new Vector3D(1, 0, 0).rotateBy(q);
		
		require.vector("vectorRight", vectorRight, reference.toArray());
	});
	
	testRig.$registerTest("Quaternion.vectorUp", function ()
	{
		var q = Quaternion.random();
		var vectorUp = q.vectorUp();
		var reference = new Vector3D(0, 1, 0).rotateBy(q);
		
		require.vector("vectorUp", vectorUp, reference.toArray());
	});
	
	testRig.$registerTest("Quaternion.random", function ()
	{
		// Doesn’t test distribution, just that results are normalized quaternions.
		var i;
		for (i = 0; i < 20; i++)
		{
			var random = Quaternion.random();
			require.instance("random", random, Quaternion);
			var normalized = random.normalize();
			require.near("normalized", normalized, random.toArray());
		}
	});
	
	testRig.$registerTest("Quaternion.toString", function ()
	{
		var q = new Quaternion(1.5, 14, 0, -3);
		var string = q.toString();
		
		require.value("string", string, "(1.5 + 14i + 0j - 3k)");
	});
	
	testRig.$registerTest("Quaternion.toSource", function ()
	{
		var q = new Quaternion(1.5, 14, 0, -3);
		var source = q.toSource();
		
		require.value("source", source, "Quaternion(1.5, 14, 0, -3)");
	});
}
