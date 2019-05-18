//
//  ViewController.swift
//  nubank
//
//  Created by Arthur Rocha on 12/05/19.
//  Copyright © 2019 Arthur Rocha. All rights reserved.
//

import UIKit

struct Tab {
    var image: UIImage
    var title: String
}

struct Menu {
    var image: UIImage
    var title: String
    var description: String
}

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var currentState: State = .closed
    private var centerYInitial: CGFloat = 0
    private var collectionCenterY: CGFloat = 0
    
    var tabs: [Tab] = [
        Tab(image: #imageLiteral(resourceName: "person_add"), title: "Indicar amigos"),
        Tab(image: #imageLiteral(resourceName: "chat_bubble"), title: "Cobrar"),
        Tab(image: #imageLiteral(resourceName: "arrow_downward"), title: "Depositar"),
        Tab(image: #imageLiteral(resourceName: "arrow_upward"), title: "Transferir"),
        Tab(image: #imageLiteral(resourceName: "lock"), title: "Bloquear cartão")
    ]
    
    var menus: [Menu] = [
        Menu(image: #imageLiteral(resourceName: "help"), title: "Me ajuda", description: ""),
        Menu(image: #imageLiteral(resourceName: "person"), title: "Perfil", description: "Nome de preferência, telefone, e-mail"),
        Menu(image: #imageLiteral(resourceName: "credit_card-1"), title: "Configurar cartão", description: ""),
        Menu(image: #imageLiteral(resourceName: "smartphone"), title: "Configurações do app", description: "")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 45
        arrowImageView.tintColor = .white
        arrowImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(arrowTapped)))
        addPanGesture(view: cardView)
        view.bringSubviewToFront(cardView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        centerYInitial = cardView.center.y
        collectionCenterY = collectionView.center.y
    }
    
    private func addPanGesture(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let cardView = sender.view!
        let translation = sender.translation(in: view)
        switch sender.state {
        case .began:
            switch currentState {
            case .closed:
                tableView.alpha = 0
                collectionView.alpha = 1
                pageControl.alpha = 1
                arrowImageView.image = #imageLiteral(resourceName: "keyboard_arrow_down")
            case .open :
                tableView.alpha = 1
                collectionView.alpha = 0
                pageControl.alpha = 0
                arrowImageView.image = #imageLiteral(resourceName: "arrow_up")
            }
        case .changed:
            guard centerYInitial < cardView.center.y else {
                cardView.center = CGPoint(x: cardView.center.x, y: cardView.center.y + translation.y / 20)
                sender.setTranslation(CGPoint.zero, in: view)
                return
            }
            cardView.center = CGPoint(x: cardView.center.x, y: cardView.center.y + translation.y)
            collectionView.center = CGPoint(x: collectionView.center.x, y: collectionView.center.y + translation.y / 20)
            sender.setTranslation(CGPoint.zero, in: view)
            let percentage = (sender.view!.center.y * 100.0 / self.view.center.y) / 100
            collectionView.alpha = 1.0-(percentage-1.0)
            pageControl.alpha = 1.0-(percentage-1.0)
            tableView.alpha = percentage-1.0
            currentState = cardView.center.y + translation.y > centerYInitial * 1.5 ? .open : .closed
        case .ended:
            animation()
            sender.setTranslation(CGPoint.zero, in: view)
        default: break
        }
    }
    
    @objc private func arrowTapped() {
        currentState = currentState.opposite
        animation()
    }
    
    private func animation() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let centerYInitial = self?.centerYInitial, let collectionCenterY = self?.collectionCenterY, let currentState = self?.currentState, let cardView = self?.cardView else { return }
            switch currentState {
            case .closed:
                cardView.center = CGPoint(x: cardView.center.x, y: centerYInitial)
                self?.collectionView.center = CGPoint(x: self?.collectionView.center.x ?? 0, y: collectionCenterY)
                self?.collectionView.alpha = 1
                self?.pageControl.alpha = 1
                self?.tableView.alpha = 0
                self?.arrowImageView.image = #imageLiteral(resourceName: "keyboard_arrow_down")
            case .open:
                cardView.center = CGPoint(x: cardView.center.x, y: collectionCenterY + centerYInitial - 190)
                self?.collectionView.center = CGPoint(x: self?.collectionView.center.x ?? 0, y: collectionCenterY + 20)
                self?.collectionView.alpha = 0
                self?.pageControl.alpha = 0
                self?.tableView.alpha = 1
                self?.arrowImageView.image = #imageLiteral(resourceName: "arrow_up")
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabCell", for: indexPath) as! TabCell
        cell.tabImageView.image = tabs[indexPath.row].image
        cell.tabImageView.tintColor = .white
        cell.tabNameLabel.text = tabs[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
        cell.menuImageView.image = menus[indexPath.row].image
        cell.menuTitleLabel.text = menus[indexPath.row].title
        cell.menuDescription.text = menus[indexPath.row].description
        cell.menuDescription.isHidden = menus[indexPath.row].description.count == 0
        return cell
    }
}

class MenuCell: UITableViewCell {
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuTitleLabel: UILabel!
    @IBOutlet weak var menuDescription: UILabel!
}

class TabCell: UICollectionViewCell {
    @IBOutlet weak var tabImageView: UIImageView!
    @IBOutlet weak var tabNameLabel: UILabel!
}

@IBDesignable class CorneredView: UIView {
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

@IBDesignable
class UIBorderedButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 5 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidht: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidht
        }
    }
    
    @IBInspectable var borderColor: UIColor? = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
