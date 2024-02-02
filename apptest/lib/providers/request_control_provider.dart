import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RequestControlProvider {
  final bool requestSuccess;
  final bool connectionFailed;
  final String? errorMsg;
  final dynamic response;

  RequestControlProvider({
    required this.requestSuccess,
    this.errorMsg,
    this.response,
    required this.connectionFailed,
  });

  void showErrorDialog(BuildContext ctx, String? errorMsg) async {
    String displayMsg = errorMsg ?? '';
    if (kReleaseMode == true) {
      if (connectionFailed == true) {
        displayMsg = 'Occorreu um problema de comunicação, verifique sua internet e tente novamente';
      }
    }
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      connectionFailed == true ? Icons.wifi_off : Icons.close,
                      size: 35,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  displayMsg,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showSucessDialog(BuildContext ctx, String message) async {
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF00AB6C),
                  foregroundColor: Colors.white,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.check,
                      size: 35,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
