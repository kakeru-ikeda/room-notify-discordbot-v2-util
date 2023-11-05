import 'package:flutter/material.dart';

class ModalContentsTemplate {
  static setContents(
      {required BuildContext context, required Widget contents}) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.close,
                    size: 24,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            contents,
          ],
        ),
      ),
    );
  }
}
