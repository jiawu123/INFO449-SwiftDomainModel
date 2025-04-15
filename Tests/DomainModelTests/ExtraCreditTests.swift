import XCTest
@testable import DomainModel

class ExtraCreditTests: XCTestCase {
    // MONEY TESTS
    func testZeroAmount() {
        let zeroUSD = Money(amount: 0, currency: "USD")
        XCTAssert(zeroUSD.amount == 0)
        XCTAssert(zeroUSD.currency == "USD")
        
        let zeroGBP = zeroUSD.convert("GBP")
        XCTAssert(zeroGBP.amount == 0)
        XCTAssert(zeroGBP.currency == "GBP")
    }

    func testNegativeAmount() {
        let negativeMoney = Money(amount: -100, currency: "USD")
        XCTAssert(negativeMoney.amount == -100)
        let converted = negativeMoney.convert("GBP")
        XCTAssert(converted.amount == -50)
    }

    func testLargeAmounts() {
        let millionUSD = Money(amount: 1000000, currency: "USD")
        let convertedGBP = millionUSD.convert("GBP")
        XCTAssert(convertedGBP.amount == 500000)
    }

    func testCaseInsensitiveCurrency() {
        let money1 = Money(amount: 100, currency: "usd")
        let money2 = Money(amount: 100, currency: "USD")
        XCTAssert(money1.currency == money2.currency)
    }

    func testComplexConversionChain() {
        let startUSD = Money(amount: 100, currency: "USD")
        let result = startUSD.convert("GBP").convert("EUR").convert("CAN").convert("USD")
        XCTAssert(result.amount == startUSD.amount)
    }

    func testMultipleCurrencyOperations() {
        let usd = Money(amount: 100, currency: "USD")
        let gbp = Money(amount: 50, currency: "GBP")
        let eur = Money(amount: 150, currency: "EUR")
        let result = usd.convert("EUR").add(gbp.convert("EUR")).add(eur)
        XCTAssert(result.currency == "EUR")
    }

    // JOB TESTS
    func testNegativeHourlyRate() {
        let job = Job(title: "Volunteer", type: Job.JobType.Hourly(-5.0))
        XCTAssert(job.calculateIncome(10) == -50)
    }

    func testZeroSalary() {
        let job = Job(title: "Intern", type: Job.JobType.Salary(0))
        XCTAssert(job.calculateIncome(2000) == 0)
    }

    func testVeryLargeSalary() {
        let job = Job(title: "CEO", type: Job.JobType.Salary(1000000))
        XCTAssert(job.calculateIncome(2000) == 1000000)
    }

    func testMultipleRaises() {
        let job = Job(title: "Developer", type: Job.JobType.Hourly(20.0))
        job.raise(byAmount: 5.0)
        job.raise(byPercent: 0.5)
        XCTAssert(job.calculateIncome(10) == 375)
    }

    func testZeroHoursWorked() {
        let job = Job(title: "Consultant", type: Job.JobType.Hourly(50.0))
        XCTAssert(job.calculateIncome(0) == 0)
    }

    func testMaximumHours() {
        let job = Job(title: "Overtime", type: Job.JobType.Hourly(10.0))
        XCTAssert(job.calculateIncome(168) == 1680) // Max hours in a week
    }

    // PERSON TESTS
    func testVeryYoungPerson() {
        let child = Person(firstName: "Baby", lastName: "Smith", age: 1)
        child.job = Job(title: "Actor", type: Job.JobType.Hourly(15.0))
        XCTAssert(child.job == nil)
    }

    func testVeryOldPerson() {
        let elder = Person(firstName: "Elder", lastName: "Smith", age: 100)
        elder.job = Job(title: "Consultant", type: Job.JobType.Hourly(50.0))
        XCTAssert(elder.job != nil)
    }

    func testMultipleJobChanges() {
        let person = Person(firstName: "Job", lastName: "Hopper", age: 30)
        person.job = Job(title: "Developer", type: Job.JobType.Salary(1000))
        person.job = Job(title: "Manager", type: Job.JobType.Salary(2000))
        XCTAssert(person.job?.title == "Manager")
    }

    func testSpouseAgeEdgeCases() {
        let young = Person(firstName: "Young", lastName: "Person", age: 17)
        let adult = Person(firstName: "Adult", lastName: "Person", age: 18)
        young.spouse = adult
        XCTAssert(young.spouse == nil)
        adult.spouse = young
        XCTAssert(adult.spouse == nil)
    }

    // FAMILY TESTS
    func testLargeFamily() {
        let parent1 = Person(firstName: "Parent", lastName: "One", age: 30)
        let parent2 = Person(firstName: "Parent", lastName: "Two", age: 30)
        let family = Family(spouse1: parent1, spouse2: parent2)
        
        for i in 1...5 {
            let child = Person(firstName: "Child\(i)", lastName: "Family", age: 10)
            XCTAssert(family.haveChild(child))
        }
        XCTAssert(family.members.count == 7)
    }

    func testFamilyIncome() {
        let spouse1 = Person(firstName: "Main", lastName: "Provider", age: 30)
        let spouse2 = Person(firstName: "Part", lastName: "Timer", age: 30)
        spouse1.job = Job(title: "Manager", type: Job.JobType.Salary(100000))
        spouse2.job = Job(title: "Consultant", type: Job.JobType.Hourly(50))
        
        let family = Family(spouse1: spouse1, spouse2: spouse2)
        let child = Person(firstName: "Summer", lastName: "Worker", age: 19)
        child.job = Job(title: "Intern", type: Job.JobType.Hourly(20))
        let _ = family.haveChild(child)
        
        XCTAssert(family.householdIncome() > 100000)
    }

    static var allTests = [
        ("testZeroAmount", testZeroAmount),
        ("testNegativeAmount", testNegativeAmount),
        ("testLargeAmounts", testLargeAmounts),
        ("testCaseInsensitiveCurrency", testCaseInsensitiveCurrency),
        ("testComplexConversionChain", testComplexConversionChain),
        ("testMultipleCurrencyOperations", testMultipleCurrencyOperations),
        ("testNegativeHourlyRate", testNegativeHourlyRate),
        ("testZeroSalary", testZeroSalary),
        ("testVeryLargeSalary", testVeryLargeSalary),
        ("testMultipleRaises", testMultipleRaises),
        ("testZeroHoursWorked", testZeroHoursWorked),
        ("testMaximumHours", testMaximumHours),
        ("testVeryYoungPerson", testVeryYoungPerson),
        ("testVeryOldPerson", testVeryOldPerson),
        ("testMultipleJobChanges", testMultipleJobChanges),
        ("testSpouseAgeEdgeCases", testSpouseAgeEdgeCases),
        ("testLargeFamily", testLargeFamily),
        ("testFamilyIncome", testFamilyIncome)
    ]
} 