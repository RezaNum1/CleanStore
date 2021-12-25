//
//  OrdersMemStore.swift
//  FeaturedApp
//
//  Created by Reza Harris on 26/10/21.
//

import Foundation

class OrdersMemStore: OrdersStoreProtocol, OrdersStoreUtilityProtocol {
  static var billingAddress = Address(street1: "1 Infinite Loop", street2: "", city: "Cupertino", state: "CA", zip: "95014")
  
  static var shipmentAddress = Address(street1: "One MicrosoftWay", street2: "", city: "Redmond", state: "WA", zip: "98052-7329")
  
  static var paymentMethod = PaymentMethod(creditCardNumber: "1234-123456-1234", expirationDate: Date(), cvv: "999")
  
  static var shipmentMethod = ShipmentMethod(speed: .OneDay)
  
  static var orders = [
    Order(firstName: "Amy", lastName: "Apple", phone:
            "111-111-1111", email: "amy.apple@clean-swift.com", billingAddress:
            billingAddress, paymentMethod: paymentMethod, shipmentAddress:
            shipmentAddress, shipmentMethod: shipmentMethod, id: "abc123",
          date: Date(), total: NSDecimalNumber(string: "1.23")),
    Order(firstName: "Bob", lastName: "Battery", phone: "222-222-2222", email: "bob.battery@clean-swift.com", billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: "def456", date: Date(), total: NSDecimalNumber(string: "4.56"))
  ]
  
  // MARK: - Fetch Order
  func fetchOrders(completionHandler: @escaping (() throws -> [Order]) -> Void) {
    completionHandler { return type(of: self).orders }
  }
  
  // MARK: - Create Order
  func createOrder(orderToCreate: Order, completionHandler: @escaping (() throws -> Order?) -> Void) {
    var order = orderToCreate
    generateOrderID(order: &order)
    calculateOrderTotal(order: &order)
    type(of: self).orders.append(order)
    completionHandler { return order }
  }
  
  // MARK: - Update Order
  func updateOrder(orderToUpdate: Order, completionHandler: @escaping (() throws -> Order?) -> Void) {
    if let index = indexOfOrderWithID(id: orderToUpdate.id) {
      type(of: self).orders[index] = orderToUpdate
      let order = type(of: self).orders[index]
      completionHandler { return order }
    } else {
      completionHandler { throw OrdersStoreError.CannotUpdate("Cannot fetch order with id \(String(describing: orderToUpdate.id)) to update") }
    }
  }
  
  // MARK: - Convenience Methods
  private func indexOfOrderWithID(id: String?) -> Int?
  {
    return type(of: self).orders.firstIndex { return $0.id == id }
  }
}

// MARK: -
protocol OrdersStoreUtilityProtocol {}

extension OrdersStoreUtilityProtocol
{
  func generateOrderID(order: inout Order)
  {
    guard order.id == nil else { return }
    order.id = "\(arc4random())"
  }
  
  func calculateOrderTotal(order: inout Order)
  {
    guard order.total == NSDecimalNumber.notANumber else { return }
    order.total = NSDecimalNumber.one
  }
}
