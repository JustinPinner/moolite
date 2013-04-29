/*

oolite-test-frameCallbacks.js
 

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


this.name			= "oolite-test-frameCallbacks";
this.author			= "Jens Ayton";
this.copyright		= "© 2011-2013 the Oolite team.";
this.description	= "Test cases for addFrameCallback()/removeFrameCallback.";
this.version		= "1.77";


this.startUp = function ()
{
	"use strict";
	
	var testRig = worldScripts["oolite-script-test-rig"];
	var require = testRig.$require;
	
	// Optional logging, best used in combination with DEBUG_FCB_VERBOSE_LOGGING in OOJSFrameCallbacks.m.
	if (0)  var fcbLog = function(msg) { log("script.frameCallback.test-script", msg); }
	else  var fcbLog = function() {}
	
	testRig.$registerTest("Frame callbacks", function ()
	{
		const testTime = 2.5;
		
		var sum = 0;
		fcbLog("Will add Frame Callbacks test FCB.");
		var fcb = addFrameCallback(function (delta)
		{
			sum += delta;
		});
		fcbLog("Did add Frame Callbacks test FCB with tracking ID " + fcb + ".");
		
		require(isValidFrameCallback(fcb), "addFrameCallback() should return a valid tracking ID.");
		
		var deferredRef = testRig.$deferResult(testTime * 2);
		
		var testTimer = new Timer(this, function ()
		{
			/*
				Use a second, zero-delay one-shot timer for final report,
				because frame callbacks fire after timers. (If we did the
				test in the first timer, we’d expect sum to be one frame
				less than testTime.)
			*/
			
			testTimer = new Timer(this, function ()
			{
				if (!isValidFrameCallback(fcb))
				{
					deferredRef.reportFailure("Expected fcb to be valid before removal.");
					return;
				}
				
				fcbLog("Will remove Frame Callbacks test FCB with tracking ID " + fcb + ".");
				removeFrameCallback(fcb);
				fcbLog("Did remove Frame Callbacks test FCB.");
				
				if (isValidFrameCallback(fcb))
				{
					deferredRef.reportFailure("Expected fcb to be invalid after removal.");
					return;
				}
				
				/*
					Check that sum is within a reasonable slop of testTime.
					0.2 should work at framerates above 5.
				*/
				if (Math.abs(sum - testTime) < 0.2)
				{
					deferredRef.reportSuccess();
				}
				else
				{
					deferredRef.reportFailure("Expected sum of frame deltas over " + testTime + " seconds to be near " + testTime + ", got " + sum + ".");
				}
			}, 0);
		}, testTime);
	});
	
	testRig.$registerTest("Nested frame callbacks", function ()
	{
		var fcb1hitCount = 0;
		var fcb2hitCount = 0;
		var fcb2;
		
		fcbLog("Will add Nested Frame Callbacks test outer FCB.");
		var fcb1 = addFrameCallback(function (delta)
		{
			fcbLog("Executing Nested Frame Callbacks test outer FCB, hit #" + (fcb1hitCount + 1) + " of expected 2.");
			
			if (fcb1hitCount == 0)
			{
				/*
					The outer FCB will be called twice, because (regardless
					of order of execution) the inner one will be added the
					first time, but first fire on the second frame, when it
					will cause both FCBs to be removed after the FCB
					execution phase.
				*/
				
				fcbLog("Will add Nested Frame Callbacks test inner FCB (should be deferred).");
				fcb2 = addFrameCallback(function (delta)
				{
					fcbLog("Executing Nested Frame Callbacks test inner FCB, hit #" + (fcb2hitCount + 1) + " of expected 1.");
					
					fcbLog("Will remove Nested Frame Callbacks test outer FCB with tracking ID " + fcb1 + " (should be deferred)");
					removeFrameCallback(fcb1);
					fcbLog("Did remove Nested Frame Callbacks test outer FCB.");
					
					fcbLog("Will remove Nested Frame Callbacks test inner FCB with tracking ID " + fcb2 + " (should be deferred)");
					removeFrameCallback(fcb2);
					fcbLog("Did remove Nested Frame Callbacks test inner FCB.");
					fcb2hitCount++;
					
					fcbLog("End of Nested Frame Callbacks test inner FCB.");
				});
				fcbLog("Did add Nested Frame Callbacks test inner FCB with tracking ID " + fcb2 + ".");
			}
			fcb1hitCount++;
			
			fcbLog("End of Nested Frame Callbacks test outer FCB.");
		});
		fcbLog("Did add Nested Frame Callbacks test outer FCB with tracking ID " + fcb1 + ".");
		
		require(isValidFrameCallback(fcb1), "addFrameCallback() should return a valid tracking ID.");
		
		var deferredRef = testRig.$deferResult(2);
		
		var testTimer = new Timer(this, function ()
		{
			if (isValidFrameCallback(fcb1))  deferredRef.reportFailure("Frame callback 1 is still valid.");
			else if (isValidFrameCallback(fcb2))  deferredRef.reportFailure("Frame callback 2 is still valid.");
			if (fcb1hitCount != 2)  deferredRef.reportFailure("Frame callback 1 hit count should be 2, got " + fcb1hitCount + ".");
			if (fcb2hitCount != 1)  deferredRef.reportFailure("Frame callback 2 hit count should be 1, got " + fcb2hitCount + ".");
			deferredRef.reportSuccess();
		}, 1);
	});
}
