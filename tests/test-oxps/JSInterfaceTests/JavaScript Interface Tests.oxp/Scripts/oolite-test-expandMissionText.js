/*

oolite-test-expandMissionText.js
 

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


this.name			= "oolite-test-expandMissionText";
this.author			= "Jens Ayton";
this.copyright		= "© 2011-2013 the Oolite team.";
this.description	= "Test cases for expandMissionText().";
this.version		= "1.77";


this.startUp = function ()
{
	"use strict";
	
	var testRig = worldScripts["oolite-script-test-rig"];
	var require = testRig.$require;
	
	testRig.$registerTest("expandMissionText basic", function ()
	{
		var key = "oolite-test-expandMissionText-basic";
		var expanded = expandMissionText(key);
		
		require.value("expanded", expanded, "foo");
	});
	
	testRig.$registerTest("expandMissionText substitution", function ()
	{
		var key = "oolite-test-expandMissionText-substitution";
		var expanded = expandMissionText(key);
		
		require.value("expanded", expanded, "foobar");
	});
	
	testRig.$registerTest("expandMissionText parameterized substitution", function ()
	{
		var substitutions = {};
		var key = "oolite-test-expandDescription-substitution-parameter";
		var expected = "baz";
		substitutions[key] = expected;
		var expanded = expandMissionText("oolite-test-expandMissionText-parameterized-substitution", substitutions);
		
		require.value("expanded", expanded, expected);
	});
	
	testRig.$registerTest("expandMissionText parameterized substitution of number", function ()
	{
		var substitutions = {};
		var key = "oolite-test-expandDescription-substitution-parameter";
		var expected = 42;
		substitutions[key] = expected;
		var expanded = expandMissionText("oolite-test-expandMissionText-parameterized-substitution", substitutions);
		
		require.value("expanded", expanded, expected);
	});
}
