Ay_Emul v2.8 beta 7

Ay_Emul v2.7 official fixes and Ay_Emul v2.8 progress
-----------------------------------------------------

v2.7 Fix 1 + BASS initial support:

20 April 2003

- SaveAs... and Search for tunes in files for ASC0 files had lost last byte,
  fixed now

15 June 2003

- Short titles can be wrongly displayed after some playlist operations on main
  window (fixed)
- Channels amplification was not selected during autoselecting chip type from
  playlist entry (fixed)
- Visualisation stops if Next or Prev buttons are pressed during pause (fixed)
- Added BASS.DLL v1.8 file types support (MP3, MOD and so on)
- Fixed some time diplaying problems in reverse count mode

v2.7 Fix 2:

28 June 2003

- BASS.DLL v1.8a supported (FFT4096)
- Playlist popup menu appearance error fixed ("system menu" key error)

1 July 2003

- Preamp moved to AY Emulation tabsheet of Mixer window
- Volume control controls global volume of system mixer now

27 July 2003

- VTX's Year member zero value is interpreted as 'no year information'
- VTX header editor allows to enter empty Year value

v2.7 Fix 3:

19 August 2003

- PT3 player: note correction after adding ornament is made as in Pro Tracker
  v3.6x (less than minimum come to minimum and greater than maximim come to
  maximum)

v2.7 Fix 4:

21 August 2003

- Added registering BASS file types in system (associating with Ay_Emul)
- Added volume control response if volume changed by other mixer programs

27 August 2003

- BASS's sound device and BASS.DLL both are freed after reaching end of playlist
  now

28 August 2003

- Added initial support of AudioCDs

v2.8 Beta:

22 October 2003

- Added filter for quality downsampling. It improves soundchip emulation of some
  AY musician's tricks like "Envelope + Ultrasound", etc, and also improves
  beeper sound emulation (Savage.ay, etc)
- Settings are saved in registry in new format
- All settings are saved automatically now, corresponding button is removed
- Default language is English now
- Tools and Mixer windows both are redesigned
- Fixed error of 2.7+ version only: some AY-files was not played correctly due
  wrong initialization of emulated Z80 RAM (see Mickey.ay from Ironfist's
  collection)

23 October 2003

- Skins directory is saved now
- BASS and system volume parameters are saved now too
- AY and YM indicators on main window show right information not only during
  playing now

25 October 2003

- Added 'Uninstall' button to complete removing Ay_Emul data from your system

v2.8 Beta 2:

26 October 2003

- Fixed some errors of previous release

1 November 2003

- BASS v2.0 is supported
- Time seeking after end of AY file started playing of next playlist item even
  if Loop button is on; fixed now
- Fixed some problems with redrawing time in "song length" time displaying mode
- Colors of playing item highlighting slightly changed
- Fixed error of redisplaying shorter titles on main window after editing
  playlist entry

2 November 2003

- Added two new icons by Exocet/JFF^Spaceballs^Industry
- Fixed error of time positioning in FXM (ZXAYAMAD) files
- Added PlayListLoop button to loop playing of all playlist items
- Added PlayListPlayingOrder button to select one of playlist items play modes:
  forward, backward, random orders and play only one item mode
- Playing order can be set by this new button only now

v2.8 Beta 3:

3 November 2003

- WaveOut code slightly changed to avoide deadlocks with bad soundcards drivers

4 November 2003

- Tracker modules loader and time length calculator is improved to avoid
  deadlocks with badly ripped or wrongly detected modules
- SQT detector is improved a little

6 November 2003

- Found STC file with not same patterns lengths (see SAT2.STC), so, STC file
  duration calculation is a little changed now

8 November 2003

- All hotkeys in main window can now works without Alt and Ctrl (1, 2, T, E, P,
  G)

14 November 2003

- Fixed error in filter (thanks to Key-Jee for bug-report and test module)

15 November 2003

- Fixed error of infinite looping playlist if all items has errors (i.e. not
  playable)
- Delete/clear playing item from playlist during vertical scrolling titles on
  main window works rightly now

18 November 2003

- Added several ways of sorting playlist items

19 November 2003

- AY emulation parameters setting is synchronized with playing thread now (for
  more safety AY emulation adjusting during playing)

v2.8 Beta 4:

22 November 2003

