Separate Team and Global Voice Chat
------------------------------------
Version: 1.0.0r3
2-17-2016


This plugin is intended to provide separate options for team and global voice chat.

It creates the following commands:

+voicealt
-voicealt

+voicealt should cause the opposite behavior to sv_alltalk.
If alltalk is on, +voicealt should cause only team members to be able to hear you.
If alltalk is off, +voicealt should cause everyone to be able to hear you.


+voiceteam
-voiceteam

+voiceteam should cause only team members to be able to hear you.


+voiceglobal
-voiceglobal

+voiceglobal should cause everyone to be able to hear you.


The general intended behavior of these commands is that if one is turned "on", 
while another has already been turned "on", then the final result would be equivalent to, 
turning the former command off, and then turning the latter command on.

An example is: entering "+voicealt", then entering "+voiceteam".
The result would be equivalent to: entering "+voicealt", then "-voicealt", and finally, "+voiceteam".

Each of the "off" commands (-voicealt, -voiceglobal, -voiceteam), should only  work with its respective,
"on" command. (+voicealt, +voiceglobal, +voiceteam). For example: entering "+voicealt", then "-voiceteam",
should not change the current behavior, of "+voicealt".


Other features:

- Compatibility with the SourceMod muting functionality.
Specifically, the muting functionality provided by the basecomm plugin should still work.
The plugin should still track if one of the commands provided by this plugin is "on",
when a player is unmuted, and resume the normal function of that command.

- Detecting change of sv_alltalk. 
The plugin should detect the change of the sv_alltalk ConVar, and automatically readjust its behavior,
so that if any of the commands created by it are on, they should still function correctly.

- Detecting team changes.
The plugin should automatically recalculate which players may hear each other, on team change, if necessary.


Compiling instructions:


Ensure that the following directory structure is present: 

./SeparateTeamGlobalVoice/actions.sp
./SeparateTeamGlobalVoice/interface.sp
./SeparateTeamGlobalVoice.sp


Note that the name of SeparateTeamGlobalVoice.sp may be changed.
This should be already be present in the included zip file, so you may simply,
extract to the scripting directory of your SourceMod installation, and do the following in Windows:

spcomp.exe SeparateTeamGlobalVoice<version>\SeparateTeamGlobalVoice.sp

or in Linux:

./spcomp SeparateTeamGlobalVoice<version>/SeparateTeamGlobalVoice.sp

The compiled plugin should be in the current directory.

You may use the "-o" option to specify an output path for the file. There must NOT be a space between -o and its respective option.
Ex: ./spcomp SeparateTeamGlobalVoice<version>/SeparateTeamGlobalVoice.sp -ocompiled/SeparateTeamGlobalVoice<version>.smx


You may find more information about compiling plugins at: https://wiki.alliedmods.net/Compiling_SourceMod_Plugins


Changes
--------

* Fixed a typo in a comment in actions.sp. Should be functionally identical.
