//
//  mag_loader.swift
//  GDS-Examiner
//
//  Created by Devin Michael Atkin on 2024-11-06.
//

import Foundation

// Define a structure to hold shape data
struct Shape {
    var layer: String
    var coordinates: [Float]
}

// Function to parse .mag file and return all shapes
func loadMagFile(at fileName: String) -> [Shape] {
    var shapes: [Shape] = []
    
    do {
        // Read the contents of the file
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "mag") else {
            print("File not found in bundle")
            return shapes
        }
        let fileContents = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        
        // Split content into lines and parse each line
        let lines = fileContents.components(separatedBy: .newlines)
        for line in lines {
            // Assume a simple format for each line, such as:
            // "layer_name x_start y_start x_end y_end"
            let components = line.split(separator: " ")
            guard components.count >= 5 else { continue }
            
            let layer = String(components[0])
            if let xStart = Float(components[1]),
               let yStart = Float(components[2]),
               let xEnd = Float(components[3]),
               let yEnd = Float(components[4]) {
                let shape = Shape(layer: layer, coordinates: [xStart/10, yStart/10, xEnd/10, yEnd/10])
                shapes.append(shape)
            }
        }
    } catch {
        print("Error reading file: \(error)")
    }
    
    return shapes
}

func normalizeShapesCoordinates(shapes: [Shape], low: Float, high: Float) -> [Shape] {
    // Find the minimum and maximum coordinates across all shapes
    let allX = shapes.flatMap { [$0.coordinates[0], $0.coordinates[2]] }
    let allY = shapes.flatMap { [$0.coordinates[1], $0.coordinates[3]] }
    
    guard let minX = allX.min(), let maxX = allX.max(), let minY = allY.min(), let maxY = allY.max() else {
        print("Error: Unable to determine min/max values.")
        return shapes
    }
    
    // Define a closure for normalization
    func normalize(value: Float, min: Float, max: Float) -> Float {
        return ((value - min) / (max - min)) * (high - low) + low
    }
    
    // Create a new array with normalized coordinates
    let normalizedShapes = shapes.map { shape in
        let normalizedCoordinates = [
            normalize(value: shape.coordinates[0], min: minX, max: maxX),
            normalize(value: shape.coordinates[1], min: minY, max: maxY),
            normalize(value: shape.coordinates[2], min: minX, max: maxX),
            normalize(value: shape.coordinates[3], min: minY, max: maxY)
        ]
        return Shape(layer: shape.layer, coordinates: normalizedCoordinates)
    }
    
    return normalizedShapes
}