- After moving playlist item playing order was not recalculated (fixed)
- BASS.DLL fix: right playing tracker modules with 'jump' command at the middle
  of last position (thanks to Ian Luck for immediate fixing; see music from
  Aladdin game converted from AMF to S3M)

24 November 2003

- Main window's hotkeys work in playlist now

28 November 2003

- Added new icon from Roman Morozov
- Esc can be used to close playlist now
- Fixed errors of previous release

2 January 2004

- Fixed portamento to first note of pattern in PT2 player (see
  DejaVU#06_14-Epilogue.pt2 by Nik-O)

24 January 2004

- Fix: opening files and playlists with precalculated time length from command
  line updates total time label in playlist now

17 February 2004

- Fix: opening files and playlists with precalculated time length after
  drug'n'droping updates total time label in playlist now

v2.8 Beta 5:

20 February 2004

- Spaces between substrings in Track Descriptor was removed (specially for
  Key-Jee)

8 March 2004

- Fixed EPSG2PSG converter if both PSG's has same name (temp file was not
  renamed)

12 August 2004

- Fixed stupid bug: error message and no running if no CD-drives in system
  (thanks to Slava Kalinin for bug-report), soon will be fixed in v3.0 too
- Play positioning is slightly fixed: no unexpected delays when pressing left
  and right arrows keys to rewind
