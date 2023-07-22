# flutter_mpesa

A simple example of implementing stk push on flutter mobile

TESTED ON: ANDROID MOBILE

introduce a .env file

ensure its listed as an asset under `pubspec.yaml`

```
    assets:
        - .env
```

add env configs as on `./env.example`

you can get this .env from https://developer.safaricom.co.ke/ by creating an app and generating a lipaonline password for STK_PASSWORD

on development the short_code in .env.example is valid as of 07-2023


run `flutter pub get` to get all the packages

run `flutter run` and code away