//
//  QRCodeEngine.swift
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

import Foundation

/// A protocol for qr code generation
@objc public protocol QRCodeEngine {
	/// The engine name
	@objc var name: String { get }

	/// Generate QR Code matrix from the specified data
	@objc func generate(data: Data, errorCorrection: QRCode.ErrorCorrection) throws -> BoolMatrix

	/// Generate QR Code matrix from the specified string
	@objc func generate(text: String, errorCorrection: QRCode.ErrorCorrection) throws -> BoolMatrix
}

// An 'empty' qr code generator which does nothing
internal class QRCodeEngine_None: QRCodeEngine {
	/// The engine name
	@objc public var name: String { "none" }

	/// Generate the QR code using the custom generator
	func generate(data: Data, errorCorrection: QRCode.ErrorCorrection) throws -> BoolMatrix {
		assert(false, "Warning: QRCode generator is not set...")
		throw QRCodeError.noGeneratorSet
	}

	func generate(text: String, errorCorrection: QRCode.ErrorCorrection) throws -> BoolMatrix {
		assert(false, "Warning: QRCode generator is not set...")
		throw QRCodeError.noGeneratorSet
	}
}

extension QRCode {
	/// Create a default engine for the platform
	@objc(DefaultEngine) static public func DefaultEngine() -> any QRCodeEngine {
#if os(watchOS)
		// You must supply a 3rd party generator for watchOS (see README.md)
		return QRCodeEngineExternal()
#else
		return QRCodeEngineCoreImage()
#endif
	}
}