// ignore_for_file: avoid_print, prefer_collection_literals, constant_identifier_names, import_of_legacy_library_into_null_safe, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
//import http package to make http requests
import 'package:appointment_app_mobile/models.dart/Products.dart';
import 'package:appointment_app_mobile/models.dart/doctors.dart';
import 'package:appointment_app_mobile/models.dart/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart/appointment.dart';
import '../models.dart/cart.dart';
import '../models.dart/orders.dart';
import 'constants.dart' as constants;

class Services {
  static String path = constants.path;
  static Uri url = Uri.parse('$path/backend/app.php');
  static Uri doctorlist = Uri.parse('$path/backend/get_doctor.php');
  static Uri appointmentrequest =
      Uri.parse('$path/backend/add_appointment.php');
  static Uri getcurrent = Uri.parse('$path/backend/get_current.php');
  static Uri getPendingAppointment = Uri.parse('$path/backend/appointment.php');
  static Uri getAcceptedAppointment =
      Uri.parse('$path/backend/get_accepted_appointments.php');
  static Uri getRejectedAppointment =
      Uri.parse('$path/backend/get_rejected_appointment.php');
  static Uri getPatientByid = Uri.parse('$path/backend/get_patient_by_id.php');
  static Uri getProductByid = Uri.parse('$path/backend/get_product_by_id.php');
  static Uri getOrderByid = Uri.parse('$path/backend/get_orders_by_id.php');

  static Uri getAcceptedAppointmentsforPatient =
      Uri.parse('$path/backend/get_accepted_appointment_for_patient.php');

  static Uri addtoOrder = Uri.parse('$path/backend/add_order.php');

  static Uri addtoCart = Uri.parse('$path/backend/addtocart.php');

  static Uri getCartitems = Uri.parse('$path/backend/getCartItems.php');
  static Uri deleteAllItemFromCart =
      Uri.parse('$path/backend/delete_all_from_cart.php');

  static const _CREATE_TABLE_ACTION = 'CREATE_TABLE';
  static const _ADD_EMP_ACTION = 'ADD_EMP';
  static const _UPDATE_EMP_ACTION = 'UPDATE_EMP';
  static const _DELETE_EMP_ACTION = 'DELETE_EMP';
  static const _CHECK_IF_LOGGED_IN = 'CHECK_IF_LOGGED_IN';
  static const _GET_CURRENT = 'GET_CURRENT';
  static const _GET_ITEM_DELETED = 'deleteitemtbyid';

