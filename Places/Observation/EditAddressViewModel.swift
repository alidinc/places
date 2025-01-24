import Combine
import PhotosUI
import SwiftUI
import SwiftData

@Observable
class EditAddressViewModel {
    
    // MARK: - Properties
    var apartmentNumber = ""
    var addressLine1 = ""
    var addressLine2 = ""
    var city = ""
    var sublocality = ""
    var postcode = ""
    var countryData: FlagData?
    var startDate = Date()
    var endDate: Date? = nil
    var buildingType: BuildingType = .flat
    var residentType: ResidentType = .friend
    var isCurrent = false
    var ownerName = ""
    var relationship = ""
    var image: UIImage?
    
    // UI State
    var previewURL: URL?
    var showCountries = false
    var showImagePicker = false
    var showDocumentPicker = false
    var showContactsList = false
    var showChecklist = false

    // Postcode Lookup State
    var postcodeResult: PostcodeResult? // The postcode data
    var isLoading = false
    var errorMessage: String?
    
    private var cancellables: Set<AnyCancellable> = []
    
    var isInvalidDate: Bool {
        startDate > endDate ?? .now
    }
    
    var currentAddressId: String {
        UserDefaults.standard.string(forKey: "current") ?? ""
    }
    
    // MARK: - Methods
    
    func hasUnsavedChanges(place: Address) -> Bool {
        return residentType != place.residentType ||
        addressLine1 != place.addressLine1 ||
        addressLine2 != place.addressLine2 ||
        apartmentNumber != place.apartmentNumber ||
        city != place.city ||
        postcode != place.postcode ||
        countryData != place.country
    }
    
    func loadPlaceDetails(from place: Address) {
        addressLine1 = place.addressLine1
        addressLine2 = place.addressLine2
        apartmentNumber = place.apartmentNumber
        sublocality = place.sublocality ?? ""
        postcode = place.postcode
        countryData = place.country
        startDate = place.startDate ?? .now
        endDate = place.endDate ?? .now
        buildingType = place.buildingType
        city = place.city
        residentType = place.residentType
        isCurrent = place.id == currentAddressId
        
        // Load ResidentProperty data if it exists
        if let residentProperty = place.residentProperty {
            ownerName = residentProperty.name
            relationship = residentProperty.relationship ?? ""
            if let imageData = residentProperty.image {
                image = UIImage(data: imageData)
            }
        }
        
        if place.country.name == "United Kingdom" {
            fetchPostcodeData(postcode: place.postcode)
        }
    }
    
    @MainActor
    func saveChanges(place: Address, modelContext: ModelContext) {
        place.addressLine1 = addressLine1
        place.addressLine2 = addressLine2
        place.sublocality = sublocality
        place.apartmentNumber = apartmentNumber
        place.city = city
        place.residentType = residentType
        
        if let countryData {
            place.country = countryData
        }
        place.postcode = postcode
        place.startDate = startDate
        place.endDate = endDate
        place.buildingType = buildingType
        
        // Update or create ResidentProperty
        if residentType == .friend {
            place.residentProperty = ResidentProperty(
                name: ownerName,
                relationship: relationship,
                image: image?.jpegData(compressionQuality: 0.8)
            )
        } else {
            place.residentProperty = nil
        }
        
        NotificationCenter.default.post(Notification(name: Constants.Notifications.addressesChanged))
    }
    
    // MARK: - Postcode Network Call
    func fetchPostcodeData(postcode: String) {
        guard !postcode.isEmpty else { return }
        
        let urlString = "https://api.postcodes.io/postcodes/\(postcode)"
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PostcodeResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                case .finished:
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                self?.postcodeResult = response.result
            })
            .store(in: &cancellables)
    }
}
