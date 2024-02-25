import Foundation
import SwiftUI
import CodeScanner // Import CodeScanner library
import UIKit

struct ContentView: View {
    enum Option: String, Identifiable {
        case consumers = "Consumers"
        case manufacturers = "Manufacturers"
        case aboutApp = "About DrugWise" // New option
        
        var id: String { self.rawValue }
    }
    
    @State private var isShowingOptions = false
    @State private var selectedOption: Option?
    @State private var isShowingImagePicker = false
    @State private var image: UIImage?
    @State private var imageDescription: String?
    @State private var manufacturerDetails: ManufacturerDetails?
    @State private var showHomeView = false // New state variable
    @State private var showAboutApp = false // New state variable
    @State private var showTopImage = false // New state variable for DRUGWISE TOP image
    
    // Variable to store scanned barcode
    @State private var scannedBarcode: String?
    @State private var noBarcodeFound = false // Flag to control the display of "NO BARCODE FOUND" message
    
    var body: some View {
        NavigationView {
            ZStack{
                Color(red: 16/255, green: 43/255, blue: 63/255)
                    .ignoresSafeArea()
                
                VStack {
                    
                    if image != nil {
                        Image(uiImage: image!)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .padding()
                        
                        if let description = imageDescription {
                            Text(description)
                                .padding()
                        }
                    }
                    
                    if !isShowingOptions {
                        TitleView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.isShowingOptions = true
                                }
                            }
                    } else {
                        OptionsView(selectedOption: $selectedOption)
                    }
                }
                .sheet(item: $manufacturerDetails) { details in
                    ManufacturerDetailsView(details: details, onSave: {
                        self.showHomeView = true
                    })
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(image: self.$image, onImageSelected: { image in
                        self.image = image
                        // Perform barcode scanning when image is selected
                        if let ciImage = CIImage(image: image) {
                            let context = CIContext()
                            let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
                            let features = detector?.features(in: ciImage)
                            if let firstFeature = features?.first as? CIQRCodeFeature {
                                self.scannedBarcode = firstFeature.messageString
                                self.noBarcodeFound = false
                            } else {
                                self.scannedBarcode = nil // No barcode found
                                self.noBarcodeFound = true
                            }
                        }
                    })
                }
                .alert(item: $selectedOption) { option in
                    switch option {
                    case .consumers:
                        return Alert(title: Text("Select an image"), message: nil, primaryButton: .default(Text("OK")) {
                            self.isShowingImagePicker = true
                        }, secondaryButton: .cancel())
                    case .manufacturers:
                        return Alert(title: Text("Enter Details"), message: nil, primaryButton: .default(Text("OK")) {
                            self.navigateToManufacturerDetails()
                        }, secondaryButton: .cancel())
                    case .aboutApp: // New case for About the App
                        return Alert(title: Text("About the App"), message: Text("Using blockchain technology, our app provides a secure, decentralized record of a drug's journey from manufacturing to sale, enabling consumers, distributors, and manufacturers to instantly verify authenticity. By recording key details like ingredients batches, transportation data, and storage conditions on a tamper-proof distributed ledger, we arm stakeholders across the pharmaceutical supply chain with transparency. With easy scanning and tracking, we aim to build trust, combat counterfeit drugs, improve safety outcomes, and raise industry standards."), dismissButton: .default(Text("OK")))
                    }
                }
                .background(
                    NavigationLink(destination: HomeView(), isActive: $showHomeView) {
                        EmptyView()
                    }
                )
                
                if showTopImage {
                    VStack {
                        Image("DRUGWISE TOP") // Your logo image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.bottom, 0)
                            .padding(.top, 0)
                            .frame(height: 50)
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                }
                
                // Display the scanned barcode or "NO BARCODE FOUND" message
                if let scannedBarcode = scannedBarcode {
                    Text("Scanned Barcode: \(scannedBarcode)")
                        .foregroundColor(.white)
                        .padding()
                } else if noBarcodeFound {
                    Text("NO BARCODE FOUND")
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    self.image = nil
                    self.selectedOption = nil
                }) {
                    Image(systemName: "house.fill")
                        .foregroundColor(.white)
                },
                trailing: Button(action: {
                    self.selectedOption = .aboutApp // Trigger About the App
                }) {
                    Text("About")
                        .foregroundColor(.white)
                }
            )
            .onAppear {
                // Show DRUGWISE TOP image after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showTopImage = true
                }
            }
        }
    }
    
    func navigateToManufacturerDetails() {
        let details = ManufacturerDetails()
        self.manufacturerDetails = details
    }
    
}

