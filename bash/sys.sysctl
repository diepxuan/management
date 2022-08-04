#!/usr/bin/env bash
#!/bin/bash

--sys:sysctl:max_user_watches() {
    echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/90-max_user_watches.conf >/dev/null
    sudo sysctl -p
}
