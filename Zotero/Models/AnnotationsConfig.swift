//
//  AnnotationsConfig.swift
//  Zotero
//
//  Created by Michal Rentka on 12/05/2020.
//  Copyright © 2020 Corporation for Digital Scholarship. All rights reserved.
//

import UIKit

struct AnnotationsConfig {
    static let sidebarWidth: CGFloat = 250
    static let previewSize: CGSize = createPreviewSize()

    private static func createPreviewSize() -> CGSize {
        let scale = UIScreen.main.scale
        let size = sidebarWidth * scale
        return CGSize(width: size, height: size)
    }
}
