import heresdk
import UIKit
import CoreLocation

class HereeSdkController: TapDelegate, LongPressDelegate, CLLocationManagerDelegate {

    private var viewController: HomeViewController//UIViewController
    private var mapView: MapViewLite
    private var mapMarkers = [MapMarkerLite]()
    private var searchEngine: SearchEngine
    private var locationManager = CLLocationManager()
    
    init(viewController: HomeViewController/*UIViewController*/, mapView: MapViewLite) {
        self.viewController = viewController
        self.mapView = mapView
        
        locationManager.delegate = self
        mapView.gestures.tapDelegate = self
        mapView.gestures.longPressDelegate = self
        
        do {
            try searchEngine = SearchEngine()
        } catch let engineInstantiationError {
            fatalError("Failed to initialize SearchEngine. Cause: \(engineInstantiationError)")
        }
        
        requestGPSAuthorization()
        
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
            
        // TODO - CRIAR ICON PARA POSICAO DO USUARIO
        
        let camera = mapView.camera
        camera.setTarget(GeoCoordinates(latitude: locValue.latitude, longitude: locValue.longitude))
        camera.setZoomLevel(14)
    }
/*
    func onGeoCodeButtonClicked() {
        // Search for the location that belongs to an address and show it on the map.
        geocodeAnAddress()
    }
  */

    func getAddressForCoordinates(geoCoordinates: GeoCoordinates) {
        // By default results are localized in EN_US.
        let reverseGeocodingOptions = SearchOptions(languageCode: LanguageCode.ptBr,
                                                    maxItems: 1)
        _ = searchEngine.search(coordinates: geoCoordinates,
                                options: reverseGeocodingOptions,
                                completion: onReverseGeocodingCompleted)
    }
    
    func searchInViewport(queryString: String) {
        clearMap()

        let textQuery = TextQuery(queryString, in: getMapViewGeoBox())
        let searchOptions = SearchOptions(languageCode: LanguageCode.ptBr,
                                          maxItems: 10)
        _ = searchEngine.search(textQuery: textQuery,
                                options: searchOptions,
                                completion: onSearchCompleted)
    }
    
    private func getSuggest(textQuery: String) {
        clear()
        
        let centerGeoCoordinates = getMapViewCenter()
        let autosuggestOptions = SearchOptions(languageCode: LanguageCode.ptBr,
                                               maxItems: 5)

        _ = searchEngine.suggest(textQuery: TextQuery(textQuery, near: centerGeoCoordinates),
                                 options: autosuggestOptions,
                                 completion: onSearchCompleted)
    }

    // Completion handler to receive search results.
    func onSearchCompleted(error: SearchError?, items: [Place]?) {
        if let searchError = error {
            showDialog(title: "Search", message: "Error: \(searchError)")
            return
        }

        // If error is nil, it is guaranteed that the items will not be nil.
        showDialog(title: "Search address.",
                   message: "Found  \(items!.count) results.")

        // Add a new marker for each search result on map.
        /*
        for searchResult in items! {
            let metadata = Metadata()
            metadata.setCustomValue(key: "key_search_result", value: SearchResultMetadata(searchResult))
            addPoiMapMarker(geoCoordinates: searchResult.coordinates, metadata: metadata)
        }*/
    }

    // Completion handler to receive auto suggestion results.
    func onSearchCompleted(error: SearchError?, items: [Suggestion]?) {
        if let searchError = error {
            print("Autosuggest Error: \(searchError)")
            return
        }

        // If error is nil, it is guaranteed that the items will not be nil.
        print("Autosuggest: Found \(items!.count) result(s).")

        var results: [String] = []
        for autosuggestResult in items! {
            results.append(autosuggestResult.title)
        }
        viewController.addressList = results
        
        /*
        for autosuggestResult in items! {
            var addressText = "Not a place."
            if let place = autosuggestResult.place {
                addressText = place.address.addressText
            }
            print("Autosuggest result: \(autosuggestResult.title), addressText: \(addressText)")
        }
        */
    }

    /*
    public func geocodeAnAddress() {
        // Set map near to expected location.
        let geoCoordinates = GeoCoordinates(latitude: 52.537931, longitude: 13.384914)
        mapView.camera.setTarget(geoCoordinates)
        mapView.camera.setZoomLevel(14)

        let streetName = "Invalidenstraße 116, Berlin"
        geocodeAddressAtLocation(queryString: streetName, geoCoordinates: geoCoordinates)
    }
   */

    private func geocodeAddressAtLocation(queryString: String, geoCoordinates: GeoCoordinates) {
        clearMap()

        let query = AddressQuery(queryString, near: geoCoordinates)
        let geocodingOptions = SearchOptions(languageCode: LanguageCode.ptBr,
                                             maxItems: 25)
        _ = searchEngine.search(addressQuery: query,
                                options: geocodingOptions,
                                completion: onGeocodingCompleted)
    }

