#!/bin/bash

# Define custom text and corresponding multi-line commands as arrays
custom_ops=(
  "Improve DNF Speed by updating conf file"
  "Adding RPM Fusion"
  "Updating firmware"
  "Installing media codecs"
  "Installing Hoyoverse repo"
  "Installing commonly used apps"
  "Removing bloatware"
)

imp_dnf () {
  cd
  cd /etc/dnf
  sudo sed -i '$a fastestmirror=1' dnf.conf
  sudo sed -i '$a max_parallel_downloads=10' dnf.conf
  sudo sed -i '$a deltarpm=True' dnf.conf
  sudo sed -i '$a defaultyes=True' dnf.conf
  cd
}

custom_commands=(
  # Improve DNF Speed by updating conf file
  "imp_dnf"
  # Adding RPM Fusion
  "sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm; sudo dnf groupupdate -y core; sudo dnf upgrade -y --refresh"
  # Updating firmware
  "sudo fwupdmgr get-devices; sudo fwupdmgr refresh --force; sudo fwupdmgr get-updates; sudo fwupdmgr update"
  # Installing media codecs
  "sudo dnf groupupdate -y 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync; sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing; sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg; sudo dnf install -y lame\* --exclude=lame-devel; sudo dnf group upgrade -y --with-optional Multimedia"
  # Installing Hoyoverse repo
  "flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo"
  # Installing commonly used apps
  "sudo dnf install -y gnome-console gnome-tweaks gnome-shell-extension-pop-shell xprop unzip p7zip p7zip-plugins unrar; flatpak install -y one.ablaze.floorp io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager ca.desrt.dconf-editor"
  # Removing bloatware
  "sudo dnf remove -y gnome-boxes gnome-contacts gnome-logs gnome-tour mediawriter gnome-abrt gnome-terminal firefox"
)

# Define your function
func_proc () {
  # Extract custom text and commands from function arguments
  local custom_ops=("${!1}")  # Indirect reference to array variable
  local custom_commands=("${!2}")  # Indirect reference to array variable

  # Define colors
  BLUE='\033[0;34m'
  WHITE='\033[0;37m'
  RED='\033[0;31m'

  # Print available commands
  echo "Available commands:"
  for ((i = 0; i < ${#custom_ops[@]}; i++)); do
    echo "$((i+1)). ${custom_ops[i]}"
  done

  # Prompt user to select commands
  read -p "Enter the numbers of the commands to run (separated by spaces), or 'all' to run all commands: " selected_indices
  selected_indices=${selected_indices:-all}

  # Check if 'all' was selected
  if [ "$selected_indices" == "all" ]; then
    selected_indices=$(seq -s ' ' 1 ${#custom_ops[@]})
  fi

  # Convert selected indices to array
  IFS=' ' read -ra indices <<< "$selected_indices"

  # Execute selected commands
  for index in "${indices[@]}"; do
    if [[ $index =~ ^[0-9]+$ && $index -ge 1 && $index -le ${#custom_ops[@]} ]]; then
      echo -e "${BLUE}${custom_ops[index-1]} ${WHITE}"
      eval "${custom_commands[index-1]}"
      echo -e "${RED}Process Completed!${WHITE}"
    else
      echo "Invalid selection: $index"
    fi
  done

  sudo dnf upgrade -y --refresh
  sudo dnf autoremove -y

  echo -e "${BLUE}It is recommended to reboot${WHITE}"
  read -p "Press y to continue: " reboot_now
  reboot_now=${reboot_now:-y}

  if [ "$reboot_now" == "y" ];
  then
    reboot
  fi
}

# Call the function with arrays of custom text and multi-line commands
func_proc custom_ops[@] custom_commands[@]
