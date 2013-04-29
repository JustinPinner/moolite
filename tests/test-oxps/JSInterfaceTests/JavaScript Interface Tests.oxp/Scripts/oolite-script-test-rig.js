/*

oolite-script-test-rig.js

Driver for JavaScript tests.
 

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


this.name			= "oolite-script-test-rig";
this.author			= "Jens Ayton";
this.copyright		= "© 2010-2013 the Oolite team.";
this.description	= "Driver for JavaScript unit tests.";
this.version		= "1.77";


(function ()
{
"use strict";

// API for test implementation scripts.

// $registerTest(): register a test to run while docked.
this.$registerTest = function registerTest(name, test)
{
	tests.push({ name: name, test: test });
}


// $registerPostLaunchTest(): register a test to run in space.
this.$registerPostLaunchTest = function registerPostLaunchTest(name, test)
{
	postLaunchTests.push({ name: name, test: test });
}


// $require(): assert that predicate is a truthy value.
this.$require = function require(description, predicate)
{
	if (!predicate)  throw "Expected invariant " + description;
}


// $require.defined(): require that value not undefined or null.
this.$require.defined = function requireDefined(name, value)
{
	if (value === undefined || value === null)  throw "Expected " + name + " to have a value.";
}


// $require.instance(): require that value is an instance of proto.
this.$require.instance = function requireInstance(name, value, proto)
{
	if (proto === undefined)  throw "Usage error: $require.instance proto parameter is undefined.";
	if (!(value instanceof proto))  throw "Expected " + name + " to be an instance of " + proto.name + ".";
}
	
// $require.value(): require an exact == match to a primitive value.
this.$require.value = function requireValue(name, actual, expected)
{
	if (actual != expected)  throw "Expected " + name + " to be " + expected + ", got " + actual + ".";
}
	
// $require.near(): like value, but allows an error range. Intended for floating-point tests.
this.$require.near = function requireNear(name, actual, expected, epsilon)
{
	if (epsilon === undefined)  epsilon = 1e-6;
	if (Math.abs(actual - expected) > epsilon)  throw "Expected " + name + " to be within " + epsilon + " of " + expected + ", got " + actual;
}
	
// $require.property(): require that a property has a specific (exact) value.
this.$require.property = function requireProperty(targetName, target, propName, expected)
{
	var actual = target[propName];
	this.value(targetName + "." + propName, actual, expected);
}
	
// $require.propertyNear(): require that a property has a specific value, within epsilon.
this.$require.propertyNear = function requirePropertyNear(targetName, target, propName, expected, epsilon)
{
	var actual = target[propName];
	this.near(targetName + "." + propName, actual, expected, epsilon);
}
	
// $require.vector(): require that a Vector3D matches an array of three numbers, within epsilon.
this.$require.vector = function requireVector(name, actual, expected, epsilon)
{
	this.instance(name, actual, Vector3D);
	this.propertyNear(name, actual, "x", expected[0], epsilon);
	this.propertyNear(name, actual, "y", expected[1], epsilon);
	this.propertyNear(name, actual, "z", expected[2], epsilon);
}
	
// $require.quaternion(): require that a Quaternion matches an array of four numbers, within epsilon.
this.$require.quaternion = function requireQuaternion(name, actual, expected, epsilon)
{
	this.instance(name, actual, Quaternion);
	this.propertyNear(name, actual, "w", expected[0], epsilon);
	this.propertyNear(name, actual, "x", expected[1], epsilon);
	this.propertyNear(name, actual, "y", expected[2], epsilon);
	this.propertyNear(name, actual, "z", expected[3], epsilon);
}


/*	
	$deferResult()
	Inform the test rig that results will be returned later. $deferResult() returns an object
	with two public methods, reportSuccess() and reportFailure(message). When the results
	are ready, one of these must be called.
*/
this.$deferResult = function deferResult()
{
	if (!currentTest)
	{
		throw "Usage error: $deferResult() must be called during a test.";
	}
	
	deferredCount++;
	var name = currentTest;
	currentDeferred = true;
	
	var reported = false;
	
	return {
		reportSuccess: function reportSuccess()
		{
			if (!reported)
			{
				printResult(name, null);
				if (--deferredCount == 0)  completeTests();
				reported = true;
			}
		},
		reportFailure: function reportFailure(message)
		{
			if (!reported)
			{
				printResult(name, message);
				failedCount++;
				if (--deferredCount == 0)  completeTests();
				reported = true;
			}
		}
	};
}




