# LAMENT

**L**efty **A**pplication, **M**odification, **E**diting and **N**otification **T**ool

LAMENT is a simple command line utility that edits system configuration files in a declarative manner. While providing declarativity, it also respects external changes made to the config files and integrates them to the declarative config.

## Why?

NixOS, Ansible, and a number of other programs provide various ways to configure a system declaratively. However, these programs either break or override when a config file under their responsibility is edited manually. This causes a lot of issues while troubleshooting because a huge amount of tutorials, forum posts, manual pages, GitHub issue comments, and even LLM generated answers involve direct editing of config files:

- open `/etc/default/grub` and append ...
- change the line that starts with `::1` in `/etc/hosts` to ...
- uncomment the line `...` in `/etc/chrony.conf`

When the user edits these lines, the declarative config overrides the edits, or the system breaks due to the conflict between the two files, leading to frustration.

However, a LAMENT config can align itself to the changes in these files.

## But why don't we let them simply edit the pre-existing config files?

The reason why LAMENT was created was to provide a command line utility to edit config files. The original problem that led to its creation was appending `modprobe.blacklist=nouveau` to the kernel command line parameters in `/etc/default/grub` in a post install script. Instead of simply using awk to append a command line parameter, we decided that we would have many similar issues in the near future, so we wanted to create a simple tool that can be used in scripts.

LAMENT provides a very simple way to configure a system in a CLI, while also respecting direct changes in the config files:

```bash
# makes a change in a line of system configuration.
lament kernel cmdline.modprobe.blacklist --append "nouveau"
# applies the changes in the configuration to the files.
lament --apply kernel
# re-calibrates LAMENT configuration, so the changes in other config files are kept under track
# except the newly configured `kernel` config module
lament --recalibrate --except kernel
```
