Train stations and train in India, data issues
==============================================

Introduction
============

For the [CHAI project](http://www.chaiproject.org/) I wanted to look whether there were trains in our study area. Besides, I was curious about two data sources:

-   [The Open Government Data (OGD) Platform of India](https://data.gov.in/)

-   [Openstreetmap](https://www.openstreetmap.org/)

I moreover saw [this blog article](http://curiousanalytics.blogspot.com.es/2015/04/indian-railways-network-using-r.html) from curious analytics.

In this README I'll explain where I got the data I decided to use, and which problems I still have.

Getting and preparing the timetable
===================================

I used a different source than curiousanalytics. I used [this train timetable](https://data.gov.in/catalog/indian-railways-train-time-table-0) from the OGD Platform of India. I tried to download the data from the API using [the `ogdindiar` package](https://github.com/steadyfish/ogdindiar) but I got an error message from the server so I downloaded the data by hand. I then prepared it using the code in [this R code](R_code/getting_train_timetable.R)

The data look like this:

``` r
load("train_data/train_timetable.RData")
knitr::kable(head(timetable))
```

| trainNo | trainName       |  islno| stationCode | stationName   |  arrivalTime|  departureTime|  distance| sourceStationCode | sourceStationName | destStationCode | destStationName |  hourDeparture| numDeparture |
|:--------|:----------------|------:|:------------|:--------------|------------:|--------------:|---------:|:------------------|:------------------|:----------------|:----------------|--------------:|:-------------|
| 00851   | BNC SUVIDHA SPL |      1| BBS         | BHUBANESWAR   |           0S|     22H 50M 0S|         0| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             22| 22H 50M 0S   |
| 00851   | BNC SUVIDHA SPL |      2| BAM         | BRAHMAPUR     |    1H 10M 0S|      1H 12M 0S|       166| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |              1| 1H 12M 0S    |
| 00851   | BNC SUVIDHA SPL |      3| VSKP        | VISAKHAPATNAM |    5H 10M 0S|      5H 30M 0S|       443| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |              5| 5H 30M 0S    |
| 00851   | BNC SUVIDHA SPL |      4| BZA         | VIJAYAWADA JN |   11H 10M 0S|     11H 20M 0S|       793| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             11| 11H 20M 0S   |
| 00851   | BNC SUVIDHA SPL |      5| RU          | RENIGUNTA JN  |   16H 42M 0S|     16H 52M 0S|      1169| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             16| 16H 52M 0S   |
| 00851   | BNC SUVIDHA SPL |      6| JTJ         | JOLARPETTAI   |   20H 35M 0S|     20H 37M 0S|      1367| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             20| 20H 37M 0S   |

It has 69006 rows.

Now, how to get geographical coordinates for each station?

Getting the coordinates for all stations
========================================

Google Maps info
----------------

I first used the same approach as curiousanalyics: querying Google Maps via the `geocode` function of the `ggmap` package for getting coordinates for each station name. One can see the code used for this at the beginning of [this R code](R_code/getting_coordinates.R)

After doing this I only had geographical coordinates for about 40% of the train stations.

Openstreetmap info
------------------

Then I decided to get all train stations nodes from Openstreetmap. I downloaded the osm.pbf file for India from [Geofabrik](http://download.geofabrik.de/asia/india.html). I filtered only the "railway=station" from this file using [osmosis](http://wiki.openstreetmap.org/wiki/Osmosis). The script is [here](osm_data/osmosis_script.txt). The osm.pbf file is not there because it was too big.

I parsed the OSM XML file using [this code](osm_data/reading_osm_file.R). Here maybe I could have made better use of the xml2 package and also of the osmar package but somehow I found it faster to write this code.

The data look like this:

``` r
load("osm_data/OSMdataIndiaStations.RData")
knitr::kable(head(dataIndiaStations))
```

| timestamp           | id       | version | uid     | user     | changeset |       lat|       lon| name      | nameJa                                                   |
|:--------------------|:---------|:--------|:--------|:---------|:----------|---------:|---------:|:----------|:---------------------------------------------------------|
| 2015-04-24 17:43:53 | 30518292 | 6       | 2831076 | Rakesh   | 30459200  |  19.35059|  72.84663| Naigaon   | NA                                                       |
| 2015-02-12 16:30:46 | 30518297 | 6       | 445671  | flierfy  | 28799056  |  19.31090|  72.85251| NA        | NA                                                       |
| 2014-09-25 00:22:57 | 30518361 | 5       | 1859494 | Jacob    | 25655940  |  19.29811|  72.98410| NA        | NA                                                       |
| 2014-05-18 10:38:31 | 30519068 | 7       | 123364  | Tronikon | 22404159  |  18.09183|  75.41796| Kurduvadi | NA                                                       |
| 2015-11-14 08:31:35 | 30519417 | 12      | 2480327 | etajin   | 35301836  |  19.21842|  73.08744| Dombivli  | <U+30C9><U+30FC><U+30F3><U+30D3><U+30F4><U+30EA><U+30FC> |
| 2013-02-06 10:40:08 | 30519559 | 10      | 1306    | PlaneMad | 14931873  |  19.07835|  73.08833| Taloje    | NA                                                       |

It has 5798 rows. So many train stations!

I gave priority to info I got from Google Maps but for the remaining ones I looked for close matches for names in the OSM data. I defined closes matches as names whose difference measured by the `stringdist` function of the `stringdist` package was 0 or 1. It is a bad solution because clearly doing this I'm giving wrong coordinates to some stations.

The whole code is [here](R_code/getting_coordinates.R)

The resulting data look like this:

``` r
load("geo_data/geoInfo.RData")
knitr::kable(head(listNames))
```

| name          |       lat|      long|
|:--------------|---------:|---------:|
| bhubaneswar   |  20.26660|  85.84362|
| brahmapur     |  19.29639|  84.79705|
| visakhapatnam |  18.97497|  84.59354|
| vijayawada    |  15.90394|  80.47232|
| renigunta     |  13.63660|  79.50659|
| jolarpettai   |  12.57284|  78.57753|

It has 4334 rows.

Complementing the timetable
===========================

I added a column for the next station for each station after grouping the data by train id, and I added the coordinates I could identify. I did all this in [this code](R_code/complementing_timetable.R).

The resulting data look like this:

``` r
load("train_data/complemented_timetable.RData")
knitr::kable(head(timetableMap))
```

| trainNo | stationName   |      lat1|     long1| nextStationName |      lat2|     long2| trainName       |  islno| stationCode |  arrivalTime|  departureTime|  distance| sourceStationCode | sourceStationName         | destStationCode | destStationName              |  hourDeparture| numDeparture |
|:--------|:--------------|---------:|---------:|:----------------|---------:|---------:|:----------------|------:|:------------|------------:|--------------:|---------:|:------------------|:--------------------------|:----------------|:-----------------------------|--------------:|:-------------|
| 00851   | bhubaneswar   |  20.26660|  85.84362| brahmapur       |  19.29639|  84.79705| BNC SUVIDHA SPL |      1| BBS         |           0S|     22H 50M 0S|         0| BBS               | BHUBANESWAR railway India | BNC             | BANGALORE CANT railway India |             22| 22H 50M 0S   |
| 00851   | brahmapur     |  19.29639|  84.79705| visakhapatnam   |  18.97497|  84.59354| BNC SUVIDHA SPL |      2| BAM         |    1H 10M 0S|      1H 12M 0S|       166| BBS               | BHUBANESWAR railway India | BNC             | BANGALORE CANT railway India |              1| 1H 12M 0S    |
| 00851   | visakhapatnam |  18.97497|  84.59354| vijayawada      |  15.90394|  80.47232| BNC SUVIDHA SPL |      3| VSKP        |    5H 10M 0S|      5H 30M 0S|       443| BBS               | BHUBANESWAR railway India | BNC             | BANGALORE CANT railway India |              5| 5H 30M 0S    |
| 00851   | vijayawada    |  15.90394|  80.47232| renigunta       |  13.63660|  79.50659| BNC SUVIDHA SPL |      4| BZA         |   11H 10M 0S|     11H 20M 0S|       793| BBS               | BHUBANESWAR railway India | BNC             | BANGALORE CANT railway India |             11| 11H 20M 0S   |
| 00851   | renigunta     |  13.63660|  79.50659| jolarpettai     |  12.57284|  78.57753| BNC SUVIDHA SPL |      5| RU          |   16H 42M 0S|     16H 52M 0S|      1169| BBS               | BHUBANESWAR railway India | BNC             | BANGALORE CANT railway India |             16| 16H 52M 0S   |
| 00851   | jolarpettai   |  12.57284|  78.57753| bangalore cant  |  12.99219|  77.60046| BNC SUVIDHA SPL |      6| JTJ         |   20H 35M 0S|     20H 37M 0S|      1367| BBS               | BHUBANESWAR railway India | BNC             | BANGALORE CANT railway India |             20| 20H 37M 0S   |

It has 69006 rows.

What do to with such a timetable?
=================================

One can draw a map with the course of a chosen train and make a video out of it using the gganimate package.

Here is an example:

\[![ScreenShot](video/07703mapOne)

Remaining issues
================

-   How to get coordinates for all stations?

-   In general, how to optimally deal with different spellings of Indian locations?

-   How should I read OSM files in a more elegant way?

Cool stuff I've learnt
======================

-   Openstreetmap and the OGD platform of India are goldmines.

-   Comparing strings of characters could help with the spelling of Indian locations but also generally in our questionnaire data for dealing with typing errors in the free text areas.

Acknowledgements
================

I've read many forums in order to understand e.g. Openstreetmap, so thank you to all the people that asked and answered questions on these forums! Here is a smiling cat for all of you nice people. :smile\_cat:
