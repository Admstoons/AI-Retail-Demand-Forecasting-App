import 'package:flutter/material.dart';


class DashboardCardModel {
  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  DashboardCardModel({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });
}