  // Method to create the table Employees.
  static Future<String> createTable() async {
    try {
      // add the parameters to pass to the request.
      var map = Map<String, dynamic>();
      map['action'] = _CREATE_TABLE_ACTION;
      final response = await http.post(url, body: map);
      log('Create Table Response: ${response.body.toString()}');
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      log('Create Table ERROR: $e');
      return "error";
    }
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _CHECK_IF_LOGGED_IN;
      map['email'] = email;
      map['password'] = password;

      final response = await http.post(url, body: map);
      log('login Response: ${response.body}');
      if (response.body.contains("true")) {
        return true;
      } else {
        //return true if the status code is 200
        return false;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<List<Doctor>> getDoctors() async {
    // CollectionReference users = FirebaseFirestore.instance.collection('user');
    var map = Map<String, dynamic>();
    // ignore: unused_local_variable
    final response = await http.post(doctorlist, body: map); //
    var list = json.decode(response.body);
    final doctorsArray =
        list.map<Doctor>((json) => Doctor.fromJson(json)).toList();
    log("doctors list${doctorsArray.toString()}");
    return doctorsArray;
  }

  static Future<List<Doctor>> getPatientById(String id) async {
    //var map = Map<String, String>();
    // ignore: unused_local_variable
    // map['action'] = "getpatientbyid";

    // map['patientid'] = "2";
    try {
      var map = Map<String, dynamic>();
      map['id'] = id;

      final response = await http.post(getPatientByid, body: map); //

      var list = json.decode(response.body);
      log("getpatientbyid: ${response.body.toString()}");
      final doctorsArray =
          list.map<Doctor>((json) => Doctor.fromJson(json)).toList();
      log("doctors list${response.body.toString()}");
      return doctorsArray;
    } catch (e) {
      log("Error getting user by id $id");
      log("error: ${e.toString()}");
      return [];
    }
  }

  static Future<bool> addAppointment(
      {required String doctorId,
      required String appointmentDate,
      required String appointmentTime,
      required String description}) async {
    try {
      var map = Map<String, dynamic>();
      // map['action'] = _ADD_APPOINTMENT_ACTION;
      map['doctorId'] = doctorId;
      //Todo: set current user id to patientID
      var preference = await SharedPreferences.getInstance();
      var currentcurrentUserId = preference.getString("id");
      map['patientId'] = currentcurrentUserId;
      map['appointmentDate'] = appointmentDate;
      map['appointmentTime'] = appointmentTime;
      map['description'] = description;
      map['appointmentStatus'] = "pending";
      log("map: ${map.length}");
      log("date: $appointmentDate");
      log("doctorid: $doctorId");

      log("time: $appointmentTime");

      final response = await http.post(appointmentrequest, body: map);
      print('addappointment Response: ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  static Future<List<Doctor>> getCurrentUser() async {
    var map = Map<String, dynamic>();
    map['action'] = _GET_CURRENT;
    var shared = await SharedPreferences.getInstance();

    var currentUserEmail = shared.getString("email");
    //log("Current user email: ${currentUserEmail.toString()}");

    map['email'] = currentUserEmail;
    final response = await http.post(getcurrent, body: map);
    if (response.statusCode == 200) {
      log("200");
      log("current user${response.body.toLowerCase()}");
    }
    var list = json.decode(response.body);
    final doctorsArray =
        list.map<Doctor>((json) => Doctor.fromJson(json)).toList();
    return doctorsArray;
  }

  static List<User> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  // Method to add users to the database...
  static Future<bool> addUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _ADD_EMP_ACTION;
      map['first_name'] = firstName;
      map['last_name'] = lastName;
      map['email'] = email;
      map['password'] = password;
      map['role'] = role;

      log("map: ${map.length}");
      final response = await http.post(url, body: map);
      print('addEmployee Response: ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Method to update an Employee in Database...
  static Future<bool> updateEmployee(
    String appid,
    String status,
  ) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _UPDATE_EMP_ACTION;
      map['appointmentid'] = appid;
      map['status'] = status;
      final response = await http.post(url, body: map);
      print('updateEmployee Response: ${response.body}');
      if (200 == response.statusCode) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("error");
      return false;
    }
  }

  // Method to Delete an Employee from Database...
  static Future<String> deleteEmployee(String empId) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = _DELETE_EMP_ACTION;
      map['emp_id'] = empId;
      final response = await http.post(url, body: map);
      print('deleteEmployee Response: ${response.body}');
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      return "error"; // returning just an "error" string to keep this simple...
    }
  }
  //appointments

  static Future<List<Appointment>> getPendingAppointmentsForDoctor() async {
    var pref = await SharedPreferences.getInstance();
    var id = pref.getString("id");
    log("Useridpref: $id");
    var map = Map<String, String>();
    map['email'] = id!;

    var response = await http.post(getPendingAppointment, body: map);
    if (response.statusCode == 200) {
      log("200");
      log("pendingappointment:${response.body.toString()}");
    }
    var list = json.decode(response.body);
    final appointments =
        list.map<Appointment>((json) => Appointment.fromJson(json)).toList();
    return appointments;
  }

  static Future<List<Appointment>> getAcceptedAppointmentsForPatient() async {
    var pref = await SharedPreferences.getInstance();
    String? id = pref.getString("id");
    log("Useridpref: $id");
    var map = Map<String, String>();
    map['email'] = id!;

    var response =
        await http.post(getAcceptedAppointmentsforPatient, body: map);
    if (response.statusCode == 200) {
      log("200");
      log("accepted appointment:${response.body.toString()}");
    }
    var list = json.decode(response.body);
    final appointments =
        list.map<Appointment>((json) => Appointment.fromJson(json)).toList();
    return appointments;
  }

  //accepted appointment for patient
  static Future<List<Appointment>> getAcceptedAppointments() async {
    var pref = await SharedPreferences.getInstance();
    var id = pref.getString("id");
    var map = Map<String, dynamic>();
    map['email'] = id!;

    var response = await http.post(getAcceptedAppointment, body: map);
    if (response.statusCode == 200) {
      log("200");
      log("acceptedappointment:${response.body.toString()}");
    }
    var list = json.decode(response.body);
    final appointments =
        list.map<Appointment>((json) => Appointment.fromJson(json)).toList();
    return appointments;
  }

  static Future<List<Appointment>> getrejectedAppointments() async {
    var pref = await SharedPreferences.getInstance();

    var id = pref.getString("id");
    var map = Map<String, dynamic>();

    map['email'] = id!;

    var response = await http.post(getRejectedAppointment, body: map);
    if (response.statusCode == 200) {
      log("200");
      log("rejectedappointments:${response.body.toString()}");
    }
    var list = json.decode(response.body);
    final appointments =
        list.map<Appointment>((json) => Appointment.fromJson(json)).toList();
    return appointments;
  }

  static Future<bool> addToCart({
    required String userId,
    required String itemId,
  }) async {
    try {
      var map = Map<String, dynamic>();

      map['userid'] = userId;
      map['itemid'] = itemId;

      log("map: ${map.length}");
      final response = await http.post(addtoCart, body: map);
      print('addToCart Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<List<Cart>> getCurrentCartItems() async {
    var map = Map<String, dynamic>();

    var shared = await SharedPreferences.getInstance();

    var currentUserId = shared.getString("id");
    //log("Current user email: ${currentUserEmail.toString()}");

    map['id'] = currentUserId;
    final response = await http.post(getCartitems, body: map);
    if (response.statusCode == 200) {}
    var list = json.decode(response.body);
    final cartItemArray =
        list.map<Cart>((json) => Cart.fromJson(json)).toList();
    return cartItemArray;
  }

  static Future<List<Product>> getProductById(String id) async {
    try {
      var map = Map<String, dynamic>();
      map['id'] = id;

      final response = await http.post(getProductByid, body: map); //

      var list = json.decode(response.body);
      log("getProductsbyid: ${response.body.toString()}");
      final doctorsArray =
          list.map<Product>((json) => Product.fromJson(json)).toList();
      log("products by id list${response.body.toString()}");
      return doctorsArray;
    } catch (e) {
      log("Error getting product by id $id");
      log("error: ${e.toString()}");
      return [];
    }
  }

  static Future<String> deleteItem(String itemId) async {
    try {
      var map = Map<String, dynamic>();
      var shared = await SharedPreferences.getInstance();

      var currentUserId = shared.getString("id");
      map['action'] = _GET_ITEM_DELETED;
      map['emp_id'] = itemId;
      map['userid'] = currentUserId;
      final response = await http.post(url, body: map);
      print('deleteEmployee Response: ${response.body}');
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      return "error"; // returning just an "error" string to keep this simple...
    }
  }

  // Method to add users to the database...
  static Future<bool> addOrder() async {
    try {
      var shared = await SharedPreferences.getInstance();

      var currentUserId = shared.getString("id");
      var map = Map<String, dynamic>();

      map['userid'] = currentUserId;

      log("map: ${map.length}");
      final response = await http.post(addtoOrder, body: map);
      final response2 = await http.post(deleteAllItemFromCart, body: map);
      log(response2.statusCode.toString());
      log('add order response: ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<List<Order>> getOrderItemsById() async {
    var map = <String, dynamic>{};

    var shared = await SharedPreferences.getInstance();

    var currentUserId = shared.getString("id");
    //log("Current user email: ${currentUserEmail.toString()}");

    map['id'] = currentUserId;
    final response = await http.post(getOrderByid, body: map);
    if (response.statusCode == 200) {}
    var list = json.decode(response.body);
    final cartItemArray =
        list.map<Order>((json) => Order.fromJson(json)).toList();
    return cartItemArray;
  }
}
