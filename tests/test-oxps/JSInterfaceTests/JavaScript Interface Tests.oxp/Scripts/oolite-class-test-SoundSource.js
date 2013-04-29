/*

oolite-class-test-SoundSource.js
 

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


this.name			= "oolite-class-test-SoundSource";
this.author			= "Jens Ayton";
this.copyright		= "© 2011-2013 the Oolite team.";
this.description	= "Test cases for SoundSource and Sound.";
this.version		= "1.77";


this.startUp = function ()
{
	"use strict";
	
	var testRig = worldScripts["oolite-script-test-rig"];
	var require = testRig.$require;
	
	const fileName = "oolite-test-sound-silence-1s.ogg";
	const csKey = "[oolite-test-sound-customsounds]";
	
	var testSource;
	
	testRig.$registerTest("SoundSource constructor", function ()
	{
		testSource = new SoundSource;
		require.instance("testSource", testSource, SoundSource);
		require.property("testSource", testSource, "isPlaying", false);
		require.property("testSource", testSource, "loop", false);
		require.property("testSource", testSource, "repeatCount", 1);
		require.property("testSource", testSource, "sound", null);
	});
	
	testRig.$registerTest("SoundSource properties", function ()
	{
		testSource.loop = true;
		require.property("testSource", testSource, "loop", true);
		testSource.loop = false;
		require.property("testSource", testSource, "loop", false);
		
		testSource.repeatCount = 3;
		require.property("testSource", testSource, "repeatCount", 3);
		// Documented maximum is 100.
		testSource.repeatCount = 500;
		require.property("testSource", testSource, "repeatCount", 100);
		// Documented minimum is 1.
		testSource.repeatCount = 0;
		require.property("testSource", testSource, "repeatCount", 1);
		testSource.repeatCount = 1;
		require.property("testSource", testSource, "repeatCount", 1);
	});
	
	testRig.$registerTest("SoundSource load file name", function ()
	{
		testSource.sound = fileName;
		require.instance("testSource.sound", testSource.sound, Sound);
		require.property("testSource.sound", testSource.sound, "name", fileName);
		
		testSource.sound = null;
		require.property("testSource", testSource, "sound", null);
	});
	
	testRig.$registerTest("SoundSource load customsounds entry", function ()
	{
		// csKey is a customsounds.plist entry which refers to fileName, so the results should be the same.
		testSource.sound = csKey;
		require.instance("testSource.sound", testSource.sound, Sound);
		require.property("testSource.sound", testSource.sound, "name", fileName);
		
		testSource.sound = null;
		require.property("testSource", testSource, "sound", null);
	});
	
	testRig.$registerTest("SoundSource play", function ()
	{
		testSource.repeatCount = 2;
		testSource.playSound(fileName);
		testSource.playOrRepeat();
		
		var deferredRef = testRig.$deferResult(4);
		var testStillPlayingTimer = new Timer(this, function ()
		{
			if (!testSource.isPlaying)
			{
				deferredRef.reportFailure("Expected testSource to be playing.");
			}
		}, 2.5);
		var testTimer = new Timer(this, function ()
		{
			if (!testSource.isPlaying)
			{
				deferredRef.reportSuccess();
			}
			else
			{
				deferredRef.reportFailure("Expected testSource to have stopped playing, but it's still playing with repeat count " + testSource.repeatCount);
			}
		}, 3.5);
	});
}
