import Foundation

struct Page<T: Decodable>: Decodable {
    let content: [T]
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let number: Int
    let numberOfElements: Int
    let first: Bool
    let last: Bool
    let empty: Bool?
    let sort: PageSort?
    let pageable: Pageable?
}

struct PageSort: Decodable {
    let empty: Bool?
    let sorted: Bool?
    let unsorted: Bool?
}

struct Pageable: Decodable {
    let offset: Int?
    let sort: PageSort?
    let paged: Bool?
    let pageNumber: Int?
    let pageSize: Int?
    let unpaged: Bool?
}

extension Page {
    static func empty() -> Page<T> {
        Page(
            content: [],
            totalElements: 0,
            totalPages: 0,
            size: 0,
            number: 0,
            numberOfElements: 0,
            first: true,
            last: true,
            empty: true,
            sort: nil,
            pageable: nil
        )
    }
}
