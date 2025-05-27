import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcons {
  static const Map<String, IconData> iconMap = {
    'home': FontAwesomeIcons.home,
    'lightbulb': FontAwesomeIcons.lightbulb,
    'shoppingCart': FontAwesomeIcons.shoppingCart,
    'bus': FontAwesomeIcons.bus,
    'film': FontAwesomeIcons.film,
    'heart': FontAwesomeIcons.heart,
    'shieldHalved': FontAwesomeIcons.shieldHalved,
    'piggyBank': FontAwesomeIcons.piggyBank,
    'utensils': FontAwesomeIcons.utensils,
    'shoppingBag': FontAwesomeIcons.shoppingBag,
    'graduationCap': FontAwesomeIcons.graduationCap,
    'gift': FontAwesomeIcons.gift,
    'plane': FontAwesomeIcons.plane,
    'gasPump': FontAwesomeIcons.gasPump,
    'tshirt': FontAwesomeIcons.tshirt,
    'mobileAlt': FontAwesomeIcons.mobileAlt,
    'book': FontAwesomeIcons.book,
    'footballBall': FontAwesomeIcons.footballBall,
    'paw': FontAwesomeIcons.paw,
    'handsHelping': FontAwesomeIcons.handsHelping,
    'chartLine': FontAwesomeIcons.chartLine,
    'music': FontAwesomeIcons.music,
    'paintBrush': FontAwesomeIcons.paintBrush,
    'fileInvoiceDollar': FontAwesomeIcons.fileInvoiceDollar,
    'moneyCheck': FontAwesomeIcons.moneyCheck,
    'fileAlt': FontAwesomeIcons.fileAlt,
    'handshake': FontAwesomeIcons.handshake,
    'baby': FontAwesomeIcons.baby,
    'hammer': FontAwesomeIcons.hammer,
    'dumbbell': FontAwesomeIcons.dumbbell,
    'creditCard': FontAwesomeIcons.creditCard,
    'palette': FontAwesomeIcons.palette,
    'spa': FontAwesomeIcons.spa,
    'broom': FontAwesomeIcons.broom,
    'ticketAlt': FontAwesomeIcons.ticketAlt,
    'ring': FontAwesomeIcons.ring,
    'cocktail': FontAwesomeIcons.cocktail,
    'firstAid': FontAwesomeIcons.firstAid,
    'ellipsis': FontAwesomeIcons.ellipsis,
  };

  static IconData getIconByName(String iconName) {
    return iconMap[iconName] ?? FontAwesomeIcons.questionCircle;
  }

  static List<String> get iconNames => iconMap.keys.toList();
}