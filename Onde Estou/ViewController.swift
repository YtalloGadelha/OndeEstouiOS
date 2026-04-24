//
//  ViewController.swift
//  Onde Estou
//
//  Created by Ytallo on 15/07/19.
//  Copyright © 2019 CursoiOS. All rights reserved.
//

import UIKit
import MapKit

@available(iOS 13.0, *)
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    var gerenciadorLocalizacao = CLLocationManager()
    
    @IBOutlet weak var velocidadeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var enderecoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        configuraGerenciadorLocalizacao()
        setupConstraints()
        
    }
    
    func configuraGerenciadorLocalizacao(){
        
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
        
    }
    
    func setupConstraints() {
        
        self.navBar.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.mapa.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.navBar)
        self.view.addSubview(self.infoView)
        self.view.addSubview(self.mapa)
        
        self.navBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        self.navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.navBar.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.10).isActive = true
        
        self.infoView.topAnchor.constraint(equalTo: self.navBar.bottomAnchor, constant: -30).isActive = true
        self.infoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.infoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.infoView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.20).isActive = true
        
        self.mapa.topAnchor.constraint(equalTo: self.infoView.bottomAnchor, constant: 4).isActive = true
        self.mapa.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.mapa.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.mapa.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let localizacaoUsuario = locations.last!
        let longitude = localizacaoUsuario.coordinate.longitude
        let latitude = localizacaoUsuario.coordinate.latitude
        
        self.longitudeLabel.text = String(longitude)
        self.latitudeLabel.text = String(latitude)
        
        if localizacaoUsuario.speed > 0{
            self.velocidadeLabel.text = String(localizacaoUsuario.speed)
        }
        
        let localizacao: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let deltaLatitude: CLLocationDegrees = 0.01
        let deltaLongitude: CLLocationDegrees = 0.01
        let areaExibicao: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: deltaLatitude, longitudeDelta: deltaLongitude)
        
        let regiao: MKCoordinateRegion = MKCoordinateRegion(center: localizacao, span: areaExibicao)
        mapa.setRegion(regiao, animated: true)
        
        CLGeocoder().reverseGeocodeLocation(localizacaoUsuario) { (detalhesLocal, erro) in
            
            if erro == nil{
                
                if let dadosLocal = detalhesLocal?.first{
                    
                    //rua
                    var thoroughfare = ""
                    if dadosLocal.thoroughfare != nil{
                        thoroughfare = dadosLocal.thoroughfare!
                    }
                    
                    //número
                    var subThoroughfare = ""
                    if dadosLocal.subThoroughfare != nil{
                        subThoroughfare = dadosLocal.subThoroughfare!
                    }
                    
                    //cidade
                    var locality = ""
                    if dadosLocal.locality != nil{
                        locality = dadosLocal.locality!
                    }
                    
                    //bairro
                    var subLocality = ""
                    if dadosLocal.subLocality != nil{
                        subLocality = dadosLocal.subLocality!
                    }
                    
                    //CEP
                    var postalCode = ""
                    if dadosLocal.postalCode != nil{
                        postalCode = dadosLocal.postalCode!
                    }
                    
                    //país
                    var country = ""
                    if dadosLocal.country != nil{
                        country = dadosLocal.country!
                    }
                    
                    //área administrativa
                    var administrativeArea = ""
                    if dadosLocal.administrativeArea != nil{
                        administrativeArea = dadosLocal.administrativeArea!
                    }
                    
                    var subadministrativeArea = ""
                    if dadosLocal.subAdministrativeArea != nil{
                        subadministrativeArea = dadosLocal.subAdministrativeArea!
                    }
                    
                    self.enderecoLabel.text = thoroughfare + " - "
                                                        + subThoroughfare + " / "
                                                        + locality + " / "
                                                        + country
                    
                }
                
            }else{
                print(erro as Any)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse{
            
            let alertaController = UIAlertController(title: "Permissão de Localização", message: "Necessário permissão para acesso à sua localização!!! Por favor habilite.", preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir configurações", style: .default) { (alertaConfiguracoes) in
                
                if let configuracoes = NSURL(string: UIApplication.openSettingsURLString){
                    
                    UIApplication.shared.open(configuracoes as URL)
                }
            }
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            present(alertaController, animated: true, completion: nil)
        }
    }
}
