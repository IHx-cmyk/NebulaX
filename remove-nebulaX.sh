#!/data/data/com.termux/files/usr/bin/bash
echo "Uninstall NebulaX..."

rm -f ~/.termux/colors.properties
termux-reload-settings 2>/dev/null

if ls ~/.bashrc.bak-nebulaX* 1> /dev/null 2>&1; then
    latest=$(ls -t ~/.bashrc.bak-nebulaX* | head -1)
    mv "$latest" ~/.bashrc
    echo "Restored from $latest"
else
    rm -f ~/.bashrc
    echo "Custom .bashrc removed → default after restart"
fi

echo "Done. Restart Termux."
