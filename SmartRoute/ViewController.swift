//
//  ViewController.swift
//  SmartRoute
//
//  Created by zz on 08.02.2022.
//  Copyright © 2022 Vadim Vitkovskiy. All rights reserved.
//

import UIKit
import MapKit
import  CoreLocation


class ViewController: UIViewController {
    let mapView = MKMapView()
    var annotations = [MKAnnotation]()
    let addRoutesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить маршрут", for: .normal)
        button.titleLabel?.font = UIFont(name: "Gill Sans", size: 20)
        button.setTitleColor(.black, for: .normal)
        button.alpha = 0.7
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton: UIButton = {
           let button = UIButton(type: .system)
            button.setImage(UIImage(named: "route"), for: .normal)
            button.tintColor = .red
           button.translatesAutoresizingMaskIntoConstraints = false
        return button
       }()
    
    let resetButton: UIButton = {
              let button = UIButton(type: .system)
                button.setTitle("Удалить", for: .normal)
                button.titleLabel?.font = UIFont(name: "Gill Sans", size: 20)
                button.setTitleColor(.systemRed, for: .normal)
                 button.alpha = 0.7
              button.translatesAutoresizingMaskIntoConstraints = false
           return button
          }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        mapView.delegate = self
        routeButton.isHidden = true
        resetButton.isHidden = true
        addTargets()
    }
}
extension ViewController {
    
    private func setupConstraints() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
         mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
         mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
         mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [addRoutesButton, resetButton])
        stackView.axis = .horizontal
        stackView.spacing = 50
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.addSubview(routeButton)
        routeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        routeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        routeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        routeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        routeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 300).isActive = true
    }
    private func addTargets() {
        addRoutesButton.addTarget(self, action: #selector(addRoute), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(route), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(ResetRoute), for: .touchUpInside)
        
    }
    
    private func addDirectional(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        let startPlaceMark = MKPlacemark(coordinate: startCoordinate)
        let endPlacemark = MKPlacemark(coordinate: endCoordinate)
        request.source = MKMapItem(placemark: startPlaceMark)
        request.destination = MKMapItem(placemark: endPlacemark)
        request.transportType = .any
        request.requestsAlternateRoutes = true
        let directional = MKDirections(request: request)
        directional.calculate { (response, error) in
            
            if error == nil {
                var minRoutes = response?.routes[0]
                for route in response!.routes {
                    if route.distance < minRoutes!.distance {
                        minRoutes = route
                    }
                    self.mapView.addOverlay(minRoutes?.polyline as! MKOverlay)
                }
            } else {
                self.showAlert(title: "Ошибка", message: "Ошибка сервера", searchTextField: false, buttonTitle: "Ок") { (_) in
                    print(error!.localizedDescription)
                    return
                }
            }
        }
    }
    @objc private func addRoute() {
        showAlert(title: "Поиск места", message: "Введите адресс места", searchTextField: true, buttonTitle: "Добавить") { (text) -> () in
            CoordinateService.shared.findCoordinate(placeSearch: text) { (coordinates, error) in
                if error == nil {
                    let annotationMark = MKPointAnnotation()
                    annotationMark.title = text
                    annotationMark.coordinate = coordinates!
                    self.annotations.append(annotationMark)
                    self.mapView.showAnnotations(self.annotations, animated: true)
                    if self.annotations.count > 2 {
                        self.routeButton.isHidden = false
                        self.resetButton.isHidden = false
                    }
                } else {
                    self.showAlert(title: "Ошибка", message: "Ошибка сервера", searchTextField: false, buttonTitle: "Ок") { (_) in
                        print(" ")
                        return
                    }
                }
            }
        }
    }
    @objc private func ResetRoute() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        annotations = [MKPointAnnotation]()
        resetButton.isHidden = true
        routeButton.isHidden = true
    }
    
    @objc private func route() {
        for index in 0...annotations.count - 2 {
            addDirectional(startCoordinate: annotations[index].coordinate, endCoordinate: annotations[index + 1].coordinate)
        }
        mapView.showAnnotations(annotations, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemGreen
        return renderer 
    }
    
    
}
