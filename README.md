<div align="center">

# NVMe Wipe & Sanitize

**Securely erase every NVMe drive in a computer from a bootable Ubuntu USB drive.**

![Platform: Ubuntu](https://img.shields.io/badge/platform-Ubuntu-E95420?logo=ubuntu&logoColor=white)
![Shell: Bash](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)
![Drives: NVMe only](https://img.shields.io/badge/drives-NVMe%20only-0A66C2)

</div>

> [!CAUTION]
> This script **permanently erases all NVMe drives** and **deletes the computer's boot entries**. This cannot be undone. Once it is set up, it runs automatically every time you log in to the USB drive.

## Contents

- [What it does](#what-it-does)
- [Requirements](#requirements)
- [Setup](#setup)
- [Running the script](#running-the-script)

## What it does

| # | Action | Command |
|:-:|--------|---------|
| 1 | Installs `nvme-cli` if it is missing | `apt install nvme-cli` |
| 2 | Securely erases every NVMe drive | `nvme format <drive> -s 1` |
| 3 | Reloads the NVMe driver | `rmmod nvme && modprobe nvme` |
| 4 | Deletes all EFI boot entries | `efibootmgr -b <entry> -B` |
| 5 | Powers off the computer | `systemctl poweroff` |

## Requirements

- A computer with **NVMe drives**. SATA drives and hard disk drives (HDDs) are not supported.
- A **USB drive** with room for Ubuntu and a persistent partition of at least 10 GB.
- A **network connection** on the first run to install `nvme-cli`. Later runs work offline.

## Setup

These steps create a persistent Ubuntu live USB drive that runs the script automatically at login.

### 1. Create a bootable USB drive

Download the [Ubuntu Desktop ISO image](https://ubuntu.com/download/desktop), then follow the steps for your operating system.

> [!NOTE]
> The USB drive needs a **persistent partition** so the script and autostart entry survive a reboot. Tools without persistence support, such as balenaEtcher and Ubuntu's Startup Disk Creator, will not work.

#### Windows

Download [Rufus](https://rufus.ie). Use Rufus to create a bootable USB drive from the ISO image, and set **Persistent partition size** to at least 10 GB.

#### Ubuntu and other Linux distributions

Install [mkusb](https://launchpad.net/~mkusb/+archive/ubuntu/ppa):

```bash
sudo add-apt-repository ppa:mkusb/ppa
sudo apt update
sudo apt install mkusb
```

Run `mkusb`, choose the **persistent live** option, select the ISO image and the USB drive, and give the persistent partition at least 10 GB.

#### macOS

There is no reliable macOS tool that creates a persistent Ubuntu USB drive. Use a Windows or Linux computer for this step. The finished USB drive works on any computer with NVMe drives.

### 2. Boot from the USB drive

Boot the computer from the USB drive. When the Ubuntu installer opens, close it.

### 3. Download the script

Open a terminal (<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>T</kbd>) and download the script to the Desktop:

```bash
wget -O /home/ubuntu/Desktop/wipesanitize.sh https://raw.githubusercontent.com/oncekaelen/nvme-wipe-sanitize/main/wipesanitize.sh
```

If `wget` isn't installed, use `curl` instead:

```bash
curl -fL -o /home/ubuntu/Desktop/wipesanitize.sh https://raw.githubusercontent.com/oncekaelen/nvme-wipe-sanitize/main/wipesanitize.sh
```

<details>
<summary>Or download it with Firefox</summary>
<br>

Open [wipesanitize.sh](wipesanitize.sh) in Firefox and click **Download raw file**. Then use the Files app to move it from the Downloads folder to the Desktop folder.

</details>

### 4. Make the script executable

```bash
chmod +x /home/ubuntu/Desktop/wipesanitize.sh
```

### 5. Create the autostart folder

Create the folder if it does not already exist:

```bash
mkdir -p /home/ubuntu/.config/autostart
```

### 6. Create the autostart entry

Open a new file in the nano text editor:

```bash
nano /home/ubuntu/.config/autostart/wipesanitize.desktop
```

Paste the following into the file (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>V</kbd>):

```ini
[Desktop Entry]
Type=Application
Name=Wipe Sanitize
Exec=/home/ubuntu/Desktop/wipesanitize.sh
Terminal=true
X-GNOME-Autostart-enabled=true
```

Press <kbd>Ctrl</kbd>+<kbd>O</kbd>, then <kbd>Enter</kbd> to save, and <kbd>Ctrl</kbd>+<kbd>X</kbd> to exit.

## Running the script

> [!WARNING]
> From this point on, the script runs automatically every time you log in. It permanently erases all NVMe drives and deletes the computer's boot entries.

Restart the computer, or log out and back in. The script opens automatically in a terminal window and powers off the computer when it finishes.