    // Completion handler to receive geocoding results.
    func onGeocodingCompleted(error: SearchError?, items: [Place]?) {
        if let searchError = error {
            showDialog(title: "Geocoding", message: "Error: \(searchError)")
            return
        }

        /*
        // If error is nil, it is guaranteed that the items will not be nil.
        for geocodingResult in items! {
            let geoCoordinates = geocodingResult.coordinates
            let address = geocodingResult.address
            let locationDetails = address.addressText
                + ". Coordinates: \(geoCoordinates.latitude)"
                + ", \(geoCoordinates.longitude)"

            showDialog(title: "Geocoding - Locations in viewport for 'Invalidenstraße 116, Berlin':",
                       message: "Found: \(items!.count) result(s): \(locationDetails)")

            self.addPoiMapMarker(geoCoordinates: geoCoordinates)
        }
       */
    }

    // Conforming to TapDelegate protocol.
    func onTap(origin: Point2D) {
        // TODO: ???
        mapView.pickMapItems(at: origin, radius: 2, completion: onMapItemsPicked)
    }

    // Completion handler to pick itmes from map.
    func onMapItemsPicked(pickedMapItems: PickMapItemsResultLite?) {
        guard let topmostMapMarker = pickedMapItems?.topmostMarker else {
            return
        }

        if let searchResultMetadata =
            topmostMapMarker.metadata?.getCustomValue(key: "key_search_result") as? SearchResultMetadata {

            let title = searchResultMetadata.searchResult.title
            let vicinity = searchResultMetadata.searchResult.address.addressText
            showDialog(title: "Picked Search Result",
                       message: "Title: \(title), Vicinity: \(vicinity)")
            return
        }

        showDialog(title: "Map Marker picked at: ",
                   message: "\(topmostMapMarker.coordinates.latitude), \(topmostMapMarker.coordinates.longitude)")
    }

    // Conforming to LongPressDelegate protocol.
    func onLongPress(state: GestureState, origin: Point2D) {
        // TODO: Pegar endereco e definir no label de busca
        
        if (state == .begin) {
            let geoCoordinates = mapView.camera.viewToGeoCoordinates(viewCoordinates: origin)
            addPoiMapMarker(geoCoordinates: geoCoordinates)
            getAddressForCoordinates(geoCoordinates: geoCoordinates)
        }
    }

    // Completion handler to receive reverse geocoding results.
    func onReverseGeocodingCompleted(error: SearchError?, items: [Place]?) {
        if let searchError = error {
            showDialog(title: "ReverseGeocodingError", message: "Error: \(searchError)")
            return
        }

        // If error is nil, it is guaranteed that the place list will not be empty.
        let addressText = items!.first!.address.addressText
        showDialog(title: "Reverse geocoded address:", message: addressText)
    }

    private func addPoiMapMarker(geoCoordinates: GeoCoordinates) {
        let mapMarker = createPoiMapMarker(geoCoordinates: geoCoordinates)
        mapView.mapScene.addMapMarker(mapMarker)
        mapMarkers.append(mapMarker)
    }

    private func addPoiMapMarker(geoCoordinates: GeoCoordinates, metadata: Metadata) {
        let mapMarker = createPoiMapMarker(geoCoordinates: geoCoordinates)
        mapMarker.metadata = metadata
        mapView.mapScene.addMapMarker(mapMarker)
        mapMarkers.append(mapMarker)
    }

    private func createPoiMapMarker(geoCoordinates: GeoCoordinates) -> MapMarkerLite {
        let mapMarker = MapMarkerLite(at: geoCoordinates)
        let image = UIImage(named: "poi")
        let mapImage = MapImageLite(image!)
        let mapMarkerImageStyle = MapMarkerImageStyleLite()
        mapMarkerImageStyle.setAnchorPoint(Anchor2D(horizontal: 0.5, vertical: 1))
        mapMarker.addImage(mapImage!, style: mapMarkerImageStyle)
        return mapMarker
    }

    private func getMapViewCenter() -> GeoCoordinates {
        return mapView.camera.getTarget()
    }

    private func getMapViewGeoBox() -> GeoBox {
        return mapView.camera.boundingBox
    }

    private func showDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertController, animated: true, completion: nil)
    }

    private func clearMap() {
        for mapMarker in mapMarkers {
            mapView.mapScene.removeMapMarker(mapMarker)
        }

        mapMarkers.removeAll()
    }
    
    
    func requestGPSAuthorization() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        print("Location update: " + location!.coordinate.latitude.debugDescription)
        
        // TODO - CRIAR ICON PARA POSICAO DO USUARIO
        //mapView.camera.setTarget(GeoCoordinates(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    
    private class SearchResultMetadata : CustomMetadataValue {

           var searchResult: Place

           init(_ searchResult: Place) {
               self.searchResult = searchResult
           }

           func getTag() -> String {
               return "SearchResult Metadata"
           }
       }
}
