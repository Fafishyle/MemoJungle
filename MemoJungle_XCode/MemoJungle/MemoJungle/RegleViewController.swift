//
//  RegleViewController.swift
//  MemoJungle
//
//  Created by Maude Vivier on 04/04/2024.
//

import UIKit

class RegleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Créer une UIImageView pour l'image de fond
        let backgroundImageView = UIImageView(image: UIImage(named: "fond_partie.png"))
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        // Ajouter la UIImageView à la vue principale
        self.view.addSubview(backgroundImageView)

        // Ajouter des contraintes pour que l'image de fond remplisse toute la vue principale
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        backgroundImageView.alpha = 0.25 // Réglez l'opacité de l'image de fond à 50%

        // Envoyer la UIImageView à l'arrière pour s'assurer qu'elle est sous tous les autres éléments
        self.view.sendSubviewToBack(backgroundImageView)
    }
}
