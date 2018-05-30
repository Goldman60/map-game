# MAP GAME

Designed and written by AJ Fite <afite@calpoly.edu> for CSC436 Spring 2018

This is the early alpha of Map Game, a Pokemon Go/Old Foursquare/Ingress style augmented reality game.  The player travels around the real world checking in at locations to gain points and ownership over virtual locations corresponding to real world points of interest.

## Known Issues and Caveats

* Most stuff isn't really working at the moment.  You can navigate the UI, sign in, and see some basic API interactivity, but beyond that its pretty non-functional
* Only Google based authentication is available
* The app is targeted at iOS 10.3 as that is what my test device is capable of.
* Some of the screens have improper (or no) constraints as I need to flesh out the data to see where the interface needs more or less space in real world usage
* Due to a time crunch created by my Networks class I'm not quite as far along as I'd like to be

## APIs Used

* iOS GPS
* MapKit
* CoreLocation
* Firebase Authentication
* Firebase Database
* Firebase Filestore
* Firebase Geofire
* iOS Camera
