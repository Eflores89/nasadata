# nasadata 

:earth_americas: :earth_africa:

inegiR is a package designed to interact with the two API's of INEGI (Oficial statistics agency of Mexico). Because these work with JSON or XML formating, this package is essentially a wrapper for jsonlite, XML and some tidy plyr transformations. 

The package uses two main functions: 

 - `serie_inegi()` - Used to query a data series from INEGI. 
 - `denue_inegi()` - Used to query the information in the DENUE database.
 
The remaining functions serve as elegant wrappers to perform common tasks. For example `inflacion_general()` to download monthly inflation data. Other functions make transformations easier on-the-fly, such as `YoY()` to calculate a percentage change from a year ago (year-over-year). 


---


# Example 1: downloading a data series 



## Install

To get the CRAN version (as of Nov-2015):


{% highlight r %}
install.packages(inegiR)
library(inegiR)
{% endhighlight %}

To download dev version on github, using devtools:


{% highlight r %}
#install.packages("devtools")
library(devtools)
install_github("Eflores89/inegiR")
  #dependiencies: zoo, XML, plyr, jsonlite
library(inegiR)
{% endhighlight %}


## Download data

There are roughly two ways to download data series: the "general" and the "short" way (provided there is a wrapper function available). 

In the first case, the function parses a URL provided by the user. All the URL's for each data series can be found in the INEGI [development site](http://www.inegi.org.mx/desarrolladores/indicadores/apiindicadores.aspx). You must also sign up for an API token in that same site with your email. 


Let us save the imaginary token:

{% highlight r %}
token <- "abc123"
{% endhighlight %}

Now, I wish to find the rate of inflation (which in the case of INEGI is a percent change of the INPC data series).

This is the corresponding URL for INPC data.series:

{% highlight r %}
urlINPC <- "http://www3.inegi.org.mx/sistemas/api/indicadores/v1//Indicador/216064/00000/es/false/xml/"
{% endhighlight %}

JSON format is also accepted and is interchangeable (do not use the "?callback?" sign provided by INEGI's documentation): 

{% highlight r %}
urlINPC2 <- "http://www3.inegi.org.mx/sistemas/api/indicadores/v1//Indicador/216064/00000/es/false/json/"
{% endhighlight %}

Now, we are going to download this data series as a data.frame.


{% highlight r %}
INPC <- serie_inegi(urlINPC, token)

# take a look
tail(INPC)
# Fechas         Valores
# 2014-12-01   116.05900000
# 2015-01-01   115.95400000
# 2015-02-01   116.17400000
# 2015-03-01   116.64700000
# 2015-04-01   116.34500000
# 2015-05-01   115.76400000
{% endhighlight %}

The optional "metadata" parameter in serie_inegi allows us to also download the metadata information from the data series, which includes date of update, units, frequency, etc. 

If "metadata" is set to TRUE, the information is parsed as a list of two elements: the metadata and the data frame. 


{% highlight r %}
INPC_Metadata <- serie_inegi(urlINPC, token, metadata = TRUE)
class(INPC_Metadata)
# [1] "list"
{% endhighlight %}

To access any of these elements, simply use as a list:


{% highlight r %}
# date of last update
INPC_Metadata$MetaData$UltimaActualizacion
[1] "2015/06/09"
{% endhighlight %}


Now that we have the INPC data series, we must apply a year-over-year change. For this we use the handy YoY() function, which let's us choose the amount of periods to compare over (12 if you want year over year for a monthly series): 



{% highlight r %}
Inflation <- YoY(INPC$Valores, 
                 lapso = 12, 
                 decimal=FALSE)

# if we want a dataframe, we simply build like this
Inflation_df <- cbind.data.frame(Fechas = INPC$Fechas, 
                                 Inflation = Inflation)

tail(Inflation_df)
# Fechas        Inflation
# 2014-12-01    4.081322
# 2015-01-01    3.065642
# 2015-02-01    3.000266
# 2015-03-01    3.137075
# 2015-04-01    3.062327
# 2015-05-01    2.876643
{% endhighlight %}

This method works for any URL obtained from the INEGI documentation, but for the most used indicators, the package has built-in shortcut wrappers. 


Let us obtain the same data series (inflation) via one of these specified shortcut functions:


{% highlight r %}
Inflation_fast <- inflacion_general(token)
tail(Inflation_fast)
# Fechas        Inflacion
# 2014-12-01    4.081322
# 2015-01-01    3.065642
# 2015-02-01    3.000266
# 2015-03-01    3.137075
# 2015-04-01    3.062327
# 2015-05-01    2.876643
{% endhighlight %}


---


# Example 2: downloading statistics from DENUE

The DENUE is a directory of businesses in Mexico and is accesible by another API within INEGI [here](http://www.inegi.org.mx/desarrolladores/denue/apidenue.aspx). A different API token is used for these queries. 


{% highlight r %}
token_denue <- "abcdef1234"
{% endhighlight %}

To download the businesses in a certain radius, we need a few coordinates. Let's use the ones around Monterrey Mexico's main square: 

{% highlight r %}
latitud_macro<-"25.669194"
longitud_macro<-"-100.309901"
{% endhighlight %}


Now, we download into a data.frame the list of businesses in a 250 meter radius.

{% highlight r %}
NegociosMacro <- denue_inegi(latitud = latitud_macro, 
                             longitud = longitud_macro, 
                             token_denue)
{% endhighlight %}

Let's see only the first rows and columns...

{% highlight r %}
head(NegociosMacro)[,1:2]
#     id                                       Nombre
# 2918696                   ESTACIONAMIENTO GRAN PLAZA
# 2918698             TEATRO DE LA CIUDAD DE MONTERREY
# 2918723                           CONGRESO DE ESTADO
# 2918793               SECRETARIA DE SALUD DEL ESTADO
# 2974150                           BIBLIOTECA CENTRAL
# 2974215      SOTANO RECURSOS HUMANOS Y ADQUISICIONES
{% endhighlight %}

If you would like to change some parameters, this is accepted. For example a 1km radius and only businesses with "Restaurante" in the description.

{% highlight r %}
RestaurantsMacro <- denue_inegi(latitud = latitud_macro, 
                                longitud = longitud_macro, 
                                token_denue, 
                                metros = 1000, 
                                keyword = "Restaurante")
{% endhighlight %}
