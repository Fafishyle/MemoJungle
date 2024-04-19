//
//  MemoryViewController.swift
//  MemoJungle
//
//  Created by Finaritra Randriamitandrina on 02/04/2024.
//

import UIKit
import AVFoundation

//Set à l'animation avec la brillance des deux cartes lorsqu'on trouve une paire
extension UIView {
    func addShineAnimation() {
        isUserInteractionEnabled = false //Pour faire en sorte que la carte ne soit pas cliquable lors de l'animation
        
        // Création d'un calque pour l'effet de brillance
        let shineLayer = CALayer()
                shineLayer.frame = bounds
                shineLayer.backgroundColor = UIColor.clear.cgColor
                layer.addSublayer(shineLayer)
                
                // Définition des couleurs de l'arc-en-ciel
                let rainbowColors: [CGColor] = [
                    UIColor.red.withAlphaComponent(0.5).cgColor,
                    UIColor.orange.withAlphaComponent(0.5).cgColor,
                    UIColor.yellow.withAlphaComponent(0.5).cgColor,
                    UIColor.green.withAlphaComponent(0.5).cgColor,
                    UIColor.blue.withAlphaComponent(0.5).cgColor,
                    UIColor.purple.withAlphaComponent(0.5).cgColor
                ]
                
                // Création d'une animation de transition entre les couleurs pour l'effet d'arc-en-ciel
                let shineAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
                shineAnimation.values = rainbowColors
                shineAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
                shineAnimation.duration = 0.5 // Durée de l'animation en secondes
                shineAnimation.repeatCount = 2
                
                // Ajout de l'animation au calque de brillance
                shineLayer.add(shineAnimation, forKey: "rainbowShineAnimation")
                
                // Création d'une animation de zoom in et zoom out
                let zoomAnimation = CABasicAnimation(keyPath: "transform.scale")
                zoomAnimation.fromValue = 1.0 // Taille normale
                zoomAnimation.toValue = 1.2 // Taille zoomée
                zoomAnimation.duration = 1 // Durée de l'animation en secondes
                zoomAnimation.repeatCount = 1
                zoomAnimation.autoreverses = true
                
                // Ajout de l'animation de zoom au bouton
                layer.add(zoomAnimation, forKey: "zoomAnimation")
    }
}


class MemoryViewController: UIViewController {
    
    var viewController: ViewController? //permet d'avoir accès aux fonctions définies dans le fichier ViewController.swift
    
    var niveau =  1 //niveau de jeu par défaut
    
    var tempsPartie = 1 //temps de jeu par défaut
    
    var timer: Timer? //utiliser pour le timer du jeu
    
    var nomsCarte : [String] = [ //tableau avec le nom des cartes à disposition
        "coccinelle.jpg",
        "elephant.jpg",
        "mouche.jpg",
        "panda.jpg",
        "mouche2.jpg",
        "mouche3.jpg",
        "punaise.jpg",
        "tigre.jpg",
        "singe.jpg",
        "scarabee.jpg",
        "araignee.jpg",
        "coccinelle.jpg",
    ]
    
    var dosCarte = "dos_carte_finale.png" //nom de la carte du dos du jeu
    
    var carteATrouver = 6 //Le nombre de paires à découvrir
    
    @IBOutlet weak var timerLabel: UILabel! //Label qui affiche le temps restant
    
    @IBOutlet var Cartes: [UIButton]! //collection des cartes
    
    var tabImagePosition : [Int: String] = [:]//tableau vide qui est remplit au fur et a mesure lors de placement des cartes du jeu
    //où la clé est la position et la valeur est le nom de l'image à cette position
    
    var nbClic = 0 //correspond au nombre de clic réalisé
    
    var nomImageClic : [Int:String] = [:] //correspond aux cartes cliquées lors de la partie
    
    var tmpTag : Int = 0 //Pour sauvegarder le tag de la 1ere carte cliquée
    
    var tmpButton : UIButton? = nil //Pour sauvegarder le bouton de la 1ere carte cliquée
    
    var tabPaireNonTrouve : [Int: String] = [:] //Tableau contenant les cartes du jeu non trouvé
    //où la clé est la position et la valeur est le nom de l'image à cette position
    
