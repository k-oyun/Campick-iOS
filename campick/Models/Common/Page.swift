import Foundation

struct Page<T: Decodable>: Decodable {
    let content: [T]
    let totalElements: Int?
    let totalPages: Int?
    let size: Int?
    /// 서버가 `page` 키를 사용하기도, `number`를 사용하기도 하므로 유연하게 맵핑
    let number: Int?
    let numberOfElements: Int?
    let first: Bool?
    let last: Bool?
    let empty: Bool?
    let sort: PageSort?
    let pageable: Pageable?

    private enum CodingKeys: String, CodingKey {
        case content
        case totalElements
        case totalPages
        case size
        case number
        case numberOfElements
        case first
        case last
        case empty
        case sort
        case pageable
        // 비표준 키
        case page
    }

    init(content: [T], totalElements: Int?, totalPages: Int?, size: Int?, number: Int?, numberOfElements: Int?, first: Bool?, last: Bool?, empty: Bool?, sort: PageSort?, pageable: Pageable?) {
        self.content = content
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.size = size
        self.number = number
        self.numberOfElements = numberOfElements
        self.first = first
        self.last = last
        self.empty = empty
        self.sort = sort
        self.pageable = pageable
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        content = try c.decode([T].self, forKey: .content)
        totalElements = try c.decodeIfPresent(Int.self, forKey: .totalElements)
        totalPages = try c.decodeIfPresent(Int.self, forKey: .totalPages)
        size = try c.decodeIfPresent(Int.self, forKey: .size)
        // 페이지 번호는 `number` 또는 `page` 중 하나로 올 수 있음
        number = try c.decodeIfPresent(Int.self, forKey: .number) ?? c.decodeIfPresent(Int.self, forKey: .page)
        numberOfElements = try c.decodeIfPresent(Int.self, forKey: .numberOfElements)
        first = try c.decodeIfPresent(Bool.self, forKey: .first)
        last = try c.decodeIfPresent(Bool.self, forKey: .last)
        empty = try c.decodeIfPresent(Bool.self, forKey: .empty)
        sort = try c.decodeIfPresent(PageSort.self, forKey: .sort)
        pageable = try c.decodeIfPresent(Pageable.self, forKey: .pageable)
    }
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
        Page(content: [],
             totalElements: 0,
             totalPages: 0,
             size: 0,
             number: 0,
             numberOfElements: 0,
             first: true,
             last: true,
             empty: true,
             sort: nil,
             pageable: nil)
    }
}
