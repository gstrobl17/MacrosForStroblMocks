import Foundation

public protocol CookieStoring {
    
    func setCookie(_ cookie: HTTPCookie)
    func deleteCookie(_ cookie: HTTPCookie)
    func cookies(for URL: URL) -> [HTTPCookie]?

}