    var soundWinGame: AVAudioPlayer? //Son quand on a gagné la partie
    
    var soundLooseGame: AVAudioPlayer? //Son quand on a perdu la partie
    
    var soundFindGoodPair: AVAudioPlayer? //Son quand on a trouvé une paire
    
    //Fonction pour mettre le son de victoire de partie
    func playSoundWinGame() {
        guard let url = Bundle.main.url(forResource: "victoire", withExtension: "mp3") else { return }
        
        do {
            // Initialiser le lecteur audio avec le contenu de l'URL
            soundWinGame = try AVAudioPlayer(contentsOf: url)
            
            // Commencer la lecture
            soundWinGame?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //Fonction pour mettre le son quand on a perdu de partie
    func playSoundLooseGame() {
        guard let url = Bundle.main.url(forResource: "echec", withExtension: "mp3") else { return }
        
        do {
            // Initialiser le lecteur audio avec le contenu de l'URL
            soundLooseGame = try AVAudioPlayer(contentsOf: url)
            
            // Commencer la lecture
            soundLooseGame?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //Fonction pour mettre le son quand on a trouvé une paire
    func playSoundPairFind() {
        guard let url = Bundle.main.url(forResource: "paire_trouve", withExtension: "mp3") else { return }
        
        do {
            // Initialiser le lecteur audio avec le contenu de l'URL
            soundFindGoodPair = try AVAudioPlayer(contentsOf: url)
            
            // Commencer la lecture
            soundFindGoodPair?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    
    //Fonction pour commencer le minuteur de la partie
    func startGame() {
        // Commencez le minuteur pour suivre le temps restant
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        let minutes = tempsPartie / 60
        let secondes = tempsPartie % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, secondes)//Format souhaité pour l'afficher sur l'écran
    }
    
    //Permet de mettre à jour le minuteur de la partie
    @objc func updateTime() {
        if tempsPartie > 0 {
            tempsPartie -= 1
            let minutes = tempsPartie / 60
            let secondes = tempsPartie % 60
            timerLabel.text = String(format: "%02d:%02d", minutes, secondes)
        } else { //Le temps est écoulé
            //On arret le minuteur
            timer?.invalidate()
            timer = nil
            
            //Met la musique quand on perd la partie
            playSoundLooseGame()
            
            //On remet le parametre enabled à false pour toutes les cartes non trouvé
            for (key, _) in self.tabImagePosition {
                if let button = self.Cartes.first(where: { $0.tag == key }) {
                    button.isEnabled = false
                }
            }
            
            //Affiche le message de fin de partie
            let alert = UIAlertController(title: "Perdu", message: "Oups le temps est écoulé. Vous avez perdu.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                print("The \"OK\" alert occured.")
                //Revenir à la page avec les niveaux
                self.navigationController?.popViewController(animated: true)
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Action qui se passe quand on clique sur un bouton qui contient une carte
    @IBAction func clic(_ sender: UIButton) {
        sender.isEnabled = false // le bouton n'est plus cliquable
        
        let imageTag = sender.tag //On recupere le tag du bouton cliqué
        
        let image = tabImagePosition[imageTag] //On récupère le nom de la carte cliquée
        
        //On retourne la carte avec une animation
        UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            sender.setImage(UIImage(named: image!), for: .normal)
        })
        
        nomImageClic[imageTag] = image //On sauvegarde la carte cliqué dans ce tableau
        nbClic += 1 // on incrémente le nombre de clic réalisé
        
        if nbClic == 1 { //On sauvegarde les informations du 1er clic (tag, bouton)
            tmpTag = imageTag
            tmpButton = sender
        }
        else if nbClic == 2 {
            //On met enabled à tous les boutons des cartes non trouvé à false
            //Pour éviter d'avoir plus que 2 cartes retournées sur le plateau de jeu
            for (key, _) in tabPaireNonTrouve {
                if let button = Cartes.first(where: { $0.tag == key }) {
                    button.isEnabled = false
                }
            }
            
            if nomImageClic[tmpTag] == nomImageClic[imageTag] { //Les 2 cartes sont identiques
                
                //Animation arc-en-ciel de la première carte cliquée
                tmpButton!.imageView?.addShineAnimation()
                //Animation arc-en-ciel de la carte actuelle cliquée
                sender.imageView?.addShineAnimation()
                
                //Met la musique quand on trouve une paire
                if carteATrouver != 0 {
                    playSoundPairFind()
                }
                
                carteATrouver -= 1 //On décremente le nombre de paire de cartes à trouver
                
                //On enlève dans tabPaireNonTrouve l'image trouvé
                for (key, value) in tabPaireNonTrouve {
                    if value == image {
                        tabPaireNonTrouve[key] = nil
                    }
                    
                    //Cool-down : empêche de cliquer sur les autres cartes
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) {
                        timer in
                        //On remet le parametre enabled a true pour toutes les cartes non trouve
                        for (key, _) in self.tabPaireNonTrouve {
                            if let button = self.Cartes.first(where: { $0.tag == key }) {
                                button.isEnabled = true
                            }
                        }
                    }
                }
                
                print(tabPaireNonTrouve)
                
                if carteATrouver == 0 && tempsPartie != 0{ //Partie finie
                    //On arrete le minuteur
                    timer?.invalidate()
                    timer = nil
                    
                    //On met la musique quand on gagne la partie
                    playSoundWinGame()
                    
                    //On affiche le message de fin de partie
                    let alert = UIAlertController(title: "Bravo", message: "Vous avez gagné.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        print("The \"OK\" alert occured.")
                        //Revenir à la page avec les niveaux
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else { //Si les deux cartes retournées sont différentes
                
                // Retourner les deux cartes face cachée après un court délai
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) {
                    timer in
                    //Animation pour les retourner
                    UIView.transition(with: self.tmpButton!, duration: 0.5, options: .transitionFlipFromRight, animations: {
                        self.tmpButton?.setImage(UIImage(named: self.dosCarte), for: .normal)
                    })
                    UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromRight, animations: {
                        sender.setImage(UIImage(named: self.dosCarte), for: .normal)
                    })
                    //On remet le parametre enabled a true pour toutes les cartes non trouvé
                    for (key, _) in self.tabPaireNonTrouve {
                        if let button = self.Cartes.first(where: { $0.tag == key }) {
                            button.isEnabled = true
                        }
                    }
                }
            }
            
            nbClic = 0 //On remet a zero
            nomImageClic = [:] //On remet le tableau a vide
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        viewController = ViewController() //On récupère notre ViewController
        
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
        backgroundImageView.alpha = 0.5 // Réglez l'opacité à 50%
        
        // Envoyer la UIImageView à l'arrière pour s'assurer qu'elle est sous tous les autres éléments
        self.view.sendSubviewToBack(backgroundImageView)
        
        //Gestion de niveaux
        // niveau 1 facile
        // niveau 2 moyen
        // niveau 3 difficile
        
        switch niveau {
        case 1: tempsPartie = 240 //4 minutes
        case 2: tempsPartie = 180 //3 minutes
        case 3: tempsPartie = 120 //2 minutes
        case 4: tempsPartie = 30 //30 secondes
        default : break
        }
        
        //Espace pour choisir les images ainsi que leurs positions
        var nomCarteCopie = nomsCarte
        
        var tabPosition: [Int] = Array(1...12) //tableau des postions des cartes
        
        for _ in 1...6 {
            let image = nomCarteCopie.randomElement()!
            nomCarteCopie.removeAll { $0 == image }// Enlever l'élément spécifié du tableau pour éviter de le retirer le tour suivant
            
            let position1 = tabPosition.randomElement()!
            tabPosition.removeAll { $0 == position1 } // Supprime l'élément sélectionné
            
            let position2 = tabPosition.randomElement()!
            tabPosition.removeAll { $0 == position2 } // Supprime l'élément sélectionné
            
            // Ajouter les paires clé-valeur au dictionnaire
            tabImagePosition[position1] = image
            tabImagePosition[position2] = image
            
        }//fin de la boucle pour ajouter les images
        
        for carte in Cartes { //initialisation des cartes en affichant le dos des cartes
            carte.setImage(UIImage(named: dosCarte), for: .normal)
        }
        
        startGame()//lance le minuteur
        
        tabPaireNonTrouve = tabImagePosition //On copie les valeurs de TabImagePosition dans tabPaireNonTrouve pour garder intact TabImagePosition
    }
}
