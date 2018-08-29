@ECHO OFF

SET "LINUXTMP=$(echo '%TMP:\=\\%' | sed -e 's|\\|/|g' -e 's|^\([A-Za-z]\)\:/\(.*\)|/mnt/\L\1\E/\2|')"
echo LINUXTMP = "%LINUXTMP%"

ECHO --- Running Linux installation.  You will be prompted for your Ubuntu user's password:
REM One big long command to be absolutely sure we're not prompted for a password repeatedly

echo apt-get update >> "%TMP%\script.sh"
echo apt-get -y install pulseaudio >> "%TMP%\script.sh"
echo wget https://github.com/PetreBoboc/wsl_gui_autoinstall/raw/master/libpulse0.deb >> "%TMP%\script.sh"
echo dpkg -i libpulse0.deb >> "%TMP%\script.sh"
echo apt-mark hold libpulse0 >> "%TMP%\script.sh"
echo sed -i 's/; default-server =/default-server = 127.0.0.1/' /etc/pulse/client.conf >> "%TMP%\script.sh"
echo sed -i "s$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$" /etc/dbus-1/session.conf >> "%TMP%\script.sh"
C:\Windows\System32\bash.exe -c "chmod +x '%LINUXTMP%/script.sh' ; tr -d $'\r' < '%LINUXTMP%/script.sh' | tee '%LINUXTMP%/script_clean.sh'; sudo '%LINUXTMP%/script_clean.sh'"

ECHO --- Downloading required third-party packages
ECHO --- VcXsrv...
C:\Windows\System32\bash.exe -xc "wget -cO '%LINUXTMP%/vcxsrv.exe' 'http://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.18.3.0/vcxsrv-64.1.18.3.0.installer.exe'"

ECHO --- Installing packages

ECHO --- Adding link for X Server to Startup Items
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Start Menu\Programs\Startup\VcXsrv.lnk');$s.TargetPath='%ProgramFiles%\VcXsrv\vcxsrv.exe';$s.Arguments=':0 -ac -terminate -lesspointer -multiwindow -clipboard -wgl';$s.Save()"

ECHO --- Launching X Server.  DO NOT grant access to any network interfaces if prompted; they are unnecessary.
START "%userprofile%\Start Menu\Programs\Startup\VcXsrv.lnk"

ECHO --- Adding X environment variable to your .bashrc
C:\Windows\System32\bash.exe -xc "echo 'export DISPLAY=localhost:0' >> ~/.bashrc"

ECHO All Done
PAUSE
