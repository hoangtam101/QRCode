//
//  QRCodePixelShapeHorizontal.swift
//
//  Created by Darren Ford on 17/11/21.
//  Copyright © 2022 Darren Ford. All rights reserved.
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

import CoreGraphics
import Foundation

public extension QRCode.PixelShape {
	@objc(QRCodePixelShapeHorizontal) class Horizontal: NSObject, QRCodePixelShapeGenerator {

		static public let Name: String = "horizontal"
		static public func Create(_ settings: [String: Any]?) -> QRCodePixelShapeGenerator {
			let inset = DoubleValue(settings?["inset", default: 0]) ?? 0
			let radius = DoubleValue(settings?["cornerRadiusFraction"]) ?? 0
			return QRCode.PixelShape.Horizontal(inset: inset, cornerRadiusFraction: radius)
		}

		public func copyShape() -> QRCodePixelShapeGenerator {
			return Horizontal(
				inset: self.inset,
				cornerRadiusFraction: self.cornerRadiusFraction
			)
		}

		var inset: CGFloat
		var cornerRadiusFraction: CGFloat
		@objc public init(inset: CGFloat = 0, cornerRadiusFraction: CGFloat = 0) {
			self.inset = inset
			self.cornerRadiusFraction = cornerRadiusFraction.clamped(to: 0...1)
			super.init()
		}

		public func onPath(size: CGSize, data: QRCode, isTemplate: Bool = false) -> CGPath {
			return self.generatePath(size: size, data: data, isOn: true, isTemplate: isTemplate)
		}

		public func offPath(size: CGSize, data: QRCode, isTemplate: Bool = false) -> CGPath {
			return self.generatePath(size: size, data: data, isOn: false, isTemplate: isTemplate)
		}

		private func generatePath(size: CGSize, data: QRCode, isOn: Bool, isTemplate: Bool) -> CGPath {
			let dx = size.width / CGFloat(data.pixelSize)
			let dy = size.height / CGFloat(data.pixelSize)
			let dm = min(dx, dy)

			let xoff = (size.width - (CGFloat(data.pixelSize) * dm)) / 2.0
			let yoff = (size.height - (CGFloat(data.pixelSize) * dm)) / 2.0

			let path = CGMutablePath()

			// Mask out the QR patterns
			let currentData = isTemplate ? data.current : data.current.maskingQREyes(inverted: !isOn)

			for row in 1 ..< data.pixelSize - 1 {
				var activeRect: CGRect?

				for col in 1 ..< data.pixelSize - 1 {
					if currentData[row, col] == false {
						if let r = activeRect {
							// We had an active rect. Close it.
							let ri = r.insetBy(dx: self.inset, dy: self.inset)
							let cr = (ri.height / 2.0) * self.cornerRadiusFraction
							path.addPath(CGPath(roundedRect: ri, cornerWidth: cr, cornerHeight: cr, transform: nil))
						}
						activeRect = nil
					}
					else if activeRect != nil {
						// We are still going...
						activeRect?.size.width += dm
					}
					else {
						// Starting a new rect
						activeRect = CGRect(x: xoff + (CGFloat(col) * dm), y: yoff + (CGFloat(row) * dm), width: dm, height: dm)
					}
				}

				if let r = activeRect {
					// Close the rect
					let ri = r.insetBy(dx: self.inset, dy: self.inset)
					let cr = (ri.height / 2.0) * self.cornerRadiusFraction
					path.addPath(CGPath(roundedRect: ri, cornerWidth: cr, cornerHeight: cr, transform: nil))
				}
			}
			return path
		}
	}
}

// MARK: - Settings

public extension QRCode.PixelShape.Horizontal {
	/// Does the shape generator support setting values for a particular key?
	@objc func supportsSettingValue(forKey key: String) -> Bool {
		return key == "inset" || key == "cornerRadiusFraction"
	}

	/// Returns a storable representation of the shape handler
	@objc func settings() -> [String : Any] {
		return [
			"inset": self.inset,
			"cornerRadiusFraction": self.cornerRadiusFraction
		]
	}

	/// Set a configuration value for a particular setting string
	@objc func setSettingValue(_ value: Any?, forKey key: String) -> Bool {
		if key == "inset" {
			guard let v = value else {
				self.inset = 0
				return true
			}
			guard let v = DoubleValue(v) else { return false }
			self.inset = v
			return true
		}
		else if key == "cornerRadiusFraction" {
			guard let v = value else {
				self.cornerRadiusFraction = 0
				return true
			}
			guard let v = DoubleValue(v) else { return false }
			self.cornerRadiusFraction = v
			return true
		}
		return false
	}
}