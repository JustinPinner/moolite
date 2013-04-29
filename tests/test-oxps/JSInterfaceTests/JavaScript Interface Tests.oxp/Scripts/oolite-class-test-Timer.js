/*

oolite-class-test-Timer.js
 

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


this.name			= "oolite-class-test-Timer";
this.author			= "Jens Ayton";
this.copyright		= "© 2010-2013 the Oolite team.";
this.description	= "Test cases for Timer.";
this.version		= "1.77";


this.startUp = function ()
{
	"use strict";
	
	var testRig = worldScripts["oolite-script-test-rig"];
	var require = testRig.$require;
	var testTimer, zeroTimer, reportTimer;
	
	testRig.$registerTest("Timer constructor", function ()
	{
		var deferredRef = testRig.$deferResult(2);
		
		var hitCount = 0;
		testTimer = new Timer(this, function testTimerCallback()
		{
			if (++hitCount == 3)
			{
				testTimer.stop();
				
				/*	Defer report to ensure that the timer actually stopped
					as intended. This was not the case prior to r3942 (but
					I think it did work at some time before that.)
					-- Ahruman 2011-01-01
				*/
				this.reportTimer = new Timer(this, function reportTimerCallback()
				{
					if (testTimer.isRunning)
					{
						deferredRef.reportFailure("Timer still running when it should have stopped.");
					}
					else if (hitCount != 3)
					{
						deferredRef.reportFailure("Timer nominally stopped but has run again -- hit count is " + hitCount);
					}
					else
					{
						deferredRef.reportSuccess();
					}
				}, 0.5);
			}
		}, 0.25, 0.3);
	});
	
	testRig.$registerTest("Zero-delay timer", function ()
	{
		var deferredRef = testRig.$deferResult(0.1);
		
		zeroTimer = new Timer(this, function zeroTimerCallback()
		{
			deferredRef.reportSuccess();
		}, 0.0);
	});
	
	testRig.$registerTest("Timer properties", function ()
	{
		require.property("testTimer", testTimer, "isRunning", true);
		require.propertyNear("testTimer", testTimer, "interval", 0.3);
		
		var nextTime = testTimer.nextTime;
		require.near("nextTime", nextTime, clock.absoluteSeconds + 0.25);
	});
	
	testRig.$registerTest("Timer.stop", function ()
	{
		testTimer.stop();
		require.property("testTimer", testTimer, "isRunning", false);
	});
	
	testRig.$registerTest("Timer.start", function ()
	{
		testTimer.start();
		require.property("testTimer", testTimer, "isRunning", true);
	});
}
