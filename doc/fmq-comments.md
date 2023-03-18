= Federico's comments on gdm-container =

Initially I was confused by the name: gdm-container is just not about
containerizing GDM, but about distributing all the packages for the
graphical session as a contaienr image, to put on top of MicroOS or
another "immutable" system.

Per the README.md, there are various options for installing and
running this: standalone process in a container, systemd in a
container, systemd system extension, systemd portable service.

I think we can evaluate these options based on what we want the UX to
be.  So, let's come up with a rubric.

== Installation ==

How do users install this?  Do we hand out a `podman container
runlabel` command line?  Does the graphical installer do this?

There are still manual steps that need to be done beforehand,
hopefully only setting `SELINUX=permissive`, which requires a reboot.
Why is this needed?  How would we remove the need for that?

== Baseline functionality ==

DBus seems funky in the standalone process; gnome-terminal doesn't run.  It is
easy to get gdm's logs for diagnosing problems (this needs documenting).

The systemd-in-a-container option seems more reliable; gnome-terminal
runs.  I think it is harder to get gdm's logs, since (I think) the
nested journald eats them.  It will be very painful to debug user's
problems unless we push these out to the system's journal.

There is no `sudo` in the graphical session!  Maybe this is what the
immutable system is all about?  I had to remind myself to run `flatpak
some_command --user`, since the default is to install as root, but
when I get prompted for the root password, it doesn't work.

There is no audio, which means the Orca/screenreader can't work -
there is no volume indicator in the shell's top bar, and the Sound
pane in gnome-control-center shows no output devices.  However, its
"system sounds" at the bottom (Click, String, Swing, Hum) *do* make a
sound when I click them.

Gnome-shell and gnome-control-center think that there is no networking
at all, but e.g. flatpak works from a terminal.

Firefox works from a flatpak, but it can't play audio.

== Updating the graphical components ==

In theory one can have multiple versions/tags of a container image
downloaded.  Does this mean we can allow the user to install different
versions of the graphical environment?  Do we need to worry about
collisions between things in /etc?

Does this enable atomic upgrades of the graphical session, or of the
underlying system, without disturbing the other one?

== Systemd system extension / portable service ==

I haven't been able to get these to work.

== Sandboxing ==

Do we want sandboxing, and if so, how restrictive / how open?

It would be nice to make it impossible to trash the base system.  I
don't know how much things like xdg-desktop-portal assume that the
user's session is running in an unconstrained environment, for
example, for accounts, screencasts, cameras/pipewire.

**Scope creep alert:** It would be really nice to keep the user's session
away from the user's secrets — not just the applications, but things
like gnome-shell — and constrain that to implementors of the secrets
portal.  This may be out of scope.

== Similar projects == 

https://ublue.it/ - Based on Fedora Silverblue / ostree.  Jorge Castro
produces very interesting material about this.