// End of API; begin implementation




var tests = [], postLaunchTests = [];
var deferredCount;
var currentDeferred;
var currentTest;
var running;
var failedCount;
var testCount;


function resetState()
{
	running = false;
	failedCount = 0;
	deferredCount = 0;
	currentTest = null;
	testCount = 0;
	currentDeferred = false;
}
resetState();


this.startUp = function startUp()
{
	if (global.consoleMessage === undefined)
	{
		this.consoleMessage = function(colorCode, message)  { log(message); }
	}
}


function printResult(name, error)
{
	if (error)
	{
		consoleMessage("error", "FAIL: " + name + " -- " + error, 0, 4);
	}
	else
	{
		consoleMessage("command-result", "Pass: " + name);	
	}
}


function runTest(testInfo)
{
	var success = true;
	try
	{
		currentTest = testInfo.name;
		
		testInfo.test();
		if (!currentDeferred)  printResult(testInfo.name, null);
	}
	catch (e)
	{
		printResult(testInfo.name, e);
		success = false;
	}
	
	currentTest = null;
	currentDeferred = false;
	
	return success;
}


function completeTests()
{
	if (failedCount > 0)
	{
		consoleMessage("error", "***** " + failedCount + " of " + testCount + " tests FAILED", 0, 5);
	}
	else
	{
		consoleMessage("command-result", "All " + testCount + " tests passed.");
	}
	
	resetState();
}


function runTestSeries(series, showProfile)
{
	function doRun()
	{
		try
		{
			var i, count = series.length;
			testCount += count;
			
			for (i = 0; i < count; i++)
			{
				if (!runTest(series[i]))  failedCount++;
			}
		}
		catch (e)
		{
			consoleMessage("error", "EXCEPTION IN TEST RIG: " + e, 0, 21);
			throw e;
		}
	}
	if (console !== undefined && console.profile !== undefined)
	{
		var prof = console.profile(doRun, this);
		if (showProfile)  log(prof);
	}
	else
	{
		doRun();
	}
}


function reportSuccess(name)
{
	printResult(name, null);
	if (--deferredCount == 0)  completeTests();
}


function reportFailure(name, error)
{
	printResult(name, error);
	if (--deferredCount == 0)  completeTests();
}


global.ooRunTests = function ooRunTests(showProfile)
{
	if (!player.ship.docked)
	{
		consoleMessage("command-error", "ooRunTests() must be called while docked.");
		return;
	}
	
	if (running)
	{
		consoleMessage("command-error", "Deferred tests are currently running.");
		return;
	}
	
	testCount = 0;
	
	function runFinished()
	{
		if (deferredCount == 0)
		{
			completeTests();
		}
		else
		{
			consoleMessage("command-result", "Waiting for " + deferredCount + " asynchronous tests to complete.");
		}
	}
	
	if (showProfile === undefined)  showProfile = false;
	log("Running docked tests...");
	runTestSeries(tests, showProfile);
	
	if (postLaunchTests.length != 0)
	{
		var station = player.ship.dockedStation;
		
		if (!this.shipLaunchedFromStation)
		{
			this.shipLaunchedFromStation = function ()
			{
				log("Running post-launch tests...");
				runTestSeries(postLaunchTests, showProfile);
				
				station.dockPlayer();
				delete this.shipLaunchedFromStation;
				
				runFinished();
			}
		}
		
		player.ship.launch();
	}
	else
	{
		runFinished();
	}
}

}).call(this);

