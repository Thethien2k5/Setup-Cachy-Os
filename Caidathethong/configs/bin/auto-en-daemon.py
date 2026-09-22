#!/usr/bin/env python3
import os
import sys
import socket
import subprocess
import threading
import time

def switch_to_en():
    try:
        subprocess.run(
            ["fcitx5-remote", "-s", "keyboard-us"],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except Exception:
        pass

def listen_upower_and_logind():
    try:
        import dbus
        from dbus.mainloop.glib import DBusGMainLoop
        from gi.repository import GLib

        DBusGMainLoop(set_as_default=True)
        system_bus = dbus.SystemBus()

        # 1. logind PrepareForSleep (Suspend/Sleep/Lid close trigger)
        def handle_sleep(sleeping):
            switch_to_en()

        system_bus.add_signal_receiver(
            handle_sleep,
            signal_name="PrepareForSleep",
            dbus_interface="org.freedesktop.login1.Manager"
        )

        # 2. UPower LidIsClosed property changes (Gập/mở màn hình laptop)
        def handle_upower_prop(interface, changed_props, invalidated_props):
            if "LidIsClosed" in changed_props:
                switch_to_en()

        system_bus.add_signal_receiver(
            handle_upower_prop,
            signal_name="PropertiesChanged",
            dbus_interface="org.freedesktop.DBus.Properties",
            path="/org/freedesktop/UPower"
        )

        loop = GLib.MainLoop()
        loop.run()
    except Exception:
        time.sleep(2)

def listen_hyprland_events():
    xdg_runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    
    while True:
        his = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
        sock_path = f"{xdg_runtime}/hypr/{his}/.socket2.sock" if his else ""
        
        if not sock_path or not os.path.exists(sock_path):
            hypr_dir = f"{xdg_runtime}/hypr"
            if os.path.isdir(hypr_dir):
                for d in os.listdir(hypr_dir):
                    test_sock = os.path.join(hypr_dir, d, ".socket2.sock")
                    if os.path.exists(test_sock):
                        sock_path = test_sock
                        break
        
        if not sock_path or not os.path.exists(sock_path):
            time.sleep(2)
            continue

        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
                s.connect(sock_path)
                with s.makefile("r", encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        line = line.strip()
                        # Bắt sự kiện màn hình tắt (dpms), khóa màn hình (lockscreen, lock)
                        if any(kw in line.lower() for kw in ["lockscreen", "dpms>>0", "dpms>>1", "lock"]):
                            switch_to_en()
        except Exception:
            time.sleep(2)

def main():
    t_dbus = threading.Thread(target=listen_upower_and_logind, daemon=True)
    t_dbus.start()

    listen_hyprland_events()

if __name__ == "__main__":
    main()
