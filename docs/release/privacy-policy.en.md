# Mojimachi Privacy Policy

> [Working note for the developer. Do not publish this block.]
> - Publish at `https://kenchan0130.github.io/apps/mojimachi/privacy` (English section or `/en`). Fill in every `TODO` first.
> - The crash-report section follows the design (D103, D123). **As of 2026-11-27 the code does not include Sentry yet** (there is only the parent-area switch "Send bug information"). Add Sentry and lock the sent fields with a test before publishing. If you do not ship Sentry, delete that section and every mention of Sentry.
> - The menu names in English ("Children", "Manage Records", and so on) are translations. The app's parent area is Japanese only today (no English localization yet, D116). Either add the English parent screens or write the Japanese names next to the English ones.
> - Translation: the Japanese file is the source (D118). Use the terms in `docs/glossary.md`. Have another model check it.

Effective date: TODO (the release day, e.g. Month D, 2026)

Mojimachi ("the app") helps children aged about 4 to 7 practice writing letters on an iPad. The child-facing screens and voices are in Japanese. This page is written for parents and guardians. It explains what information the app handles.

## Who runs the app

- Operator: TODO (the seller name shown on the App Store, D65)
- Contact: see "Contact" below.

## The short version

- There are no ads.
- There is no usage analytics and no tracking.
- The app does not collect a child's name, address, email address, location, photos, or voice.
- Learning records stay on the iPad and in the parent's own iCloud. The operator cannot see them.
- The operator receives only two things: crash information that does not identify anyone, and messages a parent chooses to send.

## What is stored on the iPad and in iCloud

The app stores this on the iPad:

- A nickname (chosen by the parent; it does not have to be a real name), a face picture, writing hand, daily goal, and pen color
- Practice records (letters written, dates, judgment results)
- The shape of the lines the child drew (for each letter, the first time and a few recent times)
- Collected items, the town layout, and clothes worn
- A record of when the child tapped "ask a grown-up" on a locked letter
- Settings (judgment strictness, volume, captions, and so on)

If the iPad is signed in to iCloud and "Sync with iCloud" is on in the parent area, the app also stores these records in the parent's iCloud private database (CloudKit).

- This is storage in the parent's own Apple Account. The operator cannot read it.
- It is for restoring records when the app is reinstalled or the iPad is replaced. iPads on the same Apple Account also sync with each other.
- Nothing is shared with other family members or other people.
- You can turn "Sync with iCloud" off at any time (parent area > Manage Records).
- If the iPad is not signed in to iCloud, records stay on the iPad only.

## What is sent out

### Crash reports (Sentry)

Only when the app crashes, it sends crash information to the crash-reporting service Sentry (Functional Software, Inc.). We use it to fix problems.

What is sent:

- Where the crash happened (the place in the program)
- The app version
- The iPadOS version
- The general model family of the iPad

What is not sent:

- Nicknames, names, practice records, or drawn lines
- Any ID that identifies a person or an iPad
- IP addresses (they are not stored)
- Logs of taps, screen recordings, or performance measurements

You can stop this by turning off "Send bug information" in the parent area under "Safety Settings". It is on by default.

Where Sentry stores the data: TODO (write the region chosen in Sentry)

### Contact form

From the parent area, a parent can open a contact form. It is a Google Form that opens in an in-app browser. A parent decides whether to send it.

- The text you write and an optional email address reach the operator.
- The form is pre-filled with the app name and version, the iPadOS version, and the type of message. If you open it from "This judgment looks wrong", the name of the judgment setting is also filled in. You can delete these before you send.
- Google's privacy policy also applies to the form.
- We use what you send only to reply. We delete it within 90 days after we finish the matter. We also delete it on request.
- Please do not write a child's name or send a child's photo.

### Purchases

Purchases are made through Apple's App Store. Apple handles payment details such as card numbers. They never reach the operator. The app only checks which products were purchased, using Apple's StoreKit.

## Ads, analytics, and tracking

- The app shows no ads and includes no ad services.
- It includes no usage analytics service.
- It does not track people across other companies' apps or websites.
- The only numbers the operator sees are the summaries in App Store Connect, provided by Apple.

## Children's information

Children aged 5 and under may use this app.

- The app does not let a child type a name, address, email address, phone number, location, photo, or voice. There is no screen for it.
- The child-facing screens show no external links, no purchases, and no contact form.
- External links, purchases, settings changes, and viewing learning records are available only after a parent passes the parental gate (a multiplication question).
- The nickname is chosen by the parent and stays on the iPad and in the parent's iCloud.
- The app is built so that the operator does not collect personal information from children, in line with the U.S. Children's Online Privacy Protection Act (COPPA) and the principles of Japan's Act on the Protection of Personal Information.

## iPad features the app does not use

The app does not use location, camera, microphone, photos, contacts, or calendar. If a parent turns on "Also ask for the iPad passcode" in the parental gate, the app uses the iPad's own authentication (Face ID, Touch ID, or passcode). Face and fingerprint data stay on the iPad and are never given to the app or the operator.

## How to delete information

| What you want | How |
|---|---|
| Delete all records of one child | Parent area > Children > the child > Delete (hold the red button for 3 seconds) |
| Delete one child's records but keep the profile | Same screen > Reset records only |
| Delete everyone's records | Parent area > Manage Records > Reset all records |
| Delete records in iCloud | Parent area > Manage Records > Delete iCloud data (hold the red button for 3 seconds). Records on other iPads may also be removed |
| Delete iCloud records after deleting the app | Deleting the app does not delete iCloud records. On the iPad: Settings > your name > iCloud > Manage Storage > Mojimachi > Delete Data |
| Delete messages you sent through the contact form | Tell us at the contact address below that you want them deleted |

Deleting the app removes the records stored on the iPad.

## Changes to this page

When we change this page, we update it and change the effective date above. For big changes, we also say so in the update notes.

## Contact

- Contact form: TODO (the same Google Form URL as in the app, or a link to the support page `https://kenchan0130.github.io/apps/mojimachi`)
- We aim to reply within 3 days.
- TODO: the developer's contact address (for example an email address). **The human decides and fills this in. It is not invented here.** Do not publish a street address or phone number (D65).
