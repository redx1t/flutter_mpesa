# flutter example mpesa daraja api for STK push

A simple example of implementing `stk push` on flutter mobile

**TESTED ON: ANDROID MOBILE ANDROID 11**

It does not depend on hardware specific needs and should work on all androids. If you have an issue, please submit it on the [issues page here](https://github.com/redx1t/flutter_mpesa/issues)

### How to configure your environment variables

introduce a .env file

ensure its listed as an asset under `pubspec.yaml`

```
    assets:
        - .env
```

add env configs as on `./env.example`

you can get your specific enviroment variables from [Daraja Developer Portal](https://developer.safaricom.co.ke/). Create a developer account, then creating an app on [MyApp Page](https://developer.safaricom.co.ke/MyApps).

Then get your `MpesaExpress` password for STK_PASSWORD from [Mpesa Simulate Page](https://developer.safaricom.co.ke/APIs/MpesaExpressSimulate)

![Mpesa Express Checkout page](./assets/mpesa-express%20simulate.png)

on development the `short_code` in `.env.example` is valid as of `July-2023`


### how to configure your flutter application to run

run `flutter pub get` to get all the packages

run `flutter run` and code away

#### FAQs

- if you have no backend to process callbacks or confirmations, I have done a simple [laravel api](https://github.com/redx1t/mpesa-flutter-laravel) with a simple api that can be exposed via `ngrok` for your testing

- you can also query from mobile if a transaction has been successful, using ` Transaction Query API.` (this is beyond the scope of this project). Part of my TODO. Will update this `readme` once done. 