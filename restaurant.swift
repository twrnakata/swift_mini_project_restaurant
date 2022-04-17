// enum Food: String, CaseIterable {
enum Food: Int{
    case burger = 60
    case pizza = 80
    case sandwich = 40
    case hotDog = 25

    func getName() -> String{
        switch self{
            case .burger:
                return "burger"
            case .pizza:
                return "pizza"
            case .sandwich:
                return "sandwich"
            case .hotDog:
                return "hotdog"
        }
    }

    func getFood() -> String{
        switch self{
            case .burger:
                return "🍔 Burger"
            case .pizza:
                return "🍕 Pizza"
            case .sandwich:
                return "🥪 Sandwich"
            case .hotDog:
                return "🌭 Hot Dog"
        }
    }

    func getPrice() -> Int{
        switch self{
            case .burger:
                return self.rawValue
            case .pizza:
                return self.rawValue
            case .sandwich:
                return self.rawValue
            case .hotDog:
                return self.rawValue
        }
    }

    func description() -> (name: String, price: Int){
        switch self{
            case .burger:
                return (name: "🍔 Burger", price: 60)
            case .pizza:
                return (name: "🍕 Pizza", price: 80)
            case .sandwich:
                return (name: "🥪 Sandwich", price: 40)
            case .hotDog:
                return (name: "🌭 Hot Dog", price: 25)
        }
    }

}


var moneyRefunds = 0

func isHaveThisFood(_ food: String) -> Bool{
    switch food.lowercased(){
        case "burger":
            return true
        case "pizza":
            return true
        case "sandwich":
            return true
        case "hotdog":
            return true
        default:
            return false     
    }
}


func updateItemInDictionary(add value: [Int], inKey key: String, toDict dict: inout [String: [Int]]){
    guard isHaveThisFood(key) else { return }
    dict[key] = value
}

// capturing values
func counter() -> () -> Void{
    var count = 1
    return { 
        print("Place Order Number:\(count)")
        count += 1
    }
}

let orderCount = counter()

func order(_ foods: Food, quantity: Int, toDict dict: inout [String: [Int]]) -> Bool{
    // คำนวณราคาอาหารที่ต้องจ่ายไปทั้งหมดใน order นี้
    // โดยคิดจากราคา + ขนาดของอาหาร ถ้าเงินไม่พอซื้อ จะไม่คิดเงินและยกเลิก order

    // guard dict.keys.contains("money"),
    guard let money = dict["money"],
    isHaveThisFood(foods.getName()) else { return false }

    var userMoney = money[0]
    let foodPrice = (foods.getPrice() * quantity)

    guard (userMoney > 0),
    ((userMoney - foodPrice) >= 0) else { return false }

    userMoney -= foodPrice
    moneyRefunds += foodPrice
    orderCount()

    // update money
    dict["money"] = [userMoney]

    let key = foods.getName()

    if let userFoodOrder = dict[key]{
        // update old quantity and price
        let newQuantity = userFoodOrder[0] + quantity
        let newPrice = userFoodOrder[1] + foodPrice
        updateItemInDictionary(add: [newQuantity, newPrice], inKey: key, toDict: &dict)
    }else{
        updateItemInDictionary(add: [quantity, foodPrice], inKey: key, toDict: &dict)
    }

    return true
}

func getCart(_ dict: [String: [Int]]) -> [(food: String, qty: Int, price: Int)]{
    var cart: [(food: String, qty: Int, price: Int)] = []
        for (key, item) in dict{
            switch key{
                case "burger":
                    cart.append((food: foodStocks[0].getFood(), qty: item[0], price: item[1]))
                case "pizza":
                    cart.append((food: foodStocks[1].getFood(), qty: item[0], price: item[1]))
                case "sandwich":
                    cart.append((food: foodStocks[2].getFood(), qty: item[0], price: item[1]))
                case "hotdog":
                    cart.append((food: foodStocks[3].getFood(), qty: item[0], price: item[1]))
                default:
                    continue
            }
        }
    return cart
}

