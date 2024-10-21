//
//  Copyright © 2024 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import XCTest
import SwiftImageReadWrite

@testable import QRCode

private let outputFolder = try! testResultsContainer.subfolder(with: "pixel-inset-tests")
private let imagesFolder = try! outputFolder.subfolder(with: "images")
private let imageStore = ImageOutput(imagesFolder)
private var markdown = ""

final class QRCodePixelInsetTests: XCTestCase {

	override class func setUp() {
		markdown += "# Pixel insets\n\n"
	}

	// Called when the test _class_ completes
	override class func tearDown() {
		// Write out the markdown
		try! outputFolder.write(markdown, to: "pixel-inset-tests.md", encoding: .utf8)
	}

	func testPixelInsets() throws {

		// Available inset generators
		let insetGenerators = QRCode.PixelInset.generators.map { $0.Create() }
		// Available pixel generators
		let pixelNames = QRCodePixelShapeFactory.shared.availableGeneratorNames

		let doc = try QRCode.Document(utf8String: "Inset tests")

		try pixelNames.forEach { pixelName in

			// Make on and off pixel generators
			let pt = try QRCodePixelShapeFactory.shared.named(pixelName)
			let ptoff = try QRCodePixelShapeFactory.shared.named(pixelName)

			doc.design.shape.onPixels = pt
			doc.design.style.onPixels = .solid(1, 0, 0)
			doc.design.shape.offPixels = ptoff
			doc.design.style.offPixels = .solid(0, 0, 1)

			markdown += "## \(pt.name)\n\n"
			if pt.supportsSettingValue(forKey: QRCode.SettingsKey.insetGeneratorName) {
				markdown += "  * supports inset generator\n"
			}
			else {
				markdown += "  * does not support inset generators\n"
			}
			if pt.supportsSettingValue(forKey: QRCode.SettingsKey.insetFraction) {
				markdown += "  * supports inset fraction\n"
			}
			else {
				markdown += "  * does not support inset fractions\n"
			}

			markdown += "\n\n"

			markdown += "| Name |  0.0  |  0.2  |  0.4  |  0.6  |\n"
			markdown += "|------|-------|-------|-------|-------|\n"

			try insetGenerators.forEach { generator in
				_ = pt.setSettingValue(generator.name, forKey: QRCode.SettingsKey.insetGeneratorName)
				_ = ptoff.setSettingValue(generator.name, forKey: QRCode.SettingsKey.insetGeneratorName)
				markdown += "| \(generator.name)"

				try [0.0, 0.2, 0.4, 0.6].forEach { inset in
					_ = pt.setSettingValue(inset, forKey: QRCode.SettingsKey.insetFraction)
					_ = ptoff.setSettingValue(inset, forKey: QRCode.SettingsKey.insetFraction)

					markdown += " | "

					let im = try doc.cgImage(dimension: 400)

					//try XCTValidateSingleQRCode(im, expectedText: "Inset tests")

					let filename = "pixel-inset-\(pt.name)-\(generator.name)-\(inset).png"
					let png = try im.representation.png()
					let link = try imageStore.store(png, filename: filename)
					markdown += "<a href=\"\(link)\"><img src=\"\(link)\" width=\"400\" /></a> &nbsp;"
				}
				markdown += " |\n"
			}

			markdown += "\n\n"
		}
	}
}