// import 'package:flutter/material.dart';
// import 'package:nithlostnfound/Pages/Dropmenu/dropmenu.dart';

// class FilterSection extends StatelessWidget {
//   final List<String> itemTypes;
//   final String? selectedItemType;
//   final ValueChanged<String?> onItemTypeChanged;

//   final List<String> locations;
//   final String? selectedLocation;
//   final ValueChanged<String?> onLocationChanged;

//   final List<String> boysHostels;
//   final List<String> girlsHostels;
//   final List<String> departments;
//   final String? selectedHostel;
//   final String? selectedDepartment;
//   final String? selectedLocationValue;
//   final ValueChanged<String?> onHostelChanged;
//   final ValueChanged<String?> onDepartmentChanged;

//   const FilterSection({
//     super.key,
//     required this.itemTypes,
//     required this.selectedItemType,
//     required this.onItemTypeChanged,
//     required this.locations,
//     required this.selectedLocation,
//     required this.onLocationChanged,
//     required this.boysHostels,
//     required this.girlsHostels,
//     required this.departments,
//     required this.selectedHostel,
//     required this.selectedDepartment,
//     required this.selectedLocationValue,
//     required this.onHostelChanged,
//     required this.onDepartmentChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         AppDropdownMenu<String>(
//           label: 'Item Type',
//           value: selectedItemType,
//           items: itemTypes,
//           onChanged: onItemTypeChanged,
//         ),
//         const SizedBox(height: 16),
//         AppDropdownMenu<String>(
//           label: 'Location',
//           value: selectedLocation,
//           items: locations,
//           onChanged: (value) {
//             onLocationChanged(value);
//             // Handle conditional dropdown reset
//           },
//         ),
//         if (selectedLocationValue == 'Boys Hostel')
//           AppDropdownMenu<String>(
//             label: 'Select Boys Hostel',
//             value: selectedHostel,
//             items: boysHostels,
//             onChanged: onHostelChanged,
//           )
//         else if (selectedLocationValue == 'Girls Hostel')
//           AppDropdownMenu<String>(
//             label: 'Select Girls Hostel',
//             value: selectedHostel,
//             items: girlsHostels,
//             onChanged: onHostelChanged,
//           )
//         else if (selectedLocationValue == 'Department')
//           AppDropdownMenu<String>(
//             label: 'Select Department',
//             value: selectedDepartment,
//             items: departments,
//             onChanged: onDepartmentChanged,
//           ),
//       ],
//     );
//   }
// }
