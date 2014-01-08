PMCIOSBeaconEmitter
===================
**A demo app to show you how to become your iPhone in a iBeacon**


## Notes

- The UUID if fixed to work with Estimote's iBeacons. You can change this easily.
- You can set major an minor properties to advertise.
- All main logic is created as singleton this way you can include it in your project easily.

### Background advertising

Beacon region advertising doesn't work in the background in iOS 7, even with the `bluetooth-peripheral` mode set in `Info.plist`.

## Contact

[Pedro Muñoz](http://github.com/pmunoz08) ([@pmunoz08](https://twitter.com/pmunoz08))

## Licence

PMCIOSBeaconEmitter is available under the MIT licence. See the LICENCE file for more info.