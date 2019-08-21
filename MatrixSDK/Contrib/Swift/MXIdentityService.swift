/*
 Copyright 2019 The Matrix.org Foundation C.I.C
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

public extension MXIdentityService {
    
    // MARK: - Setup
    
    /**
     Create an instance based on identity server URL.
     
     - parameters:
     - identityServer: The identity server address.
     
     - returns: a `MXIdentityService` instance.
     */
    @nonobjc convenience init(identityServer: URL) {
        self.init(__identityServer: identityServer.absoluteString)
    }
    
    // MARK: -
    
    // MARK: Association lookup

    /**
     Retrieve a user matrix id from a 3rd party id.
     
     - parameters:
     - descriptor: the 3PID descriptor of the user in the 3rd party system.
     - completion: A block object called when the operation completes.
     - response: Provides the Matrix user id (or `nil` if the user is not found) on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func lookup3PID(_ descriptor: MX3PID, completion: @escaping (_ response: MXResponse<String?>) -> Void) -> MXHTTPOperation {
        return __lookup3pid(descriptor.address, forMedium: descriptor.medium.identifier, success: currySuccess(completion), failure: curryFailure(completion))
    }
    
    /**
     Retrieve user matrix ids from a list of 3rd party ids.
     
     - parameters:
     - descriptors: the list of 3rd party id descriptors
     - completion: A block object called when the operation completes.
     - response: Provides the user ID for each MX3PID submitted.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func lookup3PIDs(_ descriptors: [MX3PID], completion: @escaping (_ response: MXResponse<[MX3PID: String]>) -> Void) -> MXHTTPOperation {
        
        // The API expects the form: [[<(MX3PIDMedium)media1>, <(NSString*)address1>], [<(MX3PIDMedium)media2>, <(NSString*)address2>], ...]
        let ids = descriptors.map({ return [$0.medium.identifier, $0.address] as [String] })
        
        return __lookup3pids(ids, success: currySuccess(transform: { (triplets) -> [MX3PID : String]? in
            
            // The API returns the data as an array of arrays:
            // [[<(MX3PIDMedium)media>, <(NSString*)address>, <(NSString*)userId>], ...].
            var responseDictionary = [MX3PID: String]()
            triplets
                .compactMap { return $0 as? [String] }
                .forEach { triplet in
                    
                    // Make sure the array contains 3 items
                    guard triplet.count >= 3 else { return }
                    
                    // Build the MX3PID struct, and add ito the dictionary
                    let medium = MX3PID(medium: .init(identifier: triplet[0]), address: triplet[1])
                    responseDictionary[medium] = triplet[2]
            }
            return responseDictionary
            
        }, completion), failure: curryFailure(completion))
    }
    
    // MARK: Establishing associations
    
    /**
     Request the validation of an email address.
     
     The identity server will send an email to this address. The end user
     will have to click on the link it contains to validate the address.
     
     Use the returned sid to complete operations that require authenticated email
     like `MXRestClient.add3PID(_:)`.
     
     - parameters:
     - email: the email address to validate.
     - clientSecret: a secret key generated by the client. (`MXTools.generateSecret()` creates such key)
     - sendAttempt: the number of the attempt for the validation request. Increment this value to make the identity server resend the email. Keep it to retry the request in case the previous request failed.
     - nextLink: the link the validation page will automatically open. Can be nil
     - completion: A block object called when the operation completes.
     - response: Provides provides the id of the email validation session on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func requestEmailValidation(_ email: String, clientSecret: String, sendAttempt: UInt, nextLink: String?, completion: @escaping (_ response: MXResponse<String>) -> Void) -> MXHTTPOperation {
        return __requestEmailValidation(email, clientSecret: clientSecret, sendAttempt: sendAttempt, nextLink: nextLink, success: currySuccess(completion), failure: curryFailure(completion))
    }
    
    /**
     Submit the validation token received by an email or a sms.
     
     In case of success, the related third-party id has been validated
     
     - parameters:
     - token: the token received in the email.
     - medium the type of the third-party id (see kMX3PIDMediumEmail, kMX3PIDMediumMSISDN).
     - clientSecret: the clientSecret in the email.
     - sid: the email validation session id in the email.
     - completion: A block object called when the operation completes.
     - response: Indicates whether the operation was successful.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func submit3PIDValidationToken(_ token: String, medium: String, clientSecret: String, sid: String, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation {
        return __submit3PIDValidationToken(token, medium: medium, clientSecret: clientSecret, sid: sid, success: currySuccess(completion), failure: curryFailure(completion))
    }
    
    /**
     Sign a 3PID URL.
     
     - parameters:
     - signUrl: the URL that will be called for signing.
     - completion: A block object called when the operation completes.
     - response: Provides the signed data on success.
     
     - returns: a `MXHTTPOperation` instance.
     */
    @nonobjc @discardableResult func signUrl(_ signUrl: String, completion: @escaping (_ response: MXResponse<[String: Any]>) -> Void) -> MXHTTPOperation {
        return __signUrl(signUrl, success: currySuccess(completion), failure: curryFailure(completion))
    }
    
}
