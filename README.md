# MAP GAME

Designed and written by AJ Fite <afite@calpoly.edu> for CSC436 Spring 2018

This is the early alpha of Map Game, a Pokemon Go/Old Foursquare/Ingress style augmented reality game.  The player travels around the real world checking in at locations to gain points and ownership over virtual locations corresponding to real world points of interest.

## Known Issues and Caveats

* Most stuff isn't really working at the moment.  You can navigate the UI, sign in, and see some basic API interactivity, but beyond that its pretty non-functional
* Only Google based authentication is available
* The app is targeted at iOS 10.3 as that is what my test device is capable of.
* Some of the screens have improper (or no) constraints as I need to flesh out the data to see where the interface needs more or less space in real world usage
* Due to a time crunch created by my Networks class I'm not quite as far along as I'd like to be
* Game only has functional data for the Western Continental United States (All states to the west of and including Montana, Wyoming, Colorado, and New Mexico)

## APIs Used

* iOS GPS
* MapKit
* CoreLocation
* Firebase Authentication
* Firebase Database
* Firebase Filestore
* Firebase Geofire
* iOS Camera

## Locations

Locations are exported from [OpenStreetMaps data dumps](https://download.geofabrik.de/north-america/us-west.html) using their [osmosis client](https://wiki.openstreetmap.org/wiki/Osmosis) and the following command:

```bash
osmosis --read-pbf file="us-west-latest.osm.pbf" --nkv keyValueList="amenity.townhall,amenity.library,amenity.school,amenity.university,amenity.hospital,amenity.fountain,amenity.theatre,amenity.animal_shelter,amenity.clock,amenity.courthouse,amenity.fire_station,amenity.post_office,amenity.police,amenity.ranger_station,natural.peak,natural.volcano,natural.beach,natural.cave_entrance" --tf accept-nodes name=* --wx "filtered.xml"
```

[The XML output of this command can be found here](https://projects.ajfite.com/csc436-finalproject/basedata.xml)

This XML file was then run through a simple PHP script:

```php
<?php
ini_set('memory_limit', '3G'); // or you could use 1G

$xml = simplexml_load_file("basedata.xml");
$json = json_encode($xml);

echo $json;
?>
```

Creating the output JSON for Swift to parse (since it was easier than learning XML parsing in Swift) and then store in FireBase.  [The end result can be found here](https://projects.ajfite.com/csc436-finalproject/basedata.json).
