import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health_management_admin/firebase_options.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AdminPanel(),
    );
  }
}

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Dashboard(),
            AppointmentsList(),
            LabTestsList(),
            TransactionsList(),
            UsersList(),
          ],
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int totalUsers = 0;
  int totalAppointments = 0;
  int totalLabTests = 0;

  @override
  void initState() {
    super.initState();
    getCounts();
  }

  Future<void> getCounts() async {
    // Fetch total users
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    // Fetch total appointments
    QuerySnapshot appointmentsSnapshot =
        await FirebaseFirestore.instance.collection('appointments').get();
    // Fetch total lab tests
    QuerySnapshot labTestsSnapshot =
        await FirebaseFirestore.instance.collection('lab-test').get();

    // Update state with the counts
    setState(() {
      totalUsers = usersSnapshot.size;
      totalAppointments = appointmentsSnapshot.size;
      totalLabTests = labTestsSnapshot.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(20),
      child: screenWidth < 600
          ? Column(
              children: [
                InfoCard(
                    title: 'Total Users',
                    count: '$totalUsers',
                    color: Colors.green,
                    icon: Icons.people,
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => UsersList()));
                    }),
                InfoCard(
                    title: 'Total Appointments',
                    count: '$totalAppointments',
                    color: Colors.orange,
                    icon: Icons.schedule,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AppointmentsList()));
                    }),
                InfoCard(
                    title: 'Total Lab Tests',
                    count: '$totalLabTests',
                    color: Colors.blue,
                    icon: Icons.medical_services,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LabTestsList()));
                    }),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InfoCard(
                    title: 'Total Users',
                    count: '$totalUsers',
                    color: Colors.green,
                    icon: Icons.people,
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => UsersList()));
                    }),
                InfoCard(
                    title: 'Total Appointments',
                    count: '$totalAppointments',
                    color: Colors.orange,
                    icon: Icons.schedule,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AppointmentsList()));
                    }),
                InfoCard(
                    title: 'Total Lab Tests',
                    count: '$totalLabTests',
                    color: Colors.blue,
                    icon: Icons.medical_services,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LabTestsList()));
                    }),
              ],
            ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const InfoCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        child: Container(
          padding: EdgeInsets.all(20),
          width: 200,
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 40),
              SizedBox(height: 10),
              Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 5),
              Text(count,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appointments',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No appointments found.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return AppointmentCard(
                      appointment: snapshot.data!.docs[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final QueryDocumentSnapshot appointment;

  const AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Colors.blue[50],
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Colors.blue),
        title: Text('${appointment['name']}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${appointment['doctor']}'),
            Text('Date: ${appointment['appointmentDate']}'),
            Text('Email: ${appointment['email']}'),
            Text('Phone: ${appointment['phone']}'),
            Text('Payment Status: ${appointment['payment_status']}'),
          ],
        ),
      ),
    );
  }
}

class LabTestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lab Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('lab-test').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No lab tests found.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return LabTestCard(labTest: snapshot.data!.docs[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class LabTestCard extends StatelessWidget {
  final QueryDocumentSnapshot labTest;

  const LabTestCard({required this.labTest});

  @override
  Widget build(BuildContext context) {
    TextEditingController reportController = TextEditingController();
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Colors.teal[50],
      child: ListTile(
        leading: Icon(Icons.medical_services, color: Colors.teal),
        title: Text('${labTest['lab_test_name']}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: BDT ${labTest['price']}'),
            Text('Payment Status: ${labTest['payment_status']}'),
            Text('Time of Delivery: ${labTest['report_delivery_date']}'),
            if (!(labTest.data() as Map<String, dynamic>)
                    .containsKey('report') &&
                labTest['payment_status'] == 'paid')
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Deliver Report'),
                        content: TextField(
                          controller: reportController,
                          maxLines: 3,
                          decoration: InputDecoration(
                              hintText: "Write the report here"),
                          onSubmitted: (report) async {
                            await FirebaseFirestore.instance
                                .collection('lab-test')
                                .doc(labTest.id)
                                .update({
                              'report': report,
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        actions: [
                          TextButton(
                            child: Text('Submit'),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('lab-test')
                                  .doc(labTest.id)
                                  .update({
                                'report': reportController.text,
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Deliver Report'),
              ),
            if ((labTest.data() as Map<String, dynamic>).containsKey('report'))
              Text('Report Delivered', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

class TransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transactions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('transactions')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No transactions found.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return TransactionCard(
                      transaction: snapshot.data!.docs[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final QueryDocumentSnapshot transaction;

  const TransactionCard({required this.transaction});

  Future<String> getUserName(String userId) async {
    // Fetch user data from Firestore using the user ID
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if the user document exists and return the name, otherwise return 'Unknown User'
    if (userSnapshot.exists) {
      return userSnapshot['full_name'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Colors.amber[50],
      child: ListTile(
        leading: Icon(Icons.payment, color: Colors.amber),
        title: Text('Transaction Amount: BDT ${transaction['amount']}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${transaction['status']}'),
            Text('Paid By: ${transaction['card_type']}'),
            Text(
                'Date: ${DateFormat('dd MMM yyyy hh:mm aa').format(transaction['time'].toDate())}'),
            FutureBuilder<String>(
              future: getUserName(
                  transaction['user']), // Fetch the user's name using the ID
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                      'User: Loading...'); // Display loading indicator while fetching
                }
                if (snapshot.hasError) {
                  return Text('User: Error'); // Handle error if occurs
                }
                return Text('User: ${snapshot.data}'); // Display the user name
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No users found.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return UserCard(user: snapshot.data!.docs[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final QueryDocumentSnapshot user;

  const UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 5),
      color: Colors.purple[50],
      child: ListTile(
        leading: Icon(Icons.person, color: Colors.purple),
        title: Text('${user['full_name']}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Email: ${user['email']}\nAddress: ${user['address']}'),
      ),
    );
  }
}
