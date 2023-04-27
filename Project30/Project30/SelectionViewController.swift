//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
	var dirty = false
    var original: UIImage?
    var smolItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

		// load all the JPEGs into our array
		let fm = FileManager.default
        guard let path = Bundle.main.resourcePath else { return }

        if let tempItems = try? fm.contentsOfDirectory(atPath: path) {
            for item in tempItems {
                if item.range(of: "Large") != nil {
                    self.items.append(item)
                }
            }
        }
        
        if smolItems.isEmpty{
            for i in 0..<items.count{
                
                // for each item
                let currentImage = items[i]
                // use the thumb photo
                let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
                guard let type = Bundle.main.path(forResource: imageRootName, ofType: nil) else{return}
                original = UIImage(contentsOfFile: type)
                
                let imageName = UUID().uuidString
                let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
                
                if let jpegData = original?.jpegData(compressionQuality: 0.8){
                    try? jpegData.write(to: imagePath)
                    smolItems.append(imagePath.path)
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }


	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let currentImage = smolItems[indexPath.row % smolItems.count]
        original = UIImage(contentsOfFile: currentImage)
        
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
        
        let rounded = renderer.image { ctx in
            ctx.cgContext.addEllipse(in: renderRect)
            ctx.cgContext.clip()
            original?.draw(in: renderRect)
            
        }
        
        cell.imageView?.image = rounded
        
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        cell.imageView?.layer.shadowRadius = 10
        cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath // give exact shadow by using UIBezierPath
        
        let imageTapped = items[indexPath.row % items.count]
        let defaults = UserDefaults.standard
        cell.textLabel?.text = "\(defaults.integer(forKey: imageTapped))"
        
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ImageViewController()
        vc.image = items[indexPath.row % items.count]
        vc.imagePath = smolItems[indexPath.row % smolItems.count]
        
        vc.owner = self
        
        dirty = false
        
        navigationController!.pushViewController(vc, animated: true)
    }
}
