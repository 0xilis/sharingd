# sharingd
sharingd decomp for apple id server learning, decompiled by Snoolie and plx, if you want to feel free to contribute to help us out!

This is mainly just stuff I need and does not cover a majority of sharingd. Just leaving this here in case anyone else wants to learn about SDAppleIDServerTask.

The ultimate goal of this project is to learn about how sharingd/AuthKit communicate with Apple ID servers for SFAppleIDIdentity / identity services, and use that knowledge to use those APIs on a Linux program to download the certificates, privateKeyPersistentReference, and AppleIDValidationRecord all without an Apple device to dump them. These are used in AirDrop and Signed Shortcuts, with the hope being a tool on Linux as described would be benefitting OpenAirdrop project and shortcut-sign.
