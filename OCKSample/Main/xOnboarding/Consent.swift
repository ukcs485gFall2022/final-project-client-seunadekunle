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

                * {
                    color: white;
                    font-type:
                    line-spacing: 1em;
                    font-family: Helvetica;
                }

                body {
                     background: rgb(41,51,92);
                     background: linear-gradient(135deg, rgba(41,51,92,1) 0%, rgba(219,43,57,1) 50%, rgba(243,167,18,1) 100%);
                }

                h1 {
                    font-size: 2em;
                }

                h3 {
                    font-size: 1.25em;
                }

                p, li {
                    line-height: 1.45;
                }

            </style>
        </head>
        <body>
            <h1>Consent</h1>
            <h3>Expectations</h3>
            <ul>
                <li>We will ask you to complete various study tasks such as surveys.</li>
                <li>Track will send you notifications to remind you to complete these surveys.</li>

                <li>Have a Positive Attitude and Be Truthful when answering survey</li>
            </ul>
            <h3>Privacy</h3>
            <ul>
                <li>We will ask you to share various health data types to help you reach your goals.</li>
                <li>Privacy is an important value at Track</li>
                <li>Your information will be kept private and secure. 🔒</li>
                <li>You can withdraw from sharing data at any time.</li>
            </ul>
            <h3>Eligibility</h3>
            <ul>
                <li>Must be 18 years or older.</li>
                <li>Must be able to read and understand English.</li>
                <li>Must be able to sign your own consent form.</li>
                <li>Be open to getting on <strong>Track</strong></li
            </ul>
            <p>By signing below, I acknowledge that I have read this consent form carefully, that I understand all of its terms and I start voluntarily. I understand that my information will only be used and disclosed for the purposes described in the consent and I can withdraw from the study at any time.</p>
            <p>Please sign using your finger below.</p>
            <p>Welcome aboard</p>
            <br>
        </body>
        </html>
    """
