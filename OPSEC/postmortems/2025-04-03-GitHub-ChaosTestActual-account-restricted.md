# OPSEC INCIDENT POSTMORTEM 2025/04/03: GitHub restriced ChaosTestActual's account

**GitHub flagged and restricted @ChaosTestActual's account.**

@ChaosTestActual was able to log into the GitHub web interface, but encountered warning message on billing payments page.

@ChaosTestActual examined @self in a private window. GitHub profile page returned 404. 

Warning message on billing payments page indicated that the account had been restricted due to suspicious behavior.

Warning message contained link to a support ticket form located behind a text message only OTP query.

@ChaosTestActual submitted a support ticket with an explaination that the account was being used for research into online anonymity and secure authentication protocols.

GitHub support responded quickly and explained that the Proton email alias @ChaosTestActual was using as primary GitHub email had been the reason for the flagging and restrictions. GitHub considers the default Proton email alias domains to be ephemeral. 

@ChaosTestActual quickly relisted true Proton email address as GitHub primary email and messaged GitHub Support

GitHub support respondly quickly to lift the restrictions. Long range high five to Brian with GitHub Support.

## Fix

1. Submit GitHub Support ticket via form referenced in warning message. 
1. Go to GitHub profile and replace Proton email alias with true Proton email address
1. Message GitHub Support

## Root cause

The primary email address of @ChaosTestActual's GitHub profile was set to a Proton email alias.

The automated flag was triggered because the Proton email alias was using one of the default Proton alias domains. GitHub considers those domains to be ephemeral.

# Solution

1. [TEMPORARY] set true Proton email address as GitHub profile primary email address.
1. [IMMEDIATE] Create a dedicated OPSEC domain at @The-Department-of-Vibes-and-Haiku-Warfare.
    1. Configure opsec.dovahw.xyz as default email alias domain for DOVAHW accounts.
    1. Add opsec.dovahw.xyz DNS records to Unstoppable Domains account.
1. [STRETCH] Create new Proton identity.
    1. Buy custom domain.
    1. Sign up for Proton email using custom domain.
    1. Configure opsec sub domain.
    1. Create email alias on custom opsec sub domain.
    1. Set email alias as primary email on GitHub profile.
    1. Remove opsec.dovahw.xyz email address from GitHub profile



