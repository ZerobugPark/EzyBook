//
//  PaymentRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation

struct PaymentValidationDTO: Encodable {
    let impUid: String

    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
     }

    
}
