//
//  Consent.swift
//  OCKSample
//
//  Created by Corey Baker on 11/11/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

/*
 t0do: The informedConsentHTML property allows you to display HTML
 on an ResearchKit Survey. Modify the consent so it properly
 represents the usecase of your application.
 */

let informedConsentHTML = """
    <!DOCTYPE html>
    <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta name="viewport" content="width=400, user-scalable=no">
        <meta charset="utf-8" />
        <style type="text/css">
            ul, p, h1, h3 {
                text-align: left;
            }
    
            
    
    
        </style>
    </head>
    <body>
        <h1>Consent</h1>
        <h3>Study Expectations</h3>
        <ul>
            <li>You will be asked to complete various study tasks such as surveys.</li>
            <li>Track will send you notifications to remind you to complete these study tasks.</li>
            <li>You will be asked to share various health data types to help you reach your goals.</li>
            <li>Your information will be kept private and secure.</li>
            <li>You can withdraw from sharing data at any time.</li>
        </ul>
        <h3>Eligibility Requirements</h3>
        <ul>
            <li>Must be 18 years or older.</li>
            <li>Must be able to read and understand English.</li>
            <li>Must be able to sign your own consent form.</li>
            <li>Be open to getting on <strong>Track</strong></li
        </ul>
        <p>By signing below, I acknowledge that I have read this consent carefully, that I understand all of its terms and I start voluntarily. I understand that my information will only be used and disclosed for the purposes described in the consent and I can withdraw from the study at any time.</p>
        <p>Please sign using your finger below.</p>
        <br>
    </body>
    </html>
    """
