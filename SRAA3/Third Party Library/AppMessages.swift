//
//  AppMessages.swift
//  Sercal
//
//  Created by Sucharu on 07/05/18.
//  Copyright © 2018 TrothMatrix (OPC) Private Limited. All rights reserved.
//

import Foundation
import UIKit

enum AppMessages: String {
    
   // Onesignal Credential pswd : fsnrebwcyp
    
    //Login
    case enterLoginEmail        = "Enter email address that you used for registeration."
    case enterLoginPassword     = "Enter password."
    case enterValidEmail        = "Enter valid email address."
    case loginSuccessfull       = "Login Successfully"
    
    // Sign up
    case enterFirstName              = "Enter First name."
    case enterValidFirstName     = "Enter first name with minimum 3 characters"
    //case validFirstName              = "First name must have 3 character."
    case enterLastName               = "Enter Last name."
    case enterSignUpEmail       = "Enter email address to register."
    case passwordDosntMatch     = "Your password and confirm password doesn't match."
    case enterValidPassword     = "Enter 6-15 digits password containing letter + number or symbol"
    case acceptTermsAndConditions = "Accept terms and contidions check to continue signup."
    case enterSignUpMobileNo       = "Enter Mobile Number."
    case enterValidMobileNo       = "Enter valid Phone number."

    // forgot Password
    case forgotPassword         = "You have received your forgot password request. You will get to steps on your registered email to recover your password."
    
    // Verify OTP
    
    case invalidOTP             = "Enter a valid OTP that we have shared in your mail."
    
    // Change Password
    case enterOldPassword   = "Enter a current password."
    case enterNewPassword   = "Enter a new password."
    case enterConfirmPassword   = "Enter a Confirm password."
    case callFunctionalityNotAvailable   = "Phone number functionality is not available."
    
    case ifEmailIsNotFailed   = "Your device could not send e-mail. Please check e-mail configuration and try again."
    case composeMailTitle = "Do you want to compose an email?"
    
    case noRouteFound = "No Route Found"
}
