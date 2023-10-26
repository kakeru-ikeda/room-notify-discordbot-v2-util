import 'package:flutter/material.dart';
import 'package:room_notify_discordbot_v2_util/component/style/text_style_template.dart';

class PageTemplate {
  static setPageTitle({required String title, required String caption}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyleTemplate.pageTitle,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Text(caption),
        ),
      ],
    );
  }
}
