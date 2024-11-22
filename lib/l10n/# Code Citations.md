# Code Citations

## License: unknown
https://github.com/samirRibeiro77/daily_helper/tree/b597fc740ad45a9073ea047aa8599aa93e21d0df/lib/app_localizations.dart

```
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations
```


## License: MIT
https://github.com/hazizz/hazizz_mobile/tree/e9ca1afb4f0bd976d8b93279790d7eaaebd1671b/lib/custom/hazizz_localizations.dart

```
.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String
```


## License: unknown
https://github.com/VladislavRUS/burger_city_flutter/tree/d9bdf9567a88bb25799773a57b6ded9400df2f0d/lib/app_localizations.dart

```
> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ??
```


## License: unknown
https://github.com/razifertani/Quizzed/tree/b7005421512ed9f83600e833578f02f4f98f509a/lib/appLocalizations.dart

```
, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key]
```


## License: unknown
https://github.com/WGroup-inc/App_packages_flutter/tree/f0d531576b869892baae0fe116adee3ae7ef256a/packages/signed_in/lib/resources/app_localizations.dart

```
.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
```

