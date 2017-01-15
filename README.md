# newfoto - a tvOS learning project

![newfoto icon](https://raw.githubusercontent.com/rawshooter/newfoto/master/newfoto/icons/AppleTV-Icon-App-Small-400x240.png)


# Purpose
NewFoto is a intuitive way to browse your photos on your tvOS device. Since Apple Photos does not include zooming or insights to more metadata this application provides you more information about your photo library.

# History

## Update 15.01.2017
* Polished image transitions with much more natural navigation after extensive AB testing: based on speed or preview image position
* Fixed accidental hollow images and other UI glitches including standard rotation

## Update 14.01.2017
* Fixes an issue when swiping the image to the next or last image and then going into zoom mode. Lesson learned: Always set the UIDynamic objects on right position before enabling the engine. 

## Update 23.12.2016
* Swiping to Next and Previous image possible
* usage of UIDynamics for better UXP

## Update 14.12.2016
* Added first glossy effects for collection view


## Update 13.12.2016
* Added better thumnbail loading for async collection list with no flickering
* Photos can be clicked in detail view to cycle through album as a ring 

## Update 11.12.2016
* Now support for Album collection
* 3D Tilting in Album Browser
* PHImageRequestOptions added with handler to get better image quality and network requests. huge improvement

## Update 03.12.2016

* NEW: 84 Hires Demo Photos can be added via the settings tab to current fotostream. Extremly useful when testing with the tvOS simulator

## Update 02.12.2016


* Browse over current Fotostream
* Support Double Tap without clicking
* Zoom by factor 2x
* Pan over zoomed Image
* Supports Image bounds in zoomed Image