- Added additional syncronization into WaveOut thread
- Visualisation is improved: envelope sound visualized better (different levels
  for different envelope types including "soft" envelopes
- Two extra chars can be added to song name during finding or loading STC-files.
  They are got from extra ModuleSize field of STC-header (for example, Agent-X
  used this ability)

v2.8 Beta 6:

18 September 2004

- PT3 module finder is improved to more stable detect of PT3 modules with modern
  structure (Pro Tracker 3.6x and VT II 1.0)

27 October 2004

- Non-Delphi ScrollBar in playlist window (no need to mask corresponding Delphi
  error)
- You can drug'n'drop folders now (to main and playlist windows)

v2.8 Beta 7:

7 November 2004

- Added sorting by file type into playlist

14 November 2004

- Balance was set to middle by volume control (fixed)

29 December 2004

- Visualisation thread was moved to main one, so, there are no some problems
  in WinXP now. If you was using v3.0 as more stable version, you can back to
  v2.8 now

31 December 2004

- Masked some problems with buggy WM_ENDSESSION handler in Delphi 7 VCL
- Added WindowsXP controls
- Fixed bug with saving states of "Get from list" checkers in Mixer window


1 January 2005

- Added saving playlist visibility before closing application
- The latest BASS.DLL v2.1 is supported
- Removed timelength recalculation when interrupt frequency is changed temporary

v2.8 Beta 8:

6 January 2005

- Fixed FLS-player: ornament must be disabled during selecting envelope

7 January 2005

- Fixed FLS- and FTC-players: checking note range was [0..85] (correct is
  [0..95])

14 January 2005

- Fixed errors of working with system mixer (crytical error, Ay_Emul 2.8 beta 7
  did not work on some computers at all)
- Old bug is fixed: error in PT2-files timelength calculation (not used Tempo
  setting in channel C, see "*ELEPHANT*  BY JAAN_PHT 160896" module as example)
- Added 'Find playlist items' dialog into playlist window (call by F7)

15 January 2005

- Ay_Emul 2.8 beta 7 does not work rightly with command line parameter "/vhide"
  at first startup. Fixed.

v2.8 Beta 9:

6 February 2005

- PT2 note table removed (because of same as PT3 note table #1)

12 February 2005

- PT2 note range checking changed to PT3 standard (original PT2-player has no
  range checking anyway)

10 May 2005

- WMA support added (via BASSWMA.DLL v2.1 by Ian Luck). WMA playback requires
  the Windows Media Format modules to be installed. They come installed with
  Windows Media player, so will already be on most users' systems, but they can
  also be installed separately (WMFDIST.EXE is available at the un4seen.com)

12 May 2005

- WAV converter now uses PreAmp and Quality settings from mixer (thanks to
  T.A.D. 2005 for bug-report)
- Added Ay_Emul v3.0 behaviour during moving "main" and "about" windows

13 May 2005

- Shows number of items in playlist window (specially for Alone Coder)

15 May 2005

- Integrity checking is added into modules finder (specially for T.A.D. 2005)
- Fixed error in PT2.4PF finder (thanks to T.A.D. 2005 for WILD_SEY.tzx test
  file)
- Playlist loop button is used now in "play only current item" mode (specially
  for T.A.D. 2005)
- Fixed error: after drug'n'dropping files to active window, keyboard shortcuts
  not work until mouse click (thanks to T.A.D. 2005 for bug-report)
- Fixed error: waveout buffer access violation (thanks to T.A.D. 2005 for
  bug-report)

16 May 2005

- Added playlist color setup (specially for MadCat!)
- Corrected time length calculator for GTR v1.1 modules (see HYMN.gtr)

v2.8 Beta 10:

18 May 2005

- Fixed error: one position length PT3-files was not detected by module finder
  (thanks to Newart)

21 May 2005

- Fixed error of Beta 9: FLS structure analizer error
- Added 'Select CD(s)' dialog to load whole CD content. Function checks all CD's
  tracks and loads only audiotracks (even if its not available in standard file
  browser). Hold 'Ctrl' during clicking 'Open' or 'Add items' buttons (or use
  'Ctrl+L' and 'Ctrl+Insert')

13 June 2005

- YM2 samples are supported now (thanks to Arnaud Carre for sources and to
  Key-Jee for comments)

16 June 2005

- Command line analizer can expand filenames relatively to current directory
  path (specially for SMT), so, you don't need to specify full path now
- Added new command line key "/add" to add files from command line to the end of
  current playlist (specially for TAD and SMT). The key works only if Ay_Emul
  was started before

v2.8 Beta 11:

20 August 2005

- Fixed error in GTR loader and saver (thanks to TAD for CC#4 intro GTR-music)

10 September 2005

- Added PSM (compiled Pro Sound Maker modules) support

11 September 2005

- Show playing item number in playlist down right corner (specially for TAD)
- Integrity checker in modules finder is improved
- SQT finder is improved
- Tray icon reaction changed to single left click

15 September 2005

- Added TRD catalog analizer (works after loading TRD in playlist, specially for
  SMT)

16 September 2005

- Added SCL and Hobeta headers analizers (work after loading it in playlist,
  thanks to SMT for idea)
- Added deafult filename in "Save as.." dialog (specially for TAD), autoselects
  among original file name (from disk image file), song title or source file
  name

17 September 2005

- After loading TRD, SCL or Hobeta into playlist, AY_Emul extracts author and
  title strings from corresponding playing routine of ASC and STP modules
- 'Save as...' from playlist inserts title string to STP and ASC modules (if it
  was extracted from playing routine during loading into playlist)

18 September 2005

- Added PSC v1.00-1.03 support
- AY-files without file extension '.AY' was not detected (fixed)
- ESC key is used to close 'About' window now (specially for TAD)

20 September 2005

- Added YM5- and YM6-files integrity checker before loading to avoid problems
  during playing (thanks to Nikolay Amosov for test file
  JASON_BROOKE_OUTRUN_GAME_TUN2.YM)
- Added YM5- and YM6-files sample number range checker (thanks to Nikolay Amosov
  for test file MODU_ATTACK.YM)

24 September 2005

- Added new command line key "/adp" to add files from command line to the end of
  current playlist and start playing first ot them (specially for TAD)
- AY frequency range is up to 3.5 MHz now (specially for Vyacheslav Strunov and
  others)

v2.8 Beta 12:

8 October 2005

- ZXS-files registration removed from 'Tools' box

26 October 2005

- From one of last versions STP finder didn't work fine with initialized
  STP-modules (fixed)
- STP_InitId (header byte +9) after "Save As..." was equal to 0 for wrongly
  "uninitialized" STP-modules (fixed now). All modules are playable in Ay_Emul,
  but original ZX Spectrum STP player does not initialize them correctly and
  fails. All STP-modules ripped in Tools dialog has correct STP_InitId value
  anyway

4 November 2005

- Added Pro Tracker 3.x Utility modules support (with converting to snandard
  PT3)
- Only previous version error: after saving ASC0 files from playlist '.asc'
  extension was not appended (fixed)
- Changed 'Save As...' autofilename behavior (specially for TAD). Now, if
  original filename was not found, it uses source filename with appended
  hexadecimal index (playlist position number)

9 November 2005

- Shadow file inside of created YM6-file has '.ym' extension now (specially for
  T.A.D. 2005)