func checkOut(for userCart: inout [String: [Int]]) {
    guard let money = userCart["money"] else { return }
    // guard userCart.keys.contains("money") else{ return }
    var userMoney = money[0]

    let cart = getCart(userCart)
    
    print("===== Check Out =====")
    
    print("Your item in this order 🛒 :")
    print(cart.sorted{ $0.price < $1.price })
    
    print("\nTotal pay for this order = \(moneyRefunds) Baht\n")
    // ถ้าไม่ confirm จะคืนเงิน
    print("Enter '1' for Confirm")
    print("other for cancel")
    
    let confirm = Int(readLine()!)!
    if (confirm == 1) {
        print("Your Money💰 left", userMoney)  
    }else{
        print("Cancel Order")
        userMoney += moneyRefunds
        print("Your Money💰 left", userMoney)
        userCart["money"] = [userMoney]
    }
    print("=== Thank you ===")
    print("===== Check Out =====")

    moneyRefunds = 0

}


func checkOrder(_ result: Bool, completed: () -> Void, unSuccess: () -> Void) -> Bool{
    if result{
        completed()
        return true
    }else{
        unSuccess()
        return false
    }
}


let foodStocks = [Food.burger, Food.pizza, Food.sandwich, Food.hotDog]
let showFoodStock: ([Food]) -> Void = { (food: [Food]) in
        for (number, food) in foodStocks.enumerated() {
        print(number + 1, food.description())
    }
}


// initialize variable
var userPickFood: Food? = nil
var userPickQuantity: Int
var userMoney: Int
var userCart : [String: [Int]] = [:]



// เริ่มต้นสั่งอาหาร
print("========================")
print("Welcome to Hot & Sour!")
print("========================")

print("Please Input Money")
userMoney = Int(readLine()!)!
userCart["money"] = [userMoney]

showFood: repeat{
    print("List of Foods")
    showFoodStock(foodStocks)


    ordering: repeat{
        print("Enter Order")
        var orderNumber = Int(readLine()!)!
        orderNumber -= 1
        let didOrderSuccess: (Int) -> Bool = { (number: Int) -> Bool in
            var flag = false
                if (number >= 0) && (number < foodStocks.count){
                    flag = true
                }
            return checkOrder(flag, completed:{
                print("Got it!")
            }){
                print("Sorry. We dont have that food")
            }
        }
    
        if didOrderSuccess(orderNumber) == false { continue ordering }
        userPickFood = foodStocks[orderNumber]
        break
    } while (true)
    
    orderQty: repeat{
        print("Enter Quantity")
        userPickQuantity = Int(readLine()!)!
        if (userPickQuantity <= 0){
            print("Invalid Number")
            continue orderQty
        }else{
            break
        }
    } while (true)


    print("\nProcessing...\n")
    if order(userPickFood!, quantity: userPickQuantity, toDict: &userCart){
        print("Order Success!")
        print("Here is your order 🛒 ")
        let cart = getCart(userCart)
        print(cart, "\n")
    }else{
        let foodPrice = (userPickFood!.getPrice() * userPickQuantity)
        print("Order Unsuccess\n")
        print("Not enought money")
        print("Cost for your order is: \(foodPrice)")
        if let userCurrentMoney = userCart["money"]{
            print("=== Your Balance ===")
            print("💰", userCurrentMoney[0], "\n")
        }else{
            print("=== Your Dont have any Balance ===")
        }
    }
    
    if let userCurrentMoney = userCart["money"]{
        print("Your Money left:", userCurrentMoney[0])
        print("Order Again?")
        print("Enter '1' for Order Again")
        print("other for checkout")
        let reOrder = Int(readLine()!)!
        if (reOrder != 1) { break }
    }else{
        print("We dont found you wallet")
        break
    }

} while (true)

checkOut(for: &userCart)

print("\nEnd Program")