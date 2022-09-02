import UIKit
import Darwin


struct Vehicle: Parkable {
    let plate: String
    let type: VehicleType
    let checkInTime = Date()
    var discountCard: String?
    
    var parkedTime: Int {
        Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.plate == rhs.plate
    }
}

enum VehicleType {
    case car
    case miniBus
    case bus
    case motorcycle
    
    var hourFee: Int {
        switch self {
        case .car: return 20
        case .motorcycle: return 15
        case .miniBus: return 25
        case .bus: return 30
        }
    }
}

protocol Parkable: Hashable {
    var plate: String { get }
    var type: VehicleType { get }
    var discountCard: String? { get }
    var hasDiscountCard: Bool { get }
    var checkInTime: Date { get }
    var parkedTime: Int { get }
}

extension Parkable {
    var hasDiscountCard: Bool { discountCard != nil }
}

extension Parkable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
}

struct Parking {
    var vehicles: Set<Vehicle> = []
    private let capacity: Int = 20
    var parkingAccount: (earnings: Int, vehicles: Int) = (0, 0)
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool)-> Void) {
        //Verificamos que no se sepere el límite de capacidad y, si el vehiculo ya existe dentro del parking. Si cualquier da estas es falsa, enviamos error.
        guard capacity > self.vehicles.count || !self.vehicles.contains(vehicle) else {
            onFinish(false)
            return
        }
        //Agrego el vehiculo al parking
        self.vehicles.insert(vehicle)
        onFinish(true)
        return
    }
    //Mutating porque -> modificamos una prop dentro de la struct, por eso la hacemos que sea mutating xq en self.vehicles.insert(vehicle) lo estoy agregando.
    //Chequeamos que haya lugar y que el auto no esté repetido
    //onFinish(closure) el nombre del param que tiene la closure.
    
    mutating func checkOutVehicle(plate: String, onSucess: (Int) -> Void, onError: () -> Void) {
        //Verificamos si el vehiculo existe en el parking.
        guard let vehicle = vehicles.first(where: { $0.plate == plate }) else {
            onError()
            return
        }
        //Verificamos si tiene descuento
        let hasDiscound = vehicle.discountCard != nil
        //Calculamos monto a pagar
        let fee = calculateFee(type: vehicle.type, parkedTime: vehicle.parkedTime, hasDiscountCard: hasDiscound)
        self.vehicles.remove(vehicle)
        //Actualizamos números del parking
        self.parkingAccount.vehicles += 1
        self.parkingAccount.earnings += fee
        onSucess(fee)
        
    }
    
    private func calculateFee(type: VehicleType, parkedTime: Int, hasDiscountCard: Bool) -> Int {
        let hoursInMinutes = 120
        var total = 9
        /*Si el tiempo es menor o igual a 2 horas es 20$
        si es más de 2 horas:
            -se calculas los min restantes
            -se calculas los bloques de 15 min (se usa la funcion ceil para redondear hacia arriba)
            -se calculan a partir de precio de 2 horas mas los bloques de 15' multip por el valor de cada bloque */
        
        if parkedTime <= 120 {
            total = type.hourFee
        } else {
            let minutesLeft = Float(parkedTime - hoursInMinutes)
            //Dividimos el tiempo de excedente entre 15
            let feeBlocks = ceil((minutesLeft/15))
            //Valor hora *(20 + 5 por cada bloque -> en una hora y lo multiplico por cant de bloques
            total = type.hourFee + Int(feeBlocks) * (type.hourFee/4)
        }
        
        //Se usa un operador ternarios para saber si tiene dto y se aplica este 15% o si se cobra total
        return hasDiscountCard ? Int(floor(Float(total) * 0.85)) : total
        //floor redondea monto para abajo
    }
    
    func showParkingAccount(){
        print("\(self.parkingAccount.vehicles) vehicles have checked out and have earning og $\(self.parkingAccount.earnings)")
    }
    
    func listVehicles() {
        self.vehicles.forEach { vehicle in
            print("Vehicle plate is \(vehicle.plate)")
        }
    }
}

var alkeParking = Parking()

let vehicles = [
    Vehicle(plate: "AA111AA", type: VehicleType.car, discountCard: "DISCOUNT_CARD_001"),
    Vehicle(plate: "B222BBB", type: VehicleType.motorcycle, discountCard: nil), Vehicle(plate: "CC333CC", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "DD444DD", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_002"),
    Vehicle(plate: "AA111BB", type: VehicleType.car, discountCard: "DISCOUNT_CARD_003"),
    Vehicle(plate: "B222CCC", type: VehicleType.motorcycle, discountCard: "DISCOUNT_CARD_004"),
    Vehicle(plate: "CC333DD", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "DD444EE", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_005"),
    Vehicle(plate: "AA111CC", type: VehicleType.car, discountCard: nil),
    Vehicle(plate: "B222DDD", type: VehicleType.motorcycle, discountCard: nil),
    Vehicle(plate: "CC333EE", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "DD444GG", type: VehicleType.bus, discountCard: "DISCOUNT_CARD_006"),
    Vehicle(plate: "AA111DD", type: VehicleType.car, discountCard: "DISCOUNT_CARD_007"),
    Vehicle(plate: "B222EEE", type: VehicleType.motorcycle, discountCard: nil),
    Vehicle(plate: "CC333FF", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "CC443FF", type: VehicleType.motorcycle, discountCard: nil),
    Vehicle(plate: "A12345F", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "P00089", type: VehicleType.miniBus, discountCard: "DISCOUNT_CARD_010"),
    Vehicle(plate: "PR45234", type: VehicleType.miniBus, discountCard: nil),
    Vehicle(plate: "IU89023", type: VehicleType.car, discountCard: "DISCOUNT_CARD_009")
]

// hashable no permite permitidos. set no permite dupli y hashable nos indica donde chequear en que comparar si son iguales.


for vehicle in vehicles {
    alkeParking.checkInVehicle(vehicle, onFinish: { success in success ? print("Welcome to AlkeParking!") : print("Sorry, the check-in failed")})
}

//vehicles.forEach { vehicle in
//    alkeParking.checkInVehicle(vehicle) { canInsert in
//        if !canInsert {
//            print("Sorry, failed")
//        } else {
//            print("Welcome")
//        }
//    }
//}

//Pruebo ingresar vehículo nro 21
alkeParking.checkOutVehicle(plate: "CC333GG",
                            onSucess: { fee in print("Your fee is \(fee). Come back soon.")},
                            onError: { print("Sorry, the check-out failed")})


//Pruebo realizar checkout de un vehiculo que nexiste
alkeParking.checkOutVehicle(plate: "AA111CC",
                            onSucess: { fee in print("Your fee is \(fee). Come back soon.")},
                            onError: { print("Sorry, the check-out failed")})

//Pruebo realizar checkout de un vehiculo que no existe
alkeParking.checkOutVehicle(plate: "A1111CC",
                            onSucess: { fee in print("Your fee is \(fee). Come back soon.")},
                            onError: { print("Sorry, the check-out failed")})

alkeParking.showParkingAccount()
alkeParking.listVehicles()
