# VRTK - Video Releaser's Toolkit

VRTK is designed to help people who works with video publishing.
Currently it can:
* create video preview screenshots
* create screenlists (collage)
* more features soon!

## Installation

### Prebuilt binaries
You can download prebuilt binaries from [Releases page](https://github.com/mrakobeze/vrtk).

### Building from source
Unfortunately, we do support builds for Windows only. UNIX builds in progress. 
#### Windows (x64 only)

 > You need Ruby 2.3 or newer to be in your path!

Clone this repository:

    git clone https://github.com/mrakobeze/vrtk
    cd vrtk

Install deps with bundler:
    
    gem install bundler
    bundler install

Then run rake build task:

    rake win32:build:folder             # Builds VRTK to pkg/win32 folder.
    rake win32:build:zip                # Builds :folder and then packs to zipfile.
    rake win32:build:inno               # Builds :folder and then creates an installator using INNO Setup Script.
                                        # Script template can be found in 'dist/innosetup' directory.
    rake win32:build:inno:generate      # Does not build anything, just generates INNO script from template 
                                        # to be able for you to edit it as you need.

That's definitely all.

## Usage

Basic usage:

    vrtk <applet> [applet options]
    
More information you can get if you run `vrtk help` and `vrtk <applet> --help` for any applet.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mrakobeze/vrtk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

This is licensed by Apache 2.0 License, which can be found in 'LICENSE.md'
