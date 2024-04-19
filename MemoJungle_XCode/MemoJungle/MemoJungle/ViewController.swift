//
//  ViewController.swift
//  MemoJungle
//
//  Created by Finaritra Randriamitandrina on 02/04/2024.
//

import UIKit

import AVFoundation //Framework music
import AVKit

class ViewController: UIViewController {
    
    static var audioPlayer: AVAudioPlayer? //son d'ambiance du jeu

    //Fonction pour recuperer le nom de la musique et la lancer
    func playAudio() {
        guard let url = Bundle.main.url(forResource: "musique_ambiance_memory", withExtension: "mp3") else { return }
        
        do {
            // Initialiser le lecteur audio avec le contenu de l'URL
            ViewController.audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // Définir le nombre de boucles sur -1 pour une lecture en boucle infinie
            ViewController.audioPlayer?.numberOfLoops = -1
            
            // Commencer la lecture
            ViewController.audioPlayer?.play()
            
        } catch let error {//En cas d'erreur lors de la récupération du fichier audio
            print(error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playAudio() //Appeller musique d'ambiance

        // Créer une UIImageView pour l'image de fond
        let backgroundImageView = UIImageView(image: UIImage(named: "fond_partie.png"))
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        //Ajoute UIImageView à la vue principale
        self.view.addSubview(backgroundImageView)

        // Ajouter des contraintes pour que l'image de fond remplisse toute la vue principale
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Envoyer la UIImageView à l'arrière pour s'assurer qu'elle est sous tous les autres éléments
        self.view.sendSubviewToBack(backgroundImageView)
    }
}
