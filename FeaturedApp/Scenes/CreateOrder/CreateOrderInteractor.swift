//
//  CreateOrderInteractor.swift
//  FeaturedApp
//
//  Created by Reza Harris on 25/10/21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CreateOrderBusinessLogic
{
  var shippingMethods: [String] { get }
  var orderToEdit: Order? { get }
  func formatExpirationDate(request: CreateOrder.FormatExpirationDate.Request)
  func createOrder(request: CreateOrder.CreateOrder.Request)
  func showOrderToEdit(request: CreateOrder.EditOrder.Request)
  func updateOrder(request: CreateOrder.UpdateOrder.Request)
}

protocol CreateOrderDataStore
{
  var orderToEdit: Order? { get set }
}

class CreateOrderInteractor: CreateOrderBusinessLogic, CreateOrderDataStore
{
  var orderToEdit: Order?
  
  var ordersWorker = OrdersWorker(orderStore: OrdersMemStore())
  var presenter: CreateOrderPresentationLogic?
  var worker: CreateOrderWorker?
  
  var shippingMethods = [
    ShipmentMethod(speed: .Standard).toString(),
    ShipmentMethod(speed: .OneDay).toString(),
    ShipmentMethod(speed: .TwoDay).toString()
  ]
  
  // MARK: - Expiration Date
  func formatExpirationDate(request: CreateOrder.FormatExpirationDate.Request) {
    let response = CreateOrder.FormatExpirationDate.Response(date: request.date)
    presenter?.presentExpirationDate(response: response)
  }
  
  // MARK: - Save Button / Create Order
  
  func createOrder(request: CreateOrder.CreateOrder.Request)
  {
    let orderToCreate = buildOrderFromOrderFormFields(request.orderFormFields)
    ordersWorker.createOrder(orderToCreate: orderToCreate) { (order: Order?) in
      self.orderToEdit = order
      let response = CreateOrder.CreateOrder.Response(order: order)
      self.presenter?.presentCreatedOrder(response: response)
    }
  }
  
  // MARK: - Edit Order
  func showOrderToEdit(request: CreateOrder.EditOrder.Request)
  {
    print("test")
    if let orderToEdit = orderToEdit {
      let response = CreateOrder.EditOrder.Response(order: orderToEdit)
      presenter?.presentOrderToEdit(response: response)
    }
  }
  
  // MARK: - Update Order
  func updateOrder(request: CreateOrder.UpdateOrder.Request)
  {
    let orderToUpdate = buildOrderFromOrderFormFields(request.orderFormFields)
    ordersWorker.updateOrder(orderToUpdate: orderToUpdate) { (order) in
      self.orderToEdit = order
      let response = CreateOrder.UpdateOrder.Response(order: order)
      self.presenter?.presenterUpdateOrder(response: response)
    }
  }
  
  // MARK: - Helper Function
  private func buildOrderFromOrderFormFields(_ orderFormFields: CreateOrder.OrderFormFields) -> Order
  {
    let billingAddress = Address(street1: orderFormFields.billingAddressStreet1, street2: orderFormFields.billingAddressStreet2, city: orderFormFields.billingAddressCity, state: orderFormFields.billingAddressState, zip: orderFormFields.billingAddressZIP)
    
    let paymentMethod = PaymentMethod(creditCardNumber: orderFormFields.paymentMethodCreditCardNumber, expirationDate: orderFormFields.paymentMethodExpirationDate, cvv: orderFormFields.paymentMethodCVV)
    
    let shipmentAddress = Address(street1: orderFormFields.shipmentAddressStreet1, street2: orderFormFields.shipmentAddressStreet2, city: orderFormFields.shipmentAddressCity, state: orderFormFields.shipmentAddressState, zip: orderFormFields.shipmentAddressZIP)
    
    let shipmentMethod = ShipmentMethod(speed: ShipmentMethod.ShippingSpeed(rawValue: orderFormFields.shipmentMethodSpeed)!)
    
    return Order(firstName: orderFormFields.firstName, lastName: orderFormFields.lastName, phone: orderFormFields.phone, email: orderFormFields.email, billingAddress: billingAddress, paymentMethod: paymentMethod, shipmentAddress: shipmentAddress, shipmentMethod: shipmentMethod, id: orderFormFields.id, date: orderFormFields.date, total: orderFormFields.total)
  }
}
