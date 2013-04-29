/*

oolite-png-test-suite.js

Test suite for PNG loading.


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


this.name			= "oolite-png-test-suite";
this.version		= "1.0";
this.author			= "Jens Ayton";
this.copyright		= "© 2010-2013 the Oolite team. Test images © Willem van Schaik.";


this.startUp = function()
{
	delete this.startUp;
	try
	{
		var console = debugConsole;
	}
	catch (e)
	{
		log("pngTest.error.consoleRequired", "The PNG test suite requires the debug console to be active.");
		return;
	}
	
	
	const pngTestCount = 153;
	
	
	this.runPngTestSuite = function ()
	{
		if (!player.ship.docked)
		{
			debugConsole.consoleMessage("command-error", "You must be docked to run the PNG test suite.");
			return;
		}
		
		// Show instruction/confirmation screen.
		var substitutions = { png_count: pngTestCount };
		var introText = expandMissionText("oolite_png_test_confirmation", substitutions);
		
		if (!mission.runScreen({ titleKey: "oolite_png_test_title", message: introText, choicesKey: "oolite_png_test_confirmation_choices" }, this.startTest, this))
		{
			log("pngTest.error.missionScreenFailed", "The PNG test suite failed to run a mission screen.");
			return;
		}
	}
	
	// Run on startup.
	this.missionScreenOpportunity = function ()
	{
		delete this.missionScreenOpportunity;
		this.runPngTestSuite();
	}
	
	// User-callable initiation function, if debug console is installed.
	var scriptName = this.name;
	if (debugConsole.script !== undefined)
	{
		debugConsole.script.runPngTestSuite = function ()
		{
			worldScripts[scriptName].runPngTestSuite();
		}
	}
	
	
	// Confirmation screen result callback.
	this.startTest = function (resonse)
	{
		if (resonse != "A_CONTINUE")  return;
		
		this.nextTestIndex = 1;
		this.originalHUD = player.ship.hud;
		
		this.shipWillLaunchFromStation = function () { log("pngTest.cancelled", "PNG test suite cancelled by exiting station."); this.performCleanUp(); }
		
		var startString = "Starting PNG test suite " + this.version +
		                  " under Oolite " + oolite.versionString +
						  " and " + debugConsole.platformDescription + ".";
		
		log("pngTest.start", startString);
		
		player.ship.hud = "oolite_material_test_suite_blank_hud.plist";
		this.runNextTest();
	}
	
	
	this.performCleanUp = function ()
	{
		player.ship.hud = this.originalHUD;
		
		delete this.passID;
		delete this.maxPassID;
		delete this.nextTestIndex;
		delete this.shipWillLaunchFromStation;
		delete this.originalHUD;
	}
	
	
	this.runNextTest = function ()
	{
		var testIndex = this.nextTestIndex++;
		
		if (testIndex > pngTestCount)
		{
			// We're done.
			this.performCleanUp();
			log("pngTest.complete", "PNG test suite complete.");
			return;
		}
		
		// Create a dummy ship to extract its script_info.
		var modelName = "oolite_png_test_suite_" + testIndex;
		var ship = system.addShips(modelName, 1, system.sun.position, 10000)[0];
		var testDesc = ship.scriptInfo["oolite_png_test_suite_label"];
		ship.remove();
		
		// Actually run the test.
		log("pngTest.runTest", "Running test " + testIndex + ": " + testDesc);
		
		var config =
		{
			model: modelName,
			title: "",
			message: "\n\n" + testIndex + ": " + testDesc,
			background: "oolite_material_test_suite_backdrop.png"
		};
		if (!mission.runScreen(config, this.runNextTest, this))
		{
			log("pngTest.error.missionScreenFailed", "The PNG test suite failed to run a mission screen.");
			this.performCleanUp();
			return;
		}
	}
	
	
	log("pngTest.loaded", "PNG test suite is installed.");
};
