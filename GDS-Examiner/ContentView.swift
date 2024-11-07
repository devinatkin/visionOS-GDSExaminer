//
//  ContentView.swift
//  GDS-Examiner
//
//  Created by Devin Michael Atkin on 2024-11-06.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        let MagShapes = loadMagFile(at: "inverter")
        let NormShapes = normalizeShapesCoordinates(shapes: MagShapes, low: 0, high: 10)
        RealityView { content in
            addMagShapes(to: content, shapeElements: NormShapes)
        }
    }

    func addMagShapes(to content: RealityViewContent, shapeElements: [Shape]) {
        
        for shapeElement in shapeElements {
            let width = shapeElement.coordinates[2] - shapeElement.coordinates[0]
            let height = shapeElement.coordinates[3] - shapeElement.coordinates[1]
            let gds_block = ModelEntity(mesh: .generateBox(width: width, height: height, depth: 1))
            
            gds_block.position.z = shapeElement.coordinates[0]
            gds_block.position.y = shapeElement.coordinates[1]

            content.add(gds_block)
        }
    }
    
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
