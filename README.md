# MAP GAME

Designed and written by AJ Fite <afite@calpoly.edu> for CSC436 Spring 2018

This is the early beta of Map Game, a Pokemon Go/Old Foursquare/Ingress style augmented reality game.  The player travels around the real world checking in at locations to gain points and ownership over virtual locations corresponding to real world points of interest.

## Known Issues and Caveats

* Only Google based authentication is available
* The app is targeted at iOS 10.3 as that is what my test device is capable of.
* Game only has functional data for the Western Continental United States (All states to the west of and including Montana, Wyoming, Colorado, and New Mexico)
* The Stats and Info page has 2 unimplemented features: A gallery of recent check in images and a list of places the player currently owns.   The data is available in Firebase but I ran up against time constraints and didn't have time to implement the logic to retrieve it.

## Future Improvements

To make the app "production ready" there are a number of things that would need to change

* Currently much of the database management is done in app, this is great for practicing Swift and iOS, but not so great for later updateability or changing the backend.  I'd like to migrate a lot of the current in app database management to be behind a REST API
* Needs more authentication options

## APIs Used

* iOS GPS
* MapKit
* CoreLocation
* Firebase Authentication
* Firebase Database
* Firebase Filestore
* Firebase Geofire
* Firebase Cloud Functions (see the FirebaseCloudFuncs directory)
* iOS Camera

### Location Data

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
