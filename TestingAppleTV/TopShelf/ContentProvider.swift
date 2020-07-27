//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Tamara Erlij on 27/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        completionHandler(nil);
    }

}

