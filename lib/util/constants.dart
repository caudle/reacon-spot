import 'package:intl/intl.dart';

const String emailRegex =
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const String baseUrl = "http://172.20.10.4:5000";
const String ws = "ws://172.20.10.4:5000";

final formatCurrency = NumberFormat('#,##0.00');
