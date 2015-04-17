# Limelight Openelec
Collection of scripts to run limelight in openelec on raspberry pi.

## Features 
* Script to start a session from kodi and restart kodi after finishing session
* Script to resume a running session
* All scripts automatically start a script to monitor cec during session and kill java on certain keypress to go back to kodi
* Keybinding for wired xbox360 controller
* Keyboard and Mouse are working thanks to a hack with `screen` command, no input specification for limelight needed

## Instructions
1. Install Openelec
2. Add screen and commands addons
3. Download Java and extract
4. Download [Limelight Embedded](https://github.com/irtimmer/limelight-embedded)
Copy it to `/storage/downloads/limelight` directory
5. Extract these scripts to `/storage/downloads/limelight` directory
6. Make symbolic link `/storage/downloads/limelight/java` to java binary
You can use other directories by editing script settings
7. In Kodi add `limelight_720_60.py` and other start files to commands addon
For easier access place commads addon to favorites
8. Install `xboxdrv` to `/storage/downloads/xboxdrv`  
Binary `xboxdrv` from debian needs some libraries from debain armhf build which are not part of openelec put them in `/storage/downloads/xboxdrv` after download.
Here is a list of needed files and packages which contain them 

|Symlink                |File                        |Deb-Package                       |
|---------------------- |----------------------------|----------------------------------|
|                       |xboxdrv                     |xboxdrv_0.8.5-1+b1_armhf.deb      |
|libdbus-glib-1.so.2    |libdbus-glib-1.so.2.2.2     |libdbus-glib-1-2_0.102-1_armhf.deb|
|libX11.so.6            |libX11.so.6.3.0             |libx11-6_1.6.2-3_armhf.deb        |
|libXau.so.6            |libXau.so.6.0.0             |libxau6_1.0.8-1_armhf.deb         |
|libxcb.so.1            |libxcb.so.1.1.0             |libxcb1_1.10-3+b1_armhf.deb       |
|libXdmcp.so.6          |libXdmcp.so.6.0.0           |libxdmcp6_1.1.1-1+b1_armhf.deb    |

9. Pair Limelight with your pc
10. Setup desktop streaming by adding following "Game" to GFE in Windows  
Name `Desktop` , Command `C:\Windows\System32\mstsc.exe` , Folder `C:\Windows\System32`

## Notes
When started from kodi limelight does not have a console and this prevents for some reason keyboard and mouse from working. To solve this we are using screen command in python starter scripts to fake a console

In the script there are a lot of sleep commands. Those are crude hacks to get the timing right so that kodi does not restart to early and cec stop working

To change the cec exit key, stop kodi and start cec-client, press your favorite key and look for the output. Change `killoncec.py` accordingly

