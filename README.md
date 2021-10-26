# GoSquared's Flag Icon Set

Here you'll find all the files available in our [flag icon set][1] and the tools we use to generate the downloadable file.

If you have any comments, corrections or additions then let us know with an issue or pull request

## Coming soon

 * More flags
 * Flag sprites along with accompanying CSS/SCSS/SASS and tools to generate them

## License and Usage

MIT, see [LICENSE.txt](https://github.com/gosquared/flags/blob/master/LICENSE.txt)

## Building your own version of the icon set

If you want to build your own version of this flag set, with any additions or modifications, just edit the files in `src/flags`. Each flag has its own folder, and inside each folder there is one PNG file for each size of the flag. Also in each folder is a file called `code`, which contains the ISO-3166-2 country code for the flag.

To generate the full set, just run `make` (you may want to run `make clean` if you have removed any flags). To speed up generation, try running `make -jN` where `N` is the number of CPU cores you have (e.g. `make -j4` on a quad-core machine)

### Tools required for generating the set

 * GNU Make
 * imagemagick
 * png2icns (provided on Ubuntu by `icnsutils`, or [via sourceforge](http://icns.sourceforge.net/))


[1]: https://www.gosquared.com/resources/flag-icons
