#!/usr/bin/env fish

# Firefox + Betterfox
sudo pacman -S --needed --noconfirm firefox

function find_ff_profile
    find ~/.config/mozilla/firefox ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default-release" 2>/dev/null | head -n 1
end

set PROFILE_DIR (find_ff_profile)

# No profile yet: launch Firefox headless once so it creates one, then stop that instance
if test -z "$PROFILE_DIR"
    firefox --headless >/dev/null 2>&1 &
    set FF_PID $last_pid
    for i in (seq 30)
        set PROFILE_DIR (find_ff_profile)
        test -n "$PROFILE_DIR"; and test -f "$PROFILE_DIR/prefs.js"; and break
        sleep 1
    end
    sleep 2
    kill $FF_PID 2>/dev/null
end

if test -n "$PROFILE_DIR"
    curl -fsSL https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js -o "$PROFILE_DIR/user.js"; and ls -lh "$PROFILE_DIR/user.js"
else
    echo "Could not find or create a Firefox profile. Open Firefox once and re-run."
end

---


Test

firefox --version
echo "--- profile folders"
ls -d ~/.mozilla/firefox/* ~/.config/mozilla/firefox/* 2>/dev/null
echo "--- profiles.ini"
cat ~/.mozilla/firefox/profiles.ini ~/.config/mozilla/firefox/profiles.ini 2>/dev/null
echo "--- user.js"
ls -l ~/.mozilla/firefox/*.default-release/user.js ~/.config/mozilla/firefox/*.default-release/user.js 2>/dev/null
head -n 5 ~/.mozilla/firefox/*.default-release/user.js ~/.config/mozilla/firefox/*.default-release/user.js 2>/dev/null
echo "--- leftovers"
pgrep -a firefox; or echo "no firefox running"
