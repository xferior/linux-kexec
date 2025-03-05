# linux-kexec

This script provides an easy way for users to switch between installed Linux kernels using `kexec`, allowing a kernel to be loaded without a full system reboot.

## Features

- **Dynamic initram Discovery**: Automatically finds the initrd or initramfs for a given kernel.
- **POSIX Compliance**: Uses POSIX-compliant syntax for broad compatibility.
- **Kexec Execution**: Prepares and executes the `kexec` command.
- **Tool Check**: Verifies if `kexec` is installed and provides installation help if not.
- **Root Check**: Ensures the script is run with root privileges.
- **Kernel Listing**: Lists all available kernels, excluding rescue entries.
- **Current Kernel Display**: Shows the current running kernel.
- **User Input**: Prompts the user to select from available kernels or confirm the only available kernel.
- **Automation**: Use `--latest` to boot to latest installed kernel, or `--current` to boot to current running kernel automaticly. 

## Usage and Examples

Examples from Ubuntu 22.04.3 LTS

Make sure the script is executable:

```shell
$ chmod +x linux-kexec-boot.sh
```
Install the scipt in $PATH. Set the symlink target to where you store the script:

```shell
$ sudo ln -s /home/user/linux-kexec/linux-kexec-boot.sh /usr/local/bin/
```

Run the script using sudo:

```shell
$ sudo linux-kexec-boot.sh
```

Kexec-tools are missing:

```shell
$ sudo linux-kexec-boot.sh 
kexec is not installed. Try installing it using: sudo apt-get install kexec-tools
```

Manually select different kernel:

```shell
$ sudo linux-kexec-boot.sh 
The running kernel is: 6.2.0-26-generic
Select the kernel to kexec boot into:
1) 6.2.0-26-generic
2) 6.2.0-36-generic
Enter kernel line number: 2
You have selected: 6.2.0-36-generic
Loading kernel: vmlinuz-6.2.0-36-generic
Loading initrd: initrd.img-6.2.0-36-generic
Booting to selected kernel...
```

Use `--latest` argument to boot into latest kernel:

```shell
$ sudo linux-kexec-boot.sh --latest
The latest kernel found is: 6.2.0-36-generic
Booting to latest kernel...
Loading kernel: vmlinuz-6.2.0-36-generic
Loading initrd: initrd.img-6.2.0-36-generic
Booting to selected kernel...
```

Use `--current` argument to boot into current running kernel:

```shell
$ sudo linux-kexec-boot.sh --current
Current running kernel is: 6.2.0-36-generic
Booting to current running kernel...
Loading kernel: vmlinuz-6.2.0-36-generic
Loading initrd: initrd.img-6.2.0-36-generic
Booting to selected kernel...

```

Warm reboot into only installed kernel:

```shell
$ sudo linux-kexec-boot.sh 
The running kernel is: 6.2.0-26-generic
Only one kernel found: 6.2.0-26-generic
Would you like to kexec into this kernel? (y/n) y
Loading kernel: vmlinuz-6.2.0-26-generic
Loading initrd: initrd.img-6.2.0-26-generic
Booting to selected kernel...
```
