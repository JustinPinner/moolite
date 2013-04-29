/*

oolite-test-expandDescription.js
 

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


this.name			= "oolite-test-expandDescription";
this.author			= "Jens Ayton";
this.copyright		= "© 2011-2013 the Oolite team.";
this.description	= "Test cases for expandDescription().";
this.version		= "1.77";


this.startUp = function ()
{
	"use strict";
	
	var testRig = worldScripts["oolite-script-test-rig"];
	var require = testRig.$require;
	
	testRig.$registerTest("expandDescription passthrough", function ()
	{
		var string = "test string";
		var expanded = expandDescription(string);
		
		require.value("expanded", expanded, string);
	});
	
	testRig.$registerTest("expandDescription descriptions.plist", function ()
	{
		var key = "oolite-test-expandDescription-descriptions-plist";
		var expanded = expandDescription("[" + key + "]");
		
		require.value("expanded", expanded, "foo");
	});
	
	testRig.$registerTest("expandDescription nonexistent", function ()
	{
		var key = "oolite-test-expandDescription-descriptions-plist-nonexistent (JavaScript warning expected)";
		var expanded = expandDescription("[" + key + "]");
		
		require.value("expanded", expanded, "[" + key + "]");
	});
	
	testRig.$registerTest("expandDescription parameterized substitution", function ()
	{
		var substitutions = {};
		var key = "oolite-test-expandDescription-parameterized-substitution";
		var expected = "bar";
		substitutions[key] = expected;
		var expanded = expandDescription("[" + key + "]", substitutions);
		
		require.value("expanded", expanded, expected);
	});
	
	testRig.$registerTest("expandDescription %H", function ()
	{
		var expanded = expandDescription("%H");
		
		require.value("expanded", expanded, system.name);
	});
	
	testRig.$registerTest("expandDescription %R", function ()
	{
		var expanded = expandDescription("%R");
		
		// %R produces a pseudo-random name, so we make do with ensuring it fits the expected pattern.
		require("expanded.length >= 2", expanded.length >= 2);
		require("expanded.length <= 8", expanded.length <= 8);
		require('expanded.indexof("%") == -1', expanded.indexOf("%") == -1);
	});
	
	testRig.$registerTest("expandDescription %N", function ()
	{
		var expanded = expandDescription("%N");
		
		// %N produces a pseudo-random name, so we make do with ensuring it fits the expected pattern.
		require("expanded.length >= 2", expanded.length >= 2);
		require("expanded.length <= 10", expanded.length <= 10);
		require('expanded.indexof("%") == -1', expanded.indexOf("%") == -1);
	});
	
	testRig.$registerTest("expandDescription %J", function ()
	{
		var systemNumber = Math.floor(Math.random() * 256);
		var expanded = expandDescription("%J" + (systemNumber < 10 ? "00" : systemNumber < 100 ? "0" : "") + systemNumber);
		
		require.value("expanded", expanded, System.systemNameForID(systemNumber));
	});
	
	testRig.$registerTest("expandDescription [commander_name]", function ()
	{
		var expanded = expandDescription("[commander_name]");
		
		require.value("expanded", expanded, player.name);
	});
	
	testRig.$registerTest("expandDescription [commander_shipname]", function ()
	{
		var expanded = expandDescription("[commander_shipname]");
		
		require.value("expanded", expanded, player.ship.name);
	});
	
	testRig.$registerTest("expandDescription [commander_shipdisplayname]", function ()
	{
		var expanded = expandDescription("[commander_shipdisplayname]");
		
		require.value("expanded", expanded, player.ship.displayName);
	});
	
	testRig.$registerTest("expandDescription [commander_rank]", function ()
	{
		var expanded = expandDescription("[commander_rank]");
		
		require.value("expanded", expanded, player.rank);
	});
	
	testRig.$registerTest("expandDescription [commander_legal_status]", function ()
	{
		var expanded = expandDescription("[commander_legal_status]");
		
		require.value("expanded", expanded, player.legalStatus);
	});
	
	testRig.$registerTest("expandDescription [commander_bounty]", function ()
	{
		var expanded = expandDescription("[commander_bounty]");
		
		require.value("expanded", expanded, player.bounty);
	});
	
	testRig.$registerTest("expandDescription [credits_number]", function ()
	{
		var expanded = expandDescription("[credits_number]");
		
		require.value("expanded", expanded, formatCredits(player.credits, true, false));
	});
}
