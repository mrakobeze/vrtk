# VRTK - Video Releaser's Toolkit

VRTK is designed to help people who works with video publishing.
Currently it can:
* grep screenshots from videos
* create collages
* analyze video metadata
* create well-designed release template
* create a torrent file on a template

More features are coming!

## Installation

### Prebuilt binaries
You can download prebuilt binaries from [Releases page][releases].

### Building from source
Currently we can provide auto-building on x64 Windows platforms. Also, some features work only on Windows.

#### Windows

##### Prerequisites
* Ruby (>= 2.4.2)
    * You can get freshest Ruby for Windows from [RubyInstaller][rubyinstaller].
* Git

##### Building
We recommend to use Ruby 2.4.2 or newer. 

First, clone repository:

    git clone https://github.com/mrakobeze/vrtk
    cd vrtk

Install deps with bundler:
    
    gem install bundler
    bundler install

Then run rake build task:

    rake win32:build:folder             # Builds VRTK to pkg/win32 folder.
    rake win32:build:zip                # Builds :folder and then packs to zipfile.
    rake win32:build:inno               # Builds :folder and then creates ISS installer.
    rake win32:build:all                # Builds both :zip and :inno.
                                        # Script template can be found in 'dist/innosetup' directory.
    rake win32:build:inno:generate      # Does not build anything, just generates INNO script from template 
                                        # to be able for you to edit it as you need.

Every build task checks `dist/` folder for folders named 'bindeps'. Each bindep contains binary files which is placed outside of repository.
When any bindep is missing, it's downloaded from our server and extracted to `dist/`. 
Currently project needs three bindeps: `ffmpeg`, `magick` and `mingw`.

## Usage
Basic usage:

    vrtk <applet> [applet options]
    
More information you can get if you run `vrtk help` and `vrtk <applet> --help` for any applet.

[releases]: https://github.com/mrakobeze/vrtk
[rubyinstaller]: https://rubyinstaller.org