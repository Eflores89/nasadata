# nasadata 

*An R interface to access some of NASA's API's*

## :construction: **Still under *heavy* construction** :construction:

## Imagery and Assets API :satellite: :earth_americas: 

NASA's Imagery and Assets API can be found [here](https://api.nasa.gov/api.html).

**More explaining to do ...**


## EONET Webservice :pushpin: :rotating_light:

The official documentation of NASA's Earth Observatory Nature Event Tracker (EONET) Webservice v2.1 can be found [here](http://eonet.sci.gsfc.nasa.gov/docs/v2.1). 

In NASA's words: 
> The Earth Observatory Natural Event Tracker (EONET) is a prototype web service with the goal of:
  1. providing a curated source of continuously updated natural event metadata;
  2. providing a service that links those natural events to thematically-related web service-enabled image sources (e.g., via WMS, WMTS, etc.).

I really recommend getting to know the service through the official documentation before using **nasadata**. 

In short, this packages reads from the webservice, parses the data and returns it in various **R** friendly formats (data.frames and lists). It can thus be used for a range of applications. 

## Further documentation

* A more complete vignette of this package, with examples, can be found [here](http://enelmargen.org/nasadata/)
* [NASA Github Portal](https://github.com/nasa)
