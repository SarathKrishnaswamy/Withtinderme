//
//  MapViewController.swift
//  Life Hope
//
//  Created by Gowthaman P on 11/11/20.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

/// This is used to get the selected address with lat, long, city and state need to be send.
protocol GetSelectedAddress: class {
    func fetchTheAddress(address:String, lat:Double, long:Double, city:String, state:String)
}

/// This class is used for fetching user current location,latitude and longitude drag and search option to select location and option to add landmark
class MapViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    var currentLocation:CLLocation!
    let marker = GMSMarker()
    var isFirstTimeCalled = false
    @IBOutlet weak var addressLbl: UILabel!
    var lat = 0.0
    var long = 0.0
    var locality = ""
    var state = ""
    @IBOutlet weak var landmarkTxtFld: UITextField!
    weak var delegate: GetSelectedAddress?
    @IBOutlet var saveBtn:UIButton!
    var isFromBookingDetails = false
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.mapView?.isMyLocationEnabled = true
        
        hideKeyboardWhenTappedAround()
        
        saveBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        saveBtn.layer.cornerRadius = 5.0
        saveBtn.clipsToBounds = true
        self.mapView.bringSubviewToFront(saveBtn)
        
        // Add a button to the view.
          func makeButton() {
            let btnLaunchAc = UIButton(frame: CGRect(x: 5, y: 150, width: 300, height: 35))
            btnLaunchAc.backgroundColor = .blue
            btnLaunchAc.setTitle("Launch autocomplete", for: .normal)
            btnLaunchAc.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
            self.view.addSubview(btnLaunchAc)
          }
        
       // makeButton()
    }
    
    /// When auto complete button tapped it will slect the location with pin has been selected
    @IBAction func autocompleteTapped(sender:UIButton) {
        autocompleteClicked(sender)
    }
    
    /// Present the Autocomplete view controller when the button is pressed.
      @objc func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                    UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue) |
                                                    UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.name.rawValue))
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
      }

    /// Update the location manager with latitude and longitude
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint(locations[0].coordinate)
        if !isFirstTimeCalled {
            currentLocation = locations[0]
            //Save current location lattitude and longitude
            self.lat = currentLocation.coordinate.latitude
            self.long = currentLocation.coordinate.longitude
            
            //self.returnPostionOfMapView(mapView: mapView, coordinate: currentLocation.coordinate)
            let camera = GMSCameraPosition.camera(withLatitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude, zoom: 16.0)
            mapView.animate(to: camera)
            self.returnPostionOfMapView(mapView: mapView, coordinate: currentLocation.coordinate)

            isFirstTimeCalled = true
        }
    }
    
    
    /// Set the position of the map using gmaps view
    /// - Parameters:
    ///   - mapView: Set the map view here to pin the current location
    ///   - coordinate: get the coordinated from the location
    func returnPostionOfMapView(mapView:GMSMapView,coordinate:CLLocationCoordinate2D){
        let geocoder = GMSGeocoder()
        let latitute = coordinate.latitude
        let longitude = coordinate.longitude
        let position = CLLocationCoordinate2DMake(latitute, longitude)
        geocoder.reverseGeocodeCoordinate(position) { response , error in
            if error != nil {
                //print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
            }else {
                let result = response?.results()?.first
                let address = result?.lines?.reduce("") { $0 == "" ? $1 : $0 + ", " + $1 }
                self.addressLbl.text = address
                self.locality = result?.locality ?? ""
                self.state = result?.administrativeArea ?? ""
                
                // Creates a marker in the center of the map.
                DispatchQueue.main.async {
                    
                    self.marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    self.marker.title = "Current Location"
                    self.marker.snippet = address
                    self.marker.map = mapView
                    let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 16.0)
                    self.mapView.animate(to: camera)
                }
            }
        }
    }
    
    
    /// Return the lat and long using the map view
    /// - Parameters:
    ///   - mapView: Set the map view here
    ///   - coordinate: Get the all location lat and long
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.lat = coordinate.latitude
        self.long = coordinate.longitude
        self.returnPostionOfMapView(mapView: mapView, coordinate: coordinate)
    }
   
    /// Resign the keyboard here
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        return newString.count < 31 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
    
    /// Save button tapped to fetch the address with lat, long and city, state
    @IBAction func saveButtonTapped(sender:UIButton) {
        var finalAddressStr = ""
        if landmarkTxtFld.text != "" {
            finalAddressStr = "\(addressLbl.text ?? ""), \(landmarkTxtFld.text ?? "")"
        }else{
            finalAddressStr = "\(addressLbl.text ?? "")"
        }
        self.delegate?.fetchTheAddress(address: finalAddressStr, lat: self.lat, long: self.long, city: self.locality, state: self.state)
        self.dismiss(animated: true, completion: nil)
      /*  if isFromBookingDetails {
            //Pop to Profile VC
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: BookingDetailsTableViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }else {
            //Pop to Profile VC
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: ProfileTableViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }*/
        
    }
}
extension MapViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
    /// Open the gmaps view controller as bottom sheet to select the address
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    addressLbl.text = place.formattedAddress ?? ""
    DispatchQueue.main.async {
        self.lat = place.coordinate.latitude
        self.long = place.coordinate.longitude
        self.marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.marker.title = "Current Location"
        self.marker.snippet = place.formattedAddress
        self.marker.map = self.mapView
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0)
        self.mapView.animate(to: camera)
        //Fetch city and address
        self.returnPostionOfMapView(mapView: self.mapView, coordinate: place.coordinate)

    }
    dismiss(animated: true, completion: nil)
  }

    /// Handle the error here with auto complete map checking
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  /// User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

}
