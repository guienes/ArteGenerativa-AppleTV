//
//  SetListTableViewController.swift
//  MetalGenerativeArt
//
//  Created by Lia Kassardjian on 09/07/20.
//  Copyright © 2020 Lia Kassardjian. All rights reserved.
//

import UIKit

enum Sets: String {
    case mandelbrot = "Mandelbrot Set"
    case julia = "Julia Set"
    case some = "Some Set"
}

class SetListTableViewController: UITableViewController {
    
    var sets: [Sets] = [.mandelbrot, .julia, .some]
    var selectedRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "segue", sender: nil)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? GenerativeArtViewController else { return }
        viewController.set = sets[selectedRow]
    }

}