struct HomeView: View {
    var body: some View {
        // Your home view content here
        Text("Home Page")
    }
}

struct OptionsView: View {
    @Binding var selectedOption: ContentView.Option?
    
    var body: some View {
        VStack {
            Text("What Type of User Are You?")
                .padding()
                .font(.title)
                .foregroundColor(.white)
                
            Button(action: {
                self.selectedOption = .consumers
            }) {
                Text("Consumer")
                    .padding()
                    .font(.title) // Adjust font size
                    .foregroundColor(.black)
                    .background(Color.purple)
                    .cornerRadius(15) // Adjust corner radius
            }
            .padding(30) // Increase padding
            
            Button(action: {
                self.selectedOption = .manufacturers
            }) {
                Text("Manufacturer")
                    .padding()
                    .font(.title) // Adjust font size
                    .foregroundColor(.black)
                    .background(Color.purple)
                    .cornerRadius(15) // Adjust corner radius
            }
            .padding(10) // Increase padding
        }
    }
}

struct ManufacturerDetails: Identifiable {
    var id = UUID()
    var drugName: String = ""
    var productionDate: Date = Date()
    var batchNumber: String = ""
}

struct TitleView: View {
    var body: some View {
        VStack {
            Image("DRUGWISE LOGO") //
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .padding()
            /*
             Text("DrugWise")
             .font(.largeTitle)
             .fontWeight(.bold)
             .foregroundColor(.blue)
             
             */
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImageSelected(uiImage)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
}

struct ManufacturerDetailsView: View {
    var details: ManufacturerDetails
    var onSave: () -> Void
    
    @State private var drugName: String = ""
    @State private var productionDate: Date = Date()
    @State private var batchNumber: String = ""
    @State private var isShowingImagePicker = false
    @State private var manufacturerImage: UIImage?
    @State private var imageDescription: String?
    @State private var isShowingSuccessMessage = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Drug Details")) {
                    TextField("Drug Name", text: $drugName)
                    DatePicker("Production Date", selection: $productionDate, displayedComponents: .date)
                    TextField("Batch Number", text: $batchNumber)
                }
                
                if manufacturerImage != nil {
                    VStack {
                        Image(uiImage: manufacturerImage!)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .padding()
                        
                        if let description = imageDescription {
                            Text(description)
                                .padding()
                        }
                    }
                }
                
                Button(action: {
                    self.isShowingImagePicker = true
                }) {
                    Text("Select an image")
                }
                
                Button("Save") {
                    // Handle saving the details and image
                    self.isShowingSuccessMessage = true
                    self.onSave() // Call onSave closure to dismiss the view
                    
                }
                Link(destination: URL(string: "https://remix.ethereum.org")!, label: {
                    Text("Open blockchain ledger")
                })
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: self.$manufacturerImage, onImageSelected: { image in
                    self.manufacturerImage = image
                    self.imageDescription = "Image taken on \(Date())"
                })
            }
            .onAppear {
                // Initialize the fields with existing data if needed
                drugName = details.drugName
                productionDate = details.productionDate
                batchNumber = details.batchNumber
            }
            .navigationBarTitle("Manufacturer Details", displayMode: .inline)
            .alert(isPresented: $isShowingSuccessMessage) {
                Alert(
                    title: Text("Success"),
                    message: Text("Your information has been successfully added to a blockchain ledger."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
