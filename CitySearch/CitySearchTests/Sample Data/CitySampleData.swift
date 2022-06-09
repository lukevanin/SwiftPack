import Foundation

@testable import CitySearch

extension City {
    
    ///
    /// The fictional town of Foo Ville, Antarctica
    ///
    /// id: 0
    /// name: fooville
    /// country: AA
    /// coordinate: lon: 180, lat: 90
    ///
    static func foovilleAA() -> City {
        City(
            _id: 0,
            country: "AA",
            name: "fooville",
            coord: Coordinate(lon: 180, lat: -90)
        )
    }
    
    ///
    /// The fictional city of Footopia, Antarctica
    ///
    /// id: 1
    /// name: footopia
    /// country: AA
    /// coordinate: lon: 180, lat: 90
    ///
    static func footopiaAA() -> City {
        City(
            _id: 1,
            country: "AA",
            name: "footopia",
            coord: Coordinate(lon: 180, lat: -90)
        )
    }
    
    ///
    /// The beautiful town of Wellington, South Africa
    ///
    /// id: 3359510
    /// name: Wellington
    /// country: ZA
    /// longitude: 19.0112
    /// latitude: 33.639809
    ///
    static func wellingtonZA() -> City {
        City(
            _id: 3_359_510,
            country: "ZA",
            name: "Wellington",
            coord: Coordinate(
                lon: 19.0112,
                lat: -33.639809
            )
        )
    }
}
