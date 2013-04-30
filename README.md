moolite
=======

Multiplayer Oolite (maybe, one day)

*** This is NOT an official version of Oolite. If you want the real deal, go to the official 
site at http://oolite.org/ and follow the download link. ***

FAQ
===
Q: This isn't an official OOlite repo - what are you up to?

A: I've wanted a multiplayer version of Oolite for ages but I really have no idea how or if
it might be possible. So I created a fork of the dev source in order to mess with it.

Q: Can I use what's in here?

A: Sure, but you do so at your own risk. There are no guarantees that it'll always be in a 
working state (I'll try, but I won't promise). As far as I know, by creating this fork, the
source remains freely available under the same terms as the original. I'm not claiming any 
rights over this stuff (other than kudos if it works!). Other than that, all IP still belongs 
to the original authors - check the official website at http://oolite.org/ for more info. 
The safest option if you do clone/fork from here is to make sure you maintain all the README 
and other attribution files.

Q. So what's the plan?

A. For starters, I'll vehemently deny all knowledge if I really screw this up. But if it all 
goes amazingly well I'll be wearing my badge of increased smugness and encouraging players to
try it out. But first things first: I'll have to get a working base together, and then bring
in the mods I added to the experimental repo. From there on it'll be a long hard slog I'm 
sure, but I have NO IDEA how long or how hard. If it was easy it'd have been done before now
I guess.

Q. How do I build it on Linux?

A. The best set of instructions I've found so far are here:
http://aegidian.org/bb/viewtopic.php?f=9&t=4595&start=150

Essentially, clone the repo to your machine e.g.;

$ git clone git@github.com:JustinPinner/moolite.git

(or get it from the official channels)

then run this command (if you don't already have GNUstep, gcc and all the other pre-requisites listed here);

sudo apt-get install gobjc gnustep-core-devel libsdl-mixer1.2-dev subversion libespeak-dev libnspr4-dev curl libgnustep-base-dev libsdl-image1.2-dev libglu1-mesa-dev

When that's done add these lines to your ~/.bashrc file;

#GNUSTEP Environment vars
. /usr/share/GNUstep/Makefiles/GNUstep.sh

and then cd into the directory you cloned the source into e.g.;

cd ~/moolite

and finally, kick off the compilation;

make

(or you may have to do this);

make -f Makefile release

Eventually you should end up with an oolite.app folder, inside which you'll find an oolite executable.

Enjoy!

