//
//  OrderListModel.swift
//  SRAA3
//
//  Created by Apple on 23/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class OrderListModel: NSObject {
    var order_id = ""
    var store_id = ""
    var order_status = ""
    var created_at_formatted = ""
    var order_color = ""
    var sub_total = ""
    var total = ""
    var store_photo = ""
    var store_thumbnail = ""
    var store_name = ""
    var service_details = NSArray.init()
}

class AddressListModel: NSObject {
    var id = ""
    var line1 = ""
    var line2 = ""
    var phone = ""
    var title = ""
    var city = ""
    var country = ""
    var address_default = ""
    var latitude = ""
    var longitude = ""
    var linked_id = ""
    var pincode = ""
    var state = ""
}
