import 'package:flutter/foundation.dart';

/// model for method
class MobLinkMethod {
  MobLinkMethod({@required this.name, @required this.id})
      : assert(name != null && id != null),
        super();
  final String name;
  final int id;
}

/// method defines
class MobLinkMethods {
  static final MobLinkMethod getMobId = MobLinkMethod(name: "getMobId", id: 0);
  static final MobLinkMethod restoreScene =
      MobLinkMethod(name: "restoreScene", id: 1);
  static final MobLinkMethod uploadPrivacyPermissionStatus =
  MobLinkMethod(name: "uploadPrivacyPermissionStatus", id: 2);
  static final MobLinkMethod getPrivacyPolicy =
  MobLinkMethod(name: "getPrivacyPolicy", id: 4);
}

class MLSDKError extends Error {
  MLSDKError({this.rawData})
      : code = rawData != null ? rawData["code"] : 0,
        userInfo = rawData != null ? rawData["userInfo"] : {},
        super();
  final Map rawData;
  final int code;
  final Map userInfo;
}
