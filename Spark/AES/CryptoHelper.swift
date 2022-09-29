//
//  CryptoHelper.swift
//  LionsAttendance
//
//  Created by Mata Prasad Chauhan on 01/11/17.
// Test commit

import Foundation
import CryptoSwift

/**
 This crypto helper is used to encrypt and decrypt the input parameter 
 */
class CryptoHelper {
    
    private static let key = "xfnr3PVyckouBZxW";//16 char secret key

    public static func encrypt(input:String)->String?{
        do{
            let encrypted: Array<UInt8> = try AES(key: key, iv: key, padding: .pkcs5).encrypt(Array(input.utf8))

            return encrypted.toBase64()
        }catch{
            debugPrint("Encryption Error>>>>>",error.localizedDescription)
        }
        return nil
    }

    public static func decrypt(input:String)->String?{
        do{
            let data = Data(base64Encoded: input)
            if data != nil {
                let decrypted = try AES(key: key, iv: key, padding: .pkcs5).decrypt(
                    data!.bytes)
                return String(data: Data(decrypted), encoding: .utf8)
            }

        }catch{
            debugPrint("Decryption Error>>>>>",error.localizedDescription)
        }
        return nil
    }
    
}
