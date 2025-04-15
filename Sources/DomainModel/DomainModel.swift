struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    // Properties
    public var amount: Int
    public var currency: String
    
    // Valid currencies
    private static let validCurrencies = ["USD", "GBP", "EUR", "CAN"]
    
    // Exchange rates (normalized to USD)
    private static let usdToGbp: Double = 0.5  // 1 USD = 0.5 GBP
    private static let usdToEur: Double = 1.5  // 1 USD = 1.5 EUR
    private static let usdToCan: Double = 1.25 // 1 USD = 1.25 CAN
    
    // Initializer
    public init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency.uppercased()
        
        // Validate currency
        if !Money.validCurrencies.contains(self.currency) {
            fatalError("Invalid currency: \(currency)")
        }
    }
    
    // Convert method
    public func convert(_ to: String) -> Money {
        let upperTo = to.uppercased()
        
        // If same currency, return copy of self
        if currency == upperTo {
            return Money(amount: amount, currency: currency)
        }
        
        // First convert to USD if not already USD
        var usdAmount = amount
        switch currency {
        case "GBP":
            usdAmount = Int(Double(amount) / Money.usdToGbp)
        case "EUR":
            usdAmount = Int(Double(amount) / Money.usdToEur)
        case "CAN":
            usdAmount = Int(Double(amount) / Money.usdToCan)
        default:
            break
        }
        
        // Then convert USD to target currency
        var finalAmount = usdAmount
        switch upperTo {
        case "GBP":
            finalAmount = Int(Double(usdAmount) * Money.usdToGbp)
        case "EUR":
            finalAmount = Int(Double(usdAmount) * Money.usdToEur)
        case "CAN":
            finalAmount = Int(Double(usdAmount) * Money.usdToCan)
        default:
            break
        }
        
        return Money(amount: finalAmount, currency: upperTo)
    }
    
    // Add method
    public func add(_ other: Money) -> Money {
        // Convert this amount to the other currency
        let convertedSelf = self.convert(other.currency)
        // Add the amounts in the same currency
        return Money(amount: convertedSelf.amount + other.amount, currency: other.currency)
    }
    
    // Subtract method
    public func subtract(_ other: Money) -> Money {
        // Convert this amount to the other currency
        let convertedSelf = self.convert(other.currency)
        // Subtract the amounts in the same currency
        return Money(amount: convertedSelf.amount - other.amount, currency: other.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    public var title: String
    public var type: JobType
    
    // Add the initializer that the tests are expecting
    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    public func calculateIncome(_ hours: Int) -> Int {
        switch type {
        case .Salary(let amount):
            return Int(amount)
        case .Hourly(let rate):
            return Int(rate * Double(hours))
        }
    }
    
    public func raise(byAmount: Double) {
        switch type {
        case .Salary(let amount):
            type = .Salary(UInt(Double(amount) + byAmount))
        case .Hourly(let rate):
            type = .Hourly(rate + byAmount)
        }
    }
    
    public func raise(byPercent: Double) {
        switch type {
        case .Salary(let amount):
            type = .Salary(UInt(Double(amount) * (1.0 + byPercent)))
        case .Hourly(let rate):
            type = .Hourly(rate * (1.0 + byPercent))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public var firstName: String
    public var lastName: String
    public var age: Int
    private var _job: Job?
    private var _spouse: Person?
    
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    // Add age-restricted job property
    public var job: Job? {
        get { return _job }
        set {
            if age >= 18 {  // Must be 18 or older to have a job
                _job = newValue
            }
        }
    }
    
    // Add age-restricted spouse property
    public var spouse: Person? {
        get { return _spouse }
        set {
            if age >= 18 && newValue?.age ?? 0 >= 18 {  // Both must be 18 or older to have a spouse
                _spouse = newValue
            } else {
                _spouse = nil
            }
        }
    }
    
    public func toString() -> String {
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(job?.title ?? "nil") spouse:\(spouse?.firstName ?? "nil")]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public var members: [Person] = []
    
    public init(spouse1: Person, spouse2: Person) {
        if spouse1.spouse == nil && spouse2.spouse == nil {
            spouse1.spouse = spouse2
            spouse2.spouse = spouse1
            members = [spouse1, spouse2]
        }
    }
    
    public func haveChild(_ child: Person) -> Bool {
        // Check if at least one spouse is over 21
        if let spouse1 = members.first, let spouse2 = members.last {
            if spouse1.age > 21 || spouse2.age > 21 {
                members.append(child)
                return true
            }
        }
        return false
    }
    
    public func householdIncome() -> Int {
        return members.reduce(0) { total, person in
            if let job = person.job {
                return total + job.calculateIncome(2000) // 2000 hours per year
            }
            return total
        }
    }
}
