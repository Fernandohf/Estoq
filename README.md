# <a href=https://github.com/Fernandohf/Estoq/releases><img src=https://raw.githubusercontent.com/Fernandohf/Estoq/master/Media/icon/icon_edited.png height=40></a> Estoq

[![](https://img.shields.io/static/v1?label=Flutter&message=Estoq&color=blue&logo=flutter)](https://www.flutter.com/)
[![GitHub issues](https://img.shields.io/github/issues/Fernandohf/Estoq)](https://github.com/Fernandohf/Estoq/issues)
[![GitHub license](https://img.shields.io/github/license/Fernandohf/Estoq)](https://github.com/Fernandohf/Estoq/blob/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/Fernandohf/Estoq/releases)](https://img.shields.io/github/release/Fernandohf/Estoq/releases/)


A simple app to control itens in inventory by scanning their barcode. Always make sure that your physical and digital inventory are in agreement. This project is powered by [Flutter](https://www.flutter.com).

## Features

- Scanner with camera
- Manual input
- Support USB scanner
- Export to `.txt`
- Share `.txt` file
- Languages: **pt-br**

## Download

The apk can be downloaded in the [release tab](https://github.com/Fernandohf/Estoq/releases).

Even though the app is written in flutter, the binaries are only tested and provided for **Android**. Feel free to compile it from the source and build the iOS app.

## Screenshots

|                                                               Home                                                               |                                                  Itens view                                                  |                                            Barcode scanner                                            |                                               Manual input                                                |
| :------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------: |
| ![Home screen](https://github.com/Fernandohf/Estoq/blob/master/Media/screenshots/01_home.png?raw=true "App home screen picture") | ![Session screen](https://github.com/Fernandohf/Estoq/blob/master/Media/screenshots/02_session.png?raw=true) | ![Scanner](https://github.com/Fernandohf/Estoq/blob/master/Media/screenshots/03_scanner.png?raw=true) | ![Manual input](https://github.com/Fernandohf/Estoq/blob/master/Media/screenshots/04_manual.png?raw=true) |

## Build Instructions

- Install flutter and all is dependencies following the [online documentation](https://flutter.dev/docs)
- Run `flutter pub get` to download all the packages on `pubspec.yaml`
- Run `flutter build apk` to build the apk
