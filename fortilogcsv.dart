import 'dart:io';
import 'dart:typed_data';

main(List<String> args) {
// String filePath = "C:/Users/leam_/OneDrive/Desktop/Log firewall/";
// arg[0] = filePath + "log-traffic-forward-140150-140650 - Copy (2).txt";
  if (args.contains("/?") || args.contains("-h") || args.contains("--help")) {
    print("fortinet-to-csv.exe filename [-o new-filename]");
    return;
  }

  // String fileName = "";
  String newFileName = "";
  if (args.length < 1) {
    print("fortinet-to-csv.exe filename [-o new-filename]");
    return;
  }
  if (File(args[0]).existsSync() == false) {
    print("File not found!");
    return;
  }
  if (args.length > 1) {
    if (args[1] != "-o") {
      print("We only able to convert 1 file at a time.");
      return;
    }

    if (args.length > 2) newFileName = args[2];
    if (newFileName == "") newFileName = args[0] + ".csv";
  } else {
    newFileName = args[0] + ".csv";
  }

  if (isWriteAbleFile(newFileName) == false) {
    print("New file cannot be accessible!");
    return;
  }

  List<String> lst = File(args[0]).readAsLinesSync();
  print("Found ${lst.length} records.");

  print(" ");
  print("Searching headers...");
//Normalize Header
  List<String> lstHeader = List.empty(growable: true);
  for (var element in lst) {
    var tmpElement = element.replaceAll(RegExp('"([^"]+)"'), "");
    var lstTmp = tmpElement.split(" ");
    for (var tmp in lstTmp) {
      var lstTmp1 = tmp.split("=");
      if (lstHeader.contains(lstTmp1[0]) == false) lstHeader.add(lstTmp1[0]);
    }
  }

  print("Found ${lstHeader.length} headers:");
  print(lstHeader);

  print(" ");
  print("Processing data conversion...");
//Separate data to header
  List<Map<String, dynamic>> lstData = List.empty(growable: true);
  for (var element in lst) {
    Map<String, dynamic> lstTmp = {};
    for (var header in lstHeader) {
      RegExp reg = RegExp(header + '=("[^"]+"|[^ ]+)');
      String a = "";
      var m = reg.firstMatch(element);
      if (m != null) {
        a = m.group(1) ?? "";
      }
      lstTmp.addAll({header: a});
    }
    lstData.add(lstTmp);
  }
  lst = List.empty(growable: true);

//add header to csv
  lst.add(lstHeader.join(","));

//Data conversion
  for (var data in lstData) {
    List<String> dt = List.empty(growable: true);
    for (var header in lstHeader) {
      String tmp = data[header];
      if (tmp.contains('"')) {
        tmp = tmp.replaceAll('"', '');
      }
      if (tmp.contains(",")) {
        tmp = tmp.replaceAll(",", "_");
      }
      dt.add(tmp);
    }
    lst.add(dt.join(","));
  }

  print("Saving data to file...");
  File(newFileName).writeAsStringSync(lst.join('\r\n'));
  print("Done !!!");
  print("CSV saved to: " + newFileName);
}

bool isWriteAbleFile(String fileName) {
  var f = File(fileName);
  try {
    if (f.existsSync() == false) {
      f.writeAsStringSync("test");
      f.deleteSync();
      return true;
    }

    Uint8List a = f.readAsBytesSync();
    f.deleteSync();
    f.writeAsBytesSync(a);
    return true;
  } catch (e) {
    print(e);
  }

  return false;
}
