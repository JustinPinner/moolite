Oolite Binary Release
=====================

Important!
First up: if this is the first time you've run Oolite, here's some things
that will get you out of any video/OpenGL trouble and you need to know.

Keyboard shortcut F12 toggles full screen/windowed mode.
Keyboard shortcut F11 and Shift-F11 changes resolution.

(The F2 menu has the list of resolutions, and will save the mode you select
there to your user defaults for Oolite).

Some older OpenGL cards can't hack Oolite in higher resolutions and 
often results in text not rendering or rendering as blocks. 
Try a lower screen resolution if you have problems. Most newer cards 
(tested with nVidia GeForce 4ti circa 2003, ATi Radeon Mobility circa 
2000, Intel integrated video circa 2003) work just fine in all supported 
resolutions.

Note for Fedora users only
==========================
If you encounter sound issues with Oolite try the following workaround:
1. cd into the Oolite installation folder 
2. execute "mv oolite-deps/lib/libSDL* oolite-deps/."
This will hide the distributed libSDL and libSDL_mixer libraries from 
Oolite and force it to use your system's libraries. If you do not have 
these libraries in your system, you should install them and check if 
that solves your sound issues. For some users this has worked.

Note for amd64(x86_64) users
============================
We are currently maintaining amd64 (x86_64) binary build. 
The package can be downloaded from:
http://www.oolite.org/download.shtml or
http://developer.berlios.de/project/showfiles.php?group_id=3577

If you're willing to maintain an amd64 binary build (i.e. at least
build an Autopackage for each stable release) please get in touch with
dyls@alioth.net or ksykas@gmail.com - indeed, if you're willing to 
maintain any non-x86 arch and any non-Linux OS (Oolite is at least 
known to run on FreeBSD) please let us know! 

Updating to new versions
========================
Now you have installed oolite, you can update it by running the
oolite-update script. A shortcut pointing at that script is installed
in /usr/bin. Running this updater will be considerably faster than downloading 
a new package. It uses rsync, and so can update from any version to any later
version or even try to restore a broken Oolite installation - you don't need 
to have the immediately previous release to update to a given package. 
When it completes, it will tell you what version it was when it started, 
and what version you now have.

Things that get created
=======================
When you run oolite for the first time, wherever you installed it, a GNUstep
directory will be copied into your home directory. The GNUstep backend needs
this. Additionally, in your home folder, an oolite-saves directory is created 
when you save a commander for the first time. A .Oolite folder is also created,
to store the application Logs and any AddOns (see the Adding AddOns paragraph below) 
you do not want to be visible when Oolite is run by another user. 
Finally, a .oolite-run file is created
(whose existence supresses the display of this README again)

Saved games
===========
Saved games currently are all saved in oolite-saves in your home directory.
You can copy any existing .oolite-save files (for example, from a Macintosh)
into this directory, and they will appear in the 'Load Commander' screen
in the game.
However, if you decide to install add ons, make sure if you buy an
add on ship you don't remove it, because your save game will stop working
if the ship it's based on doesn't exist!

Adding AddOns
=============
There's a whole heap of game add ons - missions, ships etc - on 

Oolite wiki - http://wiki.alioth.net/index.php/OXP
Oosat - http://capnhack.com/hosting/oolite/Oolite/OoSat.html
Oosat2 - http://oosat.alioth.net

To install an OXP, just copy the .oxp folder in the Oolite "AddOns" folder.
Next time you run Oolite, the OXP will be loaded.

If Oolite is installed system-wide then you have the following options:
A. OXPs visible by all users:
        Copy the .oxp folder in the <system-folder>/Oolite/AddOns/
B. OXPs visible only to a user:
        Copy the .oxp folder in the ~/.Oolite/AddOns/

Caution: if you save a game after buying a ship that was in an OXP,
if you subsequently remove the OXP, that commander file will be rendered
useless!

What are the dependencies that are packaged?
============================================
So far, we've tested the dependencies on a fresh install of 
Ubuntu, Debian, Mandriva, Fedora, OpenSuse and on LinpusLite (!!!) with
just the normal beginner's installation (i.e. accepting all the defaults
for the GNU/Linux distro installed). It should work on any Linux distribution
of the same vintage of Ubuntu 5.04, right the way back to Fedora Core 2
(the dependencies were built on an FC2 workstation). An old libc can
scupper you; it won't run on RedHat 8 for instance because libc is just
too old. It will also run on Knoppix (if you have somewhere writeable
to install it). Please let us know what distro you're using and whether
it worked or not via the oolite-linux forum (see the link below under
'If it's borked').

The dependencies in the deps package are:

A very minimal GNUstep 0.10 - the shared libaries and a pared-down GNUstep
system tree. This was compiled from GNU startup 0.10.
SDL (Simple Directmedia Layer)
SDL_mixer
libpng14
eSpeak + portaudio (only if you enable "Spoken Messages" in-game option)

You can download the source tarballs used to build these libraries from
http://ftpmain.gnustep.org/pub/gnustep/core/gnustep-make-2.0.8.tar.gz
http://ftpmain.gnustep.org/pub/gnustep/core/gnustep-base-1.18.0.tar.gz
http://www.libsdl.org/release/SDL-1.2.14.tar.gz
http://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-1.2.11.tar.gz
http://prdownloads.sourceforge.net/libpng/libpng-1.4.1.tar.gz?download
http://www.portaudio.com/archives/pa_stable_v19_20071207.tar.gz
http://downloads.sourceforge.net/project/espeak/espeak/espeak-1.43/espeak-1.43.03-source.zip?use_mirror=kent

I've not yet written a script to automate building these and copying the
required parts to the dependencies package; this was assembled by hand
(and since it will only rarely be updated, I probably won't bother either).
If you're constructing a package for a non-x86 or non-Linux platform, 
take a look in Linux-deps for the libraries (dynamic and static) and headers
you'll need to copy there. All of these dependencies I found straightforward to compile.

If it's borked
==============
Please report it in the oolite-linux forum. Please include screen
shots for graphics weirdness, and clear descriptions of sound
weirdness. Include any logs in the terminal window. If you launched Oolite
from an icon, you may need to start a Terminal and run it from there
so you can see the messages. The forum is here:
http://aegidian.org/bb/viewforum.php?f=9

Talking about it, reporting bugs etc.
=====================================
The oolite forums can be found here:
http://aegidian.org/bb

Credits
=======
Original OS X game: Giles Williams
Linux port: David Taylor, Giles Williams and Dylan Smith

...and of course the GNUstep project and the SDL, SDL_mixer and SDL_gfx
people, without which the Linux and Win32 ports would not have been
possible.

