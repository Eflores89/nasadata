# nasadata 

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/nasadata)](http://cran.r-project.org/package=nasadata) ![downloads](http://cranlogs.r-pkg.org/badges/grand-total/nasadata)

*An R interface to access some of NASA's API's*

### Imagery and Assets API :satellite: :earth_americas: 

NASA's Imagery and Assets API can be found [here](https://api.nasa.gov/api.html).

This API intends to open access to pan-sharpened Landsat 8 imagery hosted in Google Earth Engine. The API endpoint returns an image URL and some metadata. This package essentially wraps the call, parses the json and plots the image via `rasterImage`. 

There are still a lot of improvements to be done! Any suggestions are appreciated at twitter: @eflores89 or issues.


### EONET Webservice :pushpin: :rotating_light:

The official documentation of NASA's Earth Observatory Nature Event Tracker (EONET) Webservice v2.1 can be found [here](http://eonet.sci.gsfc.nasa.gov/docs/v2.1). 

In NASA's words: 
> The Earth Observatory Natural Event Tracker (EONET) is a prototype web service with the goal of:
  1. providing a curated source of continuously updated natural event metadata;
  2. providing a service that links those natural events to thematically-related web service-enabled image sources (e.g., via WMS, WMTS, etc.).

I really recommend getting to know the service through the official documentation before using **nasadata**. 

In short, this packages reads from the webservice, parses the data and returns it in various **R** friendly formats (data.frames and lists). It can thus be used for a range of applications. 

## Further documentation

* A more complete vignette of this package, with examples, can be found [here](http://enelmargen.org/nasadata/vignette_v0/)
* [NASA Github Portal](https://github.com/nasa)
* [CRAN](https://cran.r-project.org/web/packages/nasadata/)
