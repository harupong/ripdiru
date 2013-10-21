# ripdiru

ripdiru rips and saves Radiru\*Radiru, NHK netradio, in MP3.  Metadata such as title and duration are automatically embeded to MP3s with the data fetched from the supposedly unofficial API.

## Installation

Add this line to your application's Gemfile:

    gem 'ripdiru'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ripdiru

## Usage

Set up environment variables:

- `RIPDIRU_OUTDIR`: Output directory to save ripped MP3 files. Defaults to `~/Music/Radiru`
- `RIPDIRU_BITRATE`: Bitrate for re-encoded MP3. 48kbps by default (Radiko upstram is served around 48kbps)

Run `ripdiru <station-id>` and the recording will start/stop automatically.  Currently supported stations are as follows:

- `NHK1`: Radio-1st(ラジオ第1)
- `NHK2`: Radio-2nd(ラジオ第2)
- `FM`: NHK-FM

## Requirements

Recommended to install the following:

- Ruby 1.9
- Nokogiri
- rtmpdump
- ffmpeg

## Special thanks to

- [matchy2 (MACHIDA Hideki)](https://github.com/matchy2), for the shell script to rip Radiru\*Radiru https://gist.github.com/5310409.git

- [miyagawa (Tatsuhiko Miyagawa)](https://github.com/miyagawa/), for [ripdiko](https://github.com/miyagawa/ripdiko), from which I shamelessly copy-pasted most of the code.

- [riocampos](https://github.com/riocampos/), for all the research published on the [blog](http://d.hatena.ne.jp/riocampos+tech/)

## Author

Haruo Nakayama (@harupong)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
