import 'package:absensi/ui/absen/absen_screen.dart';
import 'package:absensi/ui/attend/attend_screen.dart';
import 'package:absensi/ui/attendance_history/attandance_history_screen.dart';
import 'package:flutter/material.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});



  @override
  Widget build(BuildContext context) {

    List<String> listAbsen = [
      'Absensi Kehadiran',
      'Izin / Cuti',
      'Riwayat Kehadiran'
    ];

    List<String> listImg = [
      'assets/images/ic_absen.png',
      'assets/images/ic_leave.png',
      'assets/images/ic_history.png'
    ];


    List<Widget> listSscreen = [
      const AttendScreen(),
      const AbsenScreen(),
      const AttandanceHistoryScreen()

    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop){
        if(didPop){
          return;
        }
        _onWillPop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Container(
            //       margin: const EdgeInsets.all(10),
            //       child: Expanded(
            //         child: InkWell(
            //           highlightColor: Colors.transparent,
            //           splashColor: Colors.transparent,
            //           onTap: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => const AttendScreen(),
            //               ),
            //             );
            //           },
            //           child: const Column(
            //             children: [
            //               Image(
            //                 image: AssetImage('assets/images/ic_absen.png'),
            //                 width: 100,
            //                 height: 100,
            //               ),
            //               SizedBox(
            //                 height: 10,
            //               ),
            //               Text('Absen Kehadiran')
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //     Container(
            //       margin: const EdgeInsets.all(10),
            //       child: Expanded(
            //         child: InkWell(
            //           highlightColor: Colors.transparent,
            //           splashColor: Colors.transparent,
            //           onTap: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => const AbsenScreen(),
            //               ),
            //             );
            //           },
            //           child: const Column(
            //             children: [
            //               Image(
            //                 image: AssetImage('assets/images/ic_leave.png'),
            //                 width: 100,
            //                 height: 100,
            //               ),
            //               SizedBox(
            //                 height: 10,
            //               ),
            //               Text('Absen Izin')
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //     Container(
            //       margin: const EdgeInsets.all(10),
            //       child: Expanded(
            //         child: InkWell(
            //           highlightColor: Colors.transparent,
            //           splashColor: Colors.transparent,
            //           onTap: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) =>
            //                 const AttandanceHistoryScreen(),
            //               ),
            //             );
            //           },
            //           child: const Column(
            //             children: [
            //               Image(
            //                 image: AssetImage('assets/images/ic_history.png'),
            //                 width: 100,
            //                 height: 100,
            //               ),
            //               SizedBox(
            //                 height: 10,
            //               ),
            //               Text('History')
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('Good Morning!', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700),),
                    Text('Today is 21 june 2025', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                  ],
                ),
                const SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => listSscreen[index],
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              border: Border.all(color: Colors.white60, width: 2),
                              borderRadius: BorderRadius.circular(15),
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child:Image(image: AssetImage(listImg[index]), width: 50, height: 50,),
                              ),
                              const SizedBox(height: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listAbsen[index],
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
                                  ),
                                  Text(
                                    'Scheduled',
                                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13, color: Colors.white60),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },

                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _onWillPop(BuildContext context) async {
  return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info'),
        content:
        const Text('Apakah anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      )) ??
      false);
}