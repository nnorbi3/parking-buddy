//
//  ButtonUtil.swift
//  ParkingBuddy
//
//  Created by Norbert Nagy on 2021. 09. 22..
//

import Foundation
import UIKit

class ButtonUtil {
    
    public static func addResetViewButtonToView(view: UIView, action: (UIButton) -> Void) {
        let resetLocationButton = UIButton()
        resetLocationButton.addTarget(self, action: #selector(action), for: .touchUpInside)
        resetLocationButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        resetLocationButton.layer.shadowRadius = 5
        resetLocationButton.layer.shadowOpacity = 0.3
       
        resetLocationButton.isOpaque = true
        resetLocationButton.setBackgroundImage(UIImage(named: "location_icon"), for: .normal)

        view.addSubview(resetLocationButton)
        resetLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resetLocationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            resetLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130),
            resetLocationButton.widthAnchor.constraint(equalToConstant: 30),
            resetLocationButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
}
