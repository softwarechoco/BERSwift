// https://github.com/Quick/Quick

import Quick
import Nimble
import BERSwift

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        let src = "MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIAwggHvMIIBWKADAgECAhAvoXazbunwSfREtACZZhlFMA0GCSqGSIb3DQEBBQUAMAwxCjAIBgNVBAMMAWEwHhcNMDgxMDE1MTUwMzQxWhcNMDkxMDE1MTUwMzQxWjAMMQowCAYDVQQDDAFhMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCJUwlwhu5hR8X01f+vG0mKPRHsVRjpZNxSEmsmFPdDiD9kylE3ertTDf0gRkpIvWfNJ+eymuxoXF0Qgl5gXAVuSrjupGD6J+VapixJiwLXJHokmDihLs3zfGARz08O3qnO5ofBy0pRxq5isu/bAAcjoByZ1sI/g0iAuotC1UFObwIDAQABo1IwUDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0OBBYEFEIGXQB4h+04Z3y/n7Nv94+CqPitMB8GA1UdIwQYMBaAFEIGXQB4h+04Z3y/n7Nv94+CqPitMA0GCSqGSIb3DQEBBQUAA4GBAE0G7tAiaacJxvP3fhEj+yP9VDxL0omrRRAEaMXwWaBf/Ggk1T/u+8/CDAdjuGNCiF6ctooKc8u8KpnZJsGqnpGQ4n6L2KjTtRUDh+hija0eJRBFdirPQe2HAebQGFnmOk6Mn7KiQfBIsOzXim/bFqaBSbf06bLTQNwFouSO+jwOAAAxggElMIIBIQIBATAgMAwxCjAIBgNVBAMMAWECEC+hdrNu6fBJ9ES0AJlmGUUwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA4MTAxNTE1MDM0M1owIwYJKoZIhvcNAQkEMRYEFAAAAAAAAAAAAAAAAAAAAAAAAAAAMA0GCSqGSIb3DQEBAQUABIGAdB7ShyMGf5lVdZtvwKlnYLHMUqJWuBnFk7aQwHAmg3JnH6OcgId2F+xfg6twXm8hhUBkhHPlHGoWa5kQtN9n8rz3NorzvcM/1Xv9+0Eal7NYSn2Hb0C0DMj2XNIYH2C6CLIHkmy1egzUvzsomZPTkx5nGDWm+8WHCjWb9A6lyrMAAAAAAAA="

        do {
            let node = try BERSwift.parse(fromBase64String: src)
            let tgt = node.base64String
            
            print(src.count)
            print(tgt.count)
            if src == tgt {
                print("success")
            } else {
                print(node.hexString)
            }
        } catch let error {
            dump(error)
        }
        
//        describe("these will fail") {
//
//            it("can do maths") {
//                expect(1) == 2
//            }
//
//            it("can read") {
//                expect("number") == "string"
//            }
//
//            it("will eventually fail") {
//                expect("time").toEventually( equal("done") )
//            }
//
//            context("these will pass") {
//
//                it("can do maths") {
//                    expect(23) == 23
//                }
//
//                it("can read") {
//                    expect("🐮") == "🐮"
//                }
//
//                it("will eventually pass") {
//                    var time = "passing"
//
//                    DispatchQueue.main.async {
//                        time = "done"
//                    }
//
//                    waitUntil { done in
//                        Thread.sleep(forTimeInterval: 0.5)
//                        expect(time) == "done"
//
//                        done()
//                    }
//                }
//            }
//        }
    }
}
