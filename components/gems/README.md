The `gems` component is used by appbundler
to build all of the gems we ship as part of
Chef Workstation.

Gemfile.lock in this directory is the One True Source
of shipped gems.

To update the Gemfile.lock, run:

`bundle lock --update --add-platform ruby x64-mingw32 x86-mingw32 x64-mingw-ucrt`
