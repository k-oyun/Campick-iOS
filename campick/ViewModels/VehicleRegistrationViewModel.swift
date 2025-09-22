import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class VehicleRegistrationViewModel: ObservableObject {
    // Form fields
    @Published var vehicleImages: [VehicleImage] = []
    @Published var uploadedImageUrls: [String] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var title: String = ""
    @Published var mileage: String = ""
    @Published var vehicleType: String = ""
    @Published var price: String = ""
    @Published var description: String = ""
    @Published var generation: String = ""
    @Published var vehicleModel: String = ""
    @Published var location: String = ""
    @Published var plateHash: String = ""
    @Published var vehicleOptions: [VehicleOption] = []

    // UI states
    @Published var showingVehicleTypePicker = false
    @Published var showingImagePicker = false
    @Published var showingOptionsPicker = false
    @Published var showingModelPicker = false
    @Published var errors: [String: String] = [:]
    @Published var isSubmitting = false
    @Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var alertMessage = ""
    @Published var availableTypes: [String] = []
    @Published var availableModels: [String] = []
    @Published var availableOptions: [String] = []
    @Published var isLoadingProductInfo = false
    @Published var isUploading = false
    @Published var isEditing = false
    @Published var editingProductId: String? = nil

    func loadProductInfo() async {
        isLoadingProductInfo = true
        do {
            let productInfo = try await ProductAPI.fetchProductInfo()
            availableTypes = productInfo.type
            availableModels = productInfo.model
            availableOptions = productInfo.option
            vehicleOptions = availableOptions.map { VehicleOption(optionName: $0, isInclude: false) }
        } catch {
            let appError = ErrorMapper.map(error)
            AppLog.error("Load product info failed: \(appError.message)", category: "PRODUCT")
            // 기본값 사용
            availableTypes = ["모터홈", "픽업트럭", "SUV"]
            availableModels = ["현대 포레스트", "기아 쏘렌토", "Toyota Hilux"]
            availableOptions = ["샤워실", "화장실", "침대", "주방", "에어컨"]
            vehicleOptions = availableOptions.map { VehicleOption(optionName: $0, isInclude: false) }
        }
        isLoadingProductInfo = false
    }

    // 편집 모드: 상세를 불러와 입력값 채우기
    func loadForEdit(productId: String) async {
        isEditing = true
        editingProductId = productId
        do {
            let dto = try await ProductAPI.fetchProductDetail(productId: productId)
            apply(detail: dto)
        } catch {
            let appError = ErrorMapper.map(error)
            AppLog.error("Load detail for edit failed: \(appError.message)", category: "PRODUCT")
        }
    }

    private func apply(detail dto: ProductDetailDTO) {
        title = dto.title ?? ""
        generation = {
            if let g = dto.generation { return String(g) }
            return ""
        }()
        mileage = dto.mileage ?? ""
        vehicleType = dto.vehicleType ?? ""
        vehicleModel = dto.vehicleModel ?? ""
        price = dto.price ?? ""
        location = dto.location ?? ""
        plateHash = dto.plateHash ?? ""
        description = dto.description ?? ""

        // 이미지 URL 세팅 (메인 + 나머지)
        if let urls = dto.productImage, !urls.isEmpty {
            uploadedImageUrls = urls
        }

        // 옵션 매핑: availableOptions를 기준으로 포함 여부 세팅
        if let opts = dto.option {
            let included = Set(opts.filter { $0.isInclude }.map { $0.optionName })
            vehicleOptions = availableOptions.map { name in
                VehicleOption(optionName: name, isInclude: included.contains(name))
            }
        }
    }

    func validateAndSubmit() {
        errors = [:]
        var newErrors: [String: String] = [:]

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { newErrors["title"] = "매물 제목을 입력하세요" }
        if generation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { newErrors["generation"] = "연식을 입력하세요" }
        if mileage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { newErrors["mileage"] = "주행거리를 입력하세요" }
        if vehicleType.isEmpty { newErrors["vehicleType"] = "차량 종류를 선택해주세요" }
        if vehicleModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { newErrors["vehicleModel"] = "차량 브랜드/모델을 입력해주세요" }
        if price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { newErrors["price"] = "판매 가격을 입력하세요" }
        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { newErrors["location"] = "판매 지역을 입력하세요" }
        let trimmedPlate = plateHash.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPlate.isEmpty {
            newErrors["plateHash"] = "차량 번호를 입력해주세요"
        } else if !Self.isValidKoreanPlate(trimmedPlate) {
            newErrors["plateHash"] = "올바른 번호판 형식을 입력하세요 (예: 123가4567)"
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { newErrors["description"] = "상세 설명을 입력해주세요" }

        errors = newErrors
        if errors.isEmpty { Task { await submit() } }
    }

    private static func isValidKoreanPlate(_ plateNumber: String) -> Bool {
        let koreanPlateRegex = "^\\d{2,3}[가-힣]\\d{4}$"
        return plateNumber.range(of: koreanPlateRegex, options: .regularExpression) != nil
    }

    func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }
        // 숫자 필드 정리
        let cleanPrice = price.replacingOccurrences(of: ",", with: "")
        let cleanMileage = mileage.replacingOccurrences(of: ",", with: "")
        // 한글 값 그대로 전송
        let localizedType = vehicleType
        let localizedModel = vehicleModel
        // 이미지 정책: 메인 이미지를 배열 첫번째로 위치시키기
        var productUrls = Array(uploadedImageUrls.dropFirst())
        let mainUrl = uploadedImageUrls.first ?? ""
        if !mainUrl.isEmpty { productUrls.insert(mainUrl, at: 0) }

        let request = VehicleRegistrationRequest(
            generation: Int(generation) ?? 0,
            mileage: cleanMileage,
            vehicleType: localizedType,
            vehicleModel: localizedModel,
            price: cleanPrice,
            location: location,
            plateHash: plateHash,
            title: title,
            description: description,
            productImageUrl: productUrls,
            option: vehicleOptions,
            mainProductImageUrl: mainUrl
        )

        if isEditing, let productId = editingProductId {
            AppLog.info("Updating product (id: \(productId))", category: "PRODUCT")
            do {
                let res = try await ProductAPI.updateProduct(productId: productId, body: request)
                let statusCode = res.status ?? 0
                if res.success == true || (200..<300).contains(statusCode) {
                    alertMessage = "성공적으로 매물 정보가 수정되었습니다."
                    showingSuccessAlert = true
                } else {
                    alertMessage = res.message ?? "수정에 실패했습니다."
                    showingErrorAlert = true
                }
            } catch {
                let appError = ErrorMapper.map(error)
                AppLog.error("Product update failed: \(appError.message)", category: "PRODUCT")
                alertMessage = appError.message
                showingErrorAlert = true
            }
        } else {
            AppLog.info("Creating product (title: \(title))", category: "PRODUCT")
            do {
                let res = try await ProductAPI.createProduct(request)
                // 성공은 2xx(예: 200, 201 포함) 또는 success == true 로 판단
                let statusCode = res.status ?? 0
                if res.success == true || (200..<300).contains(statusCode) {
                    alertMessage = res.message ?? "등록이 완료되었습니다."
                    showingSuccessAlert = true
                } else {
                    alertMessage = res.message ?? "등록에 실패했습니다."
                    showingErrorAlert = true
                }
            } catch {
                let appError = ErrorMapper.map(error)
                AppLog.error("Product create failed: \(appError.message)", category: "PRODUCT")
                alertMessage = appError.message
                showingErrorAlert = true
            }
        }
    }

    // MARK: - Image Upload
    func uploadImage(_ image: UIImage, for imageId: UUID) {
        isUploading = true
        ImageUploadService.shared.uploadImage(image) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isUploading = false
                switch result {
                case .success(let url):
                    self.uploadedImageUrls.append(url)
                    if let index = self.vehicleImages.firstIndex(where: { $0.id == imageId }) {
                        self.vehicleImages[index].uploadedUrl = url
                    }
                    AppLog.info("Image uploaded: \(url)", category: "UPLOAD")
                case .failure(let error):
                    let appError = ErrorMapper.map(error)
                    self.errors["images"] = appError.message
                    AppLog.error("Image upload failed: \(appError.message)", category: "UPLOAD")
                }
            }
        }
    }
}
