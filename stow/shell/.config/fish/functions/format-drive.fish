function format-drive --description 'Format an entire drive for a single exFAT partition'
    if test (count $argv) -ne 2
        echo "Usage: format-drive <device> <name>"
        echo "Example: format-drive /dev/sda 'My Stuff'"
        echo -e "\nAvailable drives:"
        lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
        return 1
    end

    echo "WARNING: This will completely erase all data on $argv[1] and label it '$argv[2]'."
    read -P "Are you sure you want to continue? (y/N): " confirm

    if string match -qi 'y' $confirm
        sudo wipefs -a $argv[1]
        sudo dd if=/dev/zero of=$argv[1] bs=1M count=100 status=progress
        sudo parted -s $argv[1] mklabel gpt
        sudo parted -s $argv[1] mkpart primary 1MiB 100%
        sudo parted -s $argv[1] set 1 msftdata on

        if string match -q '*nvme*' $argv[1]
            set -l partition $argv[1]p1
        else
            set -l partition $argv[1]1
        end
        sudo partprobe $argv[1]; or true
        sudo udevadm settle; or true

        sudo mkfs.exfat -n $argv[2] $partition

        echo "Drive $argv[1] formatted as exFAT and labeled '$argv[2]'."
    end
end
