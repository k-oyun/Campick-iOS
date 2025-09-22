import Foundation

enum LocalizationMaps {
    // 영어 → 한국어 매핑 테이블 (필요 시 확장)
    private static let typeEnToKo: [String: String] = [
        "MOTORHOME": "모터홈",
        "PICKUP": "픽업트럭",
        "SUV": "SUV",
        "VAN": "밴",
        "ETC": "기타"
    ]

    // 모델명은 다양하므로 일부 대표 모델만 예시 매핑, 기본은 원문 유지
    private static let modelEnToKo: [String: String] = [
        "Explorer": "익스플로러",
        "Sorento": "쏘렌토",
        "Forest": "포레스트"
    ]

    static func typeKo(_ value: String) -> String {
        let key = value.uppercased()
        return typeEnToKo[key] ?? value
    }

    static func modelKo(_ value: String) -> String {
        return modelEnToKo[value] ?? value
    }

    static func typesKo(_ values: [String]) -> [String] {
        return values.map { typeKo($0) }
    }

    static func modelsKo(_ values: [String]) -> [String] {
        return values.map { modelKo($0) }
    }
}

