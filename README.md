Introduction
============

For the CHAI project I wanted to look whether there were trains in our study area. Moreover I was curious about two data sources:

-   The Open Government Data (OGD) Platform of India <https://data.gov.in/>

-   Openstreetmap <https://www.openstreetmap.org/>

I moreover saw this blog article <http://curiousanalytics.blogspot.com.es/2015/04/indian-railways-network-using-r.html>

In this README I'll explain where I got the data I decided to use, and which problems I still have.

Getting and preparing the trains timetable
==========================================

I used a different source than curiousanalytics. I used this train timetable from the OGD Platform of India: <https://data.gov.in/catalog/indian-railways-train-time-table-0> I tried to download the data from the API using the `ogdindiar` package <https://github.com/steadyfish/ogdindiar> but I got an error message from the server so I downloaded the data by hand. I then loaded it using the code in R\_code/getting\_train\_timetable.R

The data look like this:

| trainNo    | trainName          |    islno| stationCode   | stationName   |  arrivalTime|  departureTime|  distance| sourceStationCode | sourceStationName | destStationCode | destStationName |  hourDeparture| numDeparture |
|:-----------|:-------------------|--------:|:--------------|:--------------|------------:|--------------:|---------:|:------------------|:------------------|:----------------|:----------------|--------------:|:-------------|
| 00851      | BNC SUVIDHA SPL    |        1| BBS           | BHUBANESWAR   |           0S|     22H 50M 0S|         0| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             22| 22H 50M 0S   |
| 00851      | BNC SUVIDHA SPL    |        2| BAM           | BRAHMAPUR     |    1H 10M 0S|      1H 12M 0S|       166| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |              1| 1H 12M 0S    |
| 00851      | BNC SUVIDHA SPL    |        3| VSKP          | VISAKHAPATNAM |    5H 10M 0S|      5H 30M 0S|       443| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |              5| 5H 30M 0S    |
| 00851      | BNC SUVIDHA SPL    |        4| BZA           | VIJAYAWADA JN |   11H 10M 0S|     11H 20M 0S|       793| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             11| 11H 20M 0S   |
| 00851      | BNC SUVIDHA SPL    |        5| RU            | RENIGUNTA JN  |   16H 42M 0S|     16H 52M 0S|      1169| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             16| 16H 52M 0S   |
| 00851      | BNC SUVIDHA SPL    |        6| JTJ           | JOLARPETTAI   |   20H 35M 0S|     20H 37M 0S|      1367| BBS               | BHUBANESWAR       | BNC             | BANGALORE CANT  |             20| 20H 37M 0S   |
| Now, how t | o get geographical |  coordin| ates for each | station?      |             |               |          |                   |                   |                 |                 |               |              |

Getting the coordinates for all stations
========================================

Google Maps info
----------------

I first used the same approach as curiousanalyics: querying Google Maps via the `geocode` function of the `ggmap` package for getting coordinates for each station name. One can see the code used for this at the beginning of R\_code/getting\_coordinates.R

After doing this I only had geographical coordinates for about 40% of the train stations.

Openstreetmap info
------------------

Then I decided to get all train stations nodes from Openstreetmap. I downloaded the osm.pbf file for India from <http://download.geofabrik.de/asia/india.html> I filtered only the "railway=station" from this file using osmosis. The script is in osm\_data/osmosis\_script.txt. The osm.pbf file is not there because it was too big.

I parsed the OSM XML file using the code in osm\_data/reading\_osm\_file.R Here maybe I could have made better use of the xml2 package and also of the osmar package but somehow I found it faster to write this code.

The data look like this:

| timestamp           | id       | version | uid     | user     | changeset |       lat|       lon| name      | nameJa                                                   |
|:--------------------|:---------|:--------|:--------|:---------|:----------|---------:|---------:|:----------|:---------------------------------------------------------|
| 2015-04-24 17:43:53 | 30518292 | 6       | 2831076 | Rakesh   | 30459200  |  19.35059|  72.84663| Naigaon   | NA                                                       |
| 2015-02-12 16:30:46 | 30518297 | 6       | 445671  | flierfy  | 28799056  |  19.31090|  72.85251| NA        | NA                                                       |
| 2014-09-25 00:22:57 | 30518361 | 5       | 1859494 | Jacob    | 25655940  |  19.29811|  72.98410| NA        | NA                                                       |
| 2014-05-18 10:38:31 | 30519068 | 7       | 123364  | Tronikon | 22404159  |  18.09183|  75.41796| Kurduvadi | NA                                                       |
| 2015-11-14 08:31:35 | 30519417 | 12      | 2480327 | etajin   | 35301836  |  19.21842|  73.08744| Dombivli  | <U+30C9><U+30FC><U+30F3><U+30D3><U+30F4><U+30EA><U+30FC> |
| 2013-02-06 10:40:08 | 30519559 | 10      | 1306    | PlaneMad | 14931873  |  19.07835|  73.08833| Taloje    | NA                                                       |

I gave priority to info I got from Google Maps but for the remaining ones I looked for close matches for names in the OSM data. I defined closes matches as names whose difference measured by the `stringdist` function of the `stringdist` package was 0 or 1. It is a bad solution because clearly doing this I'm giving wrong coordinates to some stations.

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

I've read many forums in order to understand Openstreetmap, so thank you to all the people that asked and answered questions on these forums!
