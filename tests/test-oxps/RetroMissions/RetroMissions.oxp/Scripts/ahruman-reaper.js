/*
	Disable other world scripts by deleting all their properites.
	
	This isn’t entirely reliable, since scripts could have started a timer in
	startUp(), but it’s good enough.
*/

this.name			= "ahruman-reaper";
this.version		= 1.0;


this.startUp = function reaper_startUp()
{
	let targets =
	[
		"oolite-constrictor-hunt",
		"oolite-cloaking-device",
		"oolite-nova",
		"oolite-thargoid-plans",
		"oolite-trumbles"
	];
	
	for (let i = 0; i < targets.length; i++)
	{
		let name = targets[i];
		try
		{
			reap(worldScripts[name], name);
		}
		catch (e)
		{
			log("reaper.error", "No world script named \"" + name + "\".");
		}
	}
	
	function reap(target, name)
	{
		for (prop in target)
		{
			if (target.hasOwnProperty(prop))
			{
				delete target[prop];
			}
		}
		
		log("reaper", "Disabled " + name + ".");
	}
	
	delete this.startUp;
}
