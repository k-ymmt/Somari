import Foundation

@freestanding(expression)
public macro URL(_ urlString: String) -> URL = #externalMacro(module: "SomariKitMacros", type: "URLMacro")